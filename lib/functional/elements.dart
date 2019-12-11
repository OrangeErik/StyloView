import 'dart:io';
import 'dart:async';
import 'package:StyloView/WindowsAndWidgets/paginated_data_table_erik.dart';
import 'package:archive/archive.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:utf/utf.dart';
import 'package:http/http.dart' as http;
import 'package:StyloView/erik_amqp/my_amqp.dart' as mq;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:xml/xml.dart';
import 'dart:math';
import 'package:StyloView/WindowsAndWidgets/ExpansionListTile.dart';
import 'package:StyloView/functional/StyloViewLib.dart';
import 'package:StyloView/functional/sqlProvider.dart';
import 'package:StyloView/WindowsAndWidgets/ReportTable.dart';
import 'package:StyloView/functional/SELib.dart';
import 'package:flutter/material.dart';


class SState{
	SState(this.State, this.StateCode);
	bool State;
	int  StateCode;
}

enum AccessState{not_auth, auth,}

class DataEtty{
	DataEtty(this.Zone, this.FieldName, this.ClmnName, this.Total, this.Type, this.Data);
	String Zone;
	String FieldName;
	String ClmnName;
	int    Total;
	String Type;
	List   Data;
	List<String> GAccs;
}

class AuthEntry{
	AuthEntry([this.AuthAccess = AccessState.not_auth]);
	String get Name => _Name;
	String get DbTableName => _DBTName;

	set Name(String name){
		_Name = name;
		_DBTName = name + '_table';
	}

	Z()
	{
		AuthAccess = AccessState.not_auth;
		GUID = null;
		_Name = null;
		DomainName = null;
		TimeDate = null;
		_DBTName = null;
	}

	AccessState AuthAccess;
	int NameID;
	DateTime TimeDate;
	String _Name;
	String DomainName;
	String GUID;
	String _DBTName;
}

class PersonalSetting {
	PersonalSetting([this.ReportsStorageDuration = C.week, this.ReportsStorageCount = 0]);

	int ReportsStorageDuration;
	int ReportsStorageCount;
}

class FormatData{
	FormatData(this.DC, this.Data);
	List<DataColumnErik> DC;
	List<TRow> Data;
}

class AppState extends ChangeNotifier {
	AppState() {
		ReportRowsPerPage = 25;
		SortAscending = true;
		PersonSetting = PersonalSetting(C.DS_STORAGE_REPORT_DURATION, C.DS_STORAGE_REPORT_COUNT);
		_RoutingParam = mq.RoutingParamEntry();
		_Auth = AuthEntry();
		_MQCS = mq.ConnectionSettings(host: "");
		getExternalStorageDirectory().then((directory) async {
			Dir = directory.path;
			C.Dir = Dir;
			final File file = File("$Dir/${C.s_AUTHFILE}");
			String temp_buf;
			if(file != null && file.existsSync()) {
				temp_buf = file.readAsStringSync();
				if(temp_buf != null && temp_buf.isNotEmpty) {
					var xml_auth = parse(temp_buf);
					_RowMqsConfigStr = xml_auth
						.findAllElements("CommonMqsConfig")
						.first
						.toString();
					XmlDocument doc = parse(_RowMqsConfigStr);
					_MQCS = mq.ConnectionSettings(
						host: doc.findAllElements("host").first.text,
						virtualHost: C.s_papyrus,
						authProvider: mq.PlainAuthenticator(doc.findAllElements("user").first.text, doc.findAllElements("secret").first.text)
					);
				}
			}
			if(_MQCS.host.isEmpty) {
				try {
					await UhttRequestSetting().then((settingsInXml) {
						SetSettingFromXml(settingsInXml);
					});
				} catch(e) {
					print(e);
					print("нет соединения с UHTT");
				}
			}
			await ConnectAndChannelMQ();
			LogIn(authFile: file);
			GetPersonSettingFromMemory();
		});
	}

	void ReDraw() {
		notifyListeners();
	}

	//Авторизация
	AuthEntry get GetAuth
	{
		return _Auth;
	}

	void SetAuthDomain(String domainName) {
		_Auth.DomainName = domainName;
	}

	void SetAuthName(List name) {
		_Auth.Name = name[C.GGLAindexName];
		_Auth.NameID = int.parse(name[C.GGLAindexID]);
	}

	void SetAuthTimeDate(DateTime dt) {
		_Auth.TimeDate = dt;
	}

	void SetAuth(AccessState aState) async
	{
		if(aState == AccessState.auth) { // Если авторизация, то...
			_Auth.AuthAccess = AccessState.auth;
			_RoutingParam.SetupReserved(mq.VarMQ.rtrsrvStyloView, _Auth.DomainName, _Auth.GUID, 0);
			ReportPreporationListen(5);
		}
	}

	Future<void> ConnectAndChannelMQ() async
	{
		_ClientMQ = mq.CreateClient(_MQCS);
		_ChannelMQ = await mq.CreateChannelForClient(_ClientMQ);
	}

	//
	//  attemptsCount ограничивает количество попыток подключения к RabbitMQ
	//    Если при попытке преднастроки прослушивания и при прослушивании происходит ошибка, то
	//    пока attemptsCount > 0 будет происходить рекурсивная попытка подключиться заново
	//
	Future<void> ReportPreporationListen(attemptsCount) async
	{
		if(attemptsCount > 0) {
			if(_Auth.AuthAccess == AccessState.auth) {
				try {
					mq.Exchange mq_exchange = await mq.BindExchangeForChannel(
						_ChannelMQ, _RoutingParam.ExchangeName, _RoutingParam.ExchangeType);
					mq.Queue mq_queue = await mq.CreateQueue(_ChannelMQ, _RoutingParam.QueueName);
					await mq.BindExchangeAndQueueByRoutingKey(mq_queue, mq_exchange, _RoutingParam.RoutingKey);
					await ListenReports(mq_queue);
					await CheckReports(PersonSetting).then((_) => CastDrawer());
					Timer.periodic(Duration(minutes: 3), (timer) async {
						try {
							ListenReports(mq_queue);
						} catch(error) {
							timer.cancel();
							print(error.toString());
							RabbitConnectionRecast(attemptsCount - 1);
						}
					});
				}catch(error) {
					print(error.toString());
					RabbitConnectionRecast(attemptsCount - 1);
				}
			}
		}
		else {
			print(C.s_rabbitMQConnectionError);
		}
	}

	Future<void> RabbitConnectionRecast(int attemptsCount) async
	{
		if(attemptsCount > 0) {
			ZRabbit();
			await ConnectAndChannelMQ();
			ReportPreporationListen(attemptsCount);
		}
		else {
			print(C.s_rabbitMQConnectionError);
		}
	}

	Future ListenReports(mq.Queue MQQueue) async
	{
		_ConsumerMQ?.cancel();
		_ConsumerMQ = await MQQueue.consume(noAck: false);
		_ConsumerMQ.listen((message) { // тут уже слушаем очередь, в которую сливаются отчеты
			String report_name = message.properties.headers['namedfilt-name'].toString();
			DateTime date_time = message.properties.timestamp;
			Map meta_data = message.properties.headers; // доп. инфа по фильтру
			List<int> xml_data = message.payload.toList();
			SqlRow sql_data = SqlRow(
				DateTime: date_time.toString(),
				ReportName: report_name,
				MetaData: meta_data.toString(),
				CompressXmlData: xml_data,
				Total: [0],
				Reserve: [0],
			);
			if(DataTest(sql_data).State) {
				SqlProvider.Db.SetRow(_Auth.DbTableName, sql_data).then((_) async{
					await CheckReports(PersonSetting).then((_) => CastDrawer());
				});
			}
			message.ack();
		});
	}

	void ZRabbit() async {
		await _ChannelMQ.close();
		await _ClientMQ.close();
		await _ConsumerMQ.cancel();
		_ClientMQ = null;
		_ChannelMQ = null;
		_ConsumerMQ = null;
	}

	SState DataTest(SqlRow sqlData) {
		SState ok;
		String temp_buf;
		Iterable<XmlElement> temp_iter;
		Map<String, String> meta_map = new Map();
		meta_map = sqlData.MDToMap();
		List<int> bytes_buf = ZLibDecoder().decodeBytes(sqlData.CompressXmlData);
		temp_buf = decodeUtf8(bytes_buf);
		temp_buf = XmlSymbReplace(temp_buf);
		XmlDocument xml_document = parse(temp_buf); // парсим весь документ
		temp_iter = xml_document.findAllElements("Types");
		if(temp_iter.isNotEmpty) {
			temp_iter = xml_document.findAllElements("ViewDescription");
			if(temp_iter.isNotEmpty) {
				temp_iter = temp_iter.first.findAllElements('Item'); //все Itemы в ViewDescription
				if(temp_iter.isNotEmpty) {
					if(meta_map.containsKey("filename")) {
						ok = SState(true, 1); //Все ок
					}
					else
						ok = SState(false, 5); //ошибка метаданных
				}
				else
					ok = SState(false, 4); //нет "строк" (Iterов) в файле
			}
			else
				ok = SState(false, 3); //неопределены поля вывода
		}
		else
			ok = SState(false, 2); // если нет DTD в файле, и нет типов полей
		return ok;
	}

	void CastDrawer() {
		SqlProvider.Db.GetColumns(_Auth.DbTableName, [C.DB_ROW_FIELD_REPORTNAME, C.DB_ROW_FIELD_DATETIME]).then((sqlColumns) {
			Map<String, List<String>> report_choise_list = Map();
			for(int i = 0; i < sqlColumns.length; i++) {
				if(!report_choise_list.containsKey(sqlColumns[i][C.DB_ROW_FIELD_REPORTNAME])) {
					report_choise_list[sqlColumns[i][C.DB_ROW_FIELD_REPORTNAME]] =
					[sqlColumns[i][C.DB_ROW_FIELD_DATETIME]];
				}
				else {
					report_choise_list[sqlColumns[i][C.DB_ROW_FIELD_REPORTNAME]].add(
						sqlColumns[i][C.DB_ROW_FIELD_DATETIME]);
				}
			}
			ChoiceList = List<ExpansionListTile>.generate(report_choise_list.length, (i) {
				List dates_list = report_choise_list[report_choise_list.keys.toList()[i]].reversed.toList();
				String report_name = report_choise_list.keys.toList()[i];
				String report_date = dates_list[dates_list.length - 1];
				return ExpansionListTile(
					onLongPress: () {
						XmlDataFromSql(_Auth.DbTableName, report_name, dates_list[0]).then((entities) {
							if(entities != null && entities.isNotEmpty) {
								TableHeader = Text("$report_name от ${report_date.substring(0, 10)}");
								FormatData fd = DataCast(entities);
								Columns = fd.DC;
								Source = ReportTableSource(fd.Data, fd.DC.length);
								ReportWidget = ReportTable();
								ReDraw();
							}
						});
					},
					title: Text(report_name),
					children: List<Widget>.generate(dates_list.length, (j) {
						String report_date = dates_list[j];
						return ListTile(
							title: Text(report_date.substring(0, report_date.length - 4)),
							onTap: () {
								XmlDataFromSql(_Auth.DbTableName, report_name, report_date).then((entities) {
									if(entities != null && entities.isNotEmpty) {
										TableHeader = Text("$report_name от ${report_date.substring(0, 10)}");
										FormatData fd = DataCast(entities);
										Columns = fd.DC;
										Source = ReportTableSource(fd.Data, fd.DC.length);
										ReportWidget = ReportTable();
										ReDraw();
									}
								});
							},
						);
					}),
				);
			});
			ReDraw();
		}, onError: (e) {
			print(e);
		});
	}

	Future<void> CheckReports(PersonalSetting personSetting) async
	{
		if(personSetting.ReportsStorageDuration > 0) {
			await SqlProvider.Db.GetTable(_Auth.DbTableName)?.then((table) {
				table.forEach((sqlStr) {
					DateTime report_dt = DateTime.parse(sqlStr.DateTime);
					if(DateTime.now().millisecondsSinceEpoch - report_dt.millisecondsSinceEpoch > Duration(days: personSetting.ReportsStorageDuration).inMilliseconds) {
						SqlProvider.Db.DeleteRow(_Auth.DbTableName, sqlStr.Id);
					}
				});
			});
		}
		if(personSetting.ReportsStorageCount > 0) {
			await SqlProvider.Db.GetColumns(_Auth.DbTableName, [C.DB_ROW_FIELD_ID, C.DB_ROW_FIELD_REPORTNAME, C.DB_ROW_FIELD_DATETIME]).then((sqlColumns) {
				Map<String, List> report_check_list = Map();
				for(int i = 0; i < sqlColumns.length; i++) {
					if(!report_check_list.containsKey(sqlColumns[i][C.DB_ROW_FIELD_REPORTNAME])) {
						report_check_list[sqlColumns[i][C.DB_ROW_FIELD_REPORTNAME]] = [
							[sqlColumns[i][C.DB_ROW_FIELD_DATETIME], sqlColumns[i][C.DB_ROW_FIELD_ID]]
						];
					}
					else {
						report_check_list[sqlColumns[i][C.DB_ROW_FIELD_REPORTNAME]].add(
							[sqlColumns[i][C.DB_ROW_FIELD_DATETIME], sqlColumns[i][C.DB_ROW_FIELD_ID]]
						);
					}
				}
				report_check_list.forEach((name, mass){
					while(mass.length > personSetting.ReportsStorageCount){
						SqlProvider.Db.DeleteRow(_Auth.DbTableName, mass[0][1]);
						mass.removeAt(0);
					}
				});
			});
		}

	}

	void ResetToDefaultSetting() {
		PersonSetting = PersonalSetting(C.DS_STORAGE_REPORT_DURATION, C.DS_STORAGE_REPORT_COUNT);
		File setting_file = File("$Dir/${C.s_SETTINGFILE}");
		if(setting_file != null && setting_file.existsSync()){
			setting_file.deleteSync();
		}
	}

	void SavePersonSetting() {
		String auth_xml = '''<?xml version="1.0"?>
<PersonSetting>
    <ReportsStorageDuration>${PersonSetting.ReportsStorageDuration}</ReportsStorageDuration>
    <ReportsStorageCount>${PersonSetting.ReportsStorageCount}</ReportsStorageCount>
</PersonSetting>''';
		final File file = File("$Dir/${C.s_SETTINGFILE}");
		file.writeAsStringSync(auth_xml);
	}

	GetPersonSettingFromMemory()
	{
		final File setting_file = File("$Dir/${C.s_SETTINGFILE}");
		String temp_buf;
		if(setting_file != null && setting_file.existsSync()){
			temp_buf = setting_file.readAsStringSync();
			if(temp_buf != null && temp_buf.isNotEmpty){
				print(temp_buf);
				XmlDocument xml_setting = parse(temp_buf);
				temp_buf = xml_setting.findAllElements('ReportsStorageDuration').first.text;
				PersonSetting.ReportsStorageDuration = int.parse(temp_buf);
				temp_buf = xml_setting.findAllElements('ReportsStorageCount').first.text;
				PersonSetting.ReportsStorageCount = int.parse(temp_buf);
				ReDraw();
			}
		}
	}

	Future<List<DataEtty>> XmlDataFromSql(String tableName, String reportName, String dateTime)async{
		String temp_buf;
		Iterable<XmlElement> temp_iter;
		XmlElement temp_element;
		DataEtty entity = DataEtty('', '', '', 0, '', []);
		List<DataEtty>  entities = [];
		await SqlProvider.Db.GetRowByNameAndDate(tableName, reportName, dateTime).then((SqlRow d){
			XmlElement types;
			Map<String, String> meta_map = new Map();
			meta_map = d.MDToMap();
			List<int> bytes_buf = ZLibDecoder().decodeBytes(d.CompressXmlData);
			temp_buf = decodeUtf8(bytes_buf);
			temp_buf = XmlSymbReplace(temp_buf);
			XmlDocument xml_document = parse(temp_buf);  // парсим весь документ
			temp_iter = xml_document.findAllElements("Types");
			if(temp_iter.isNotEmpty){
				types = temp_iter.first;        // прототипы с типами данных в полях тегов Iter и Head. Нужны для красивиого отображения в таблице данных
				temp_iter = xml_document.findAllElements("ViewDescription");
				if(temp_iter.isNotEmpty){
					temp_element = temp_iter.first; // ViewDescription
					temp_iter = temp_element.findAllElements('Item'); //все Itemы в ViewDescription
					if(temp_iter.isNotEmpty) {
						temp_iter.forEach((itemXML) {
							entity.Zone = itemXML.findElements('Zone').first.text;
							entity.FieldName = itemXML.findElements('FieldName').first.text;
							entity.ClmnName = itemXML.findElements('Text').first.text;
							entity.Total = int.tryParse(itemXML.findElements('TotalFunc').first.text);
							if(entity.Zone == 'Iter') {
								types.findAllElements('Iter').forEach((i) {
									i.findElements(entity.FieldName).forEach((e) {
										entities.add(DataEtty(entity.Zone, entity.FieldName, entity.ClmnName, entity.Total, e.text, []));
									});
								});
							}
						});
						if(meta_map.containsKey("filename")){
							temp_buf = meta_map["filename"];
							xml_document.findElements(temp_buf.substring(0, temp_buf.length-4)).first.findElements("Iter").forEach((iterElement){  //сами данные в строках
								for(int j = 0; j < entities.length; j++){
									entities[j].Data.add(iterElement.findElements(entities[j].FieldName).first.text);
								}
							});
						}
					}
				}
			}
		});
		return entities;
	}

	FormatData DataCast(List<DataEtty> entities)
	{
		List<String>  tmp_str = [];
		List<TRow> data = [];
		List<DataColumnErik> data_column = [];
		String total_str = '';
		for(int i = 0; i < entities[0].Data.length; i ++){ //строки
			tmp_str.clear();
			tmp_str.add((i+1).toString());
			entities.forEach((entity){
				tmp_str.add(entity.Data[i]);
			});
			data.add(TRow(tmp_str.sublist(0)));
		}
		data_column.add(DataColumnErik(
			label: Expanded(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.spaceEvenly,
					crossAxisAlignment: CrossAxisAlignment.start,
					children: <Widget>[
						Text("№")
					],
				),
			),
			numeric: true,
			onSort: (int columnIndex, bool ascending) => ReportTableSort<num>((TRow d) => int.parse(d.StrItem[0]), columnIndex, ascending)
		));
		for(int i = 0; i < entities.length; i++, total_str = ''){//колонки
			if(entities[i].Total > 0){
				switch(entities[i].Total){
					case C.TOTAL_COUNT:
						{
							total_str = C.s_amount + D.s_colon + entities[i].Data.length.toString();
						}
						break;
					case C.TOTAL_SUM:
						{
							if(entities[i].Type != 'char'){
								double total = 0.0;
								entities[i].Data.forEach((data){
									total += double.parse(data);
								});
								total_str = C.s_sum + D.s_colon + total.toStringAsFixed(2);
							}
						}
						break;
					case C.TOTAL_AVG:
						{
							if(entities[i].Type != 'char'){
								double total = 0.0;
								entities[i].Data.forEach((data){
									total += double.parse(data);
								});
								total = total / entities[i].Data.length;
								total_str = C.s_average+ D.s_colon + total.toStringAsFixed(2);
							}
						}
						break;
					case C.TOTAL_MIN:
						{
							if(entities[i].Type != 'char'){
								double total;
								entities[i].Data.forEach((data){
									if(total == null)
										total =  double.parse(data);
									else
										total = min(total, double.parse(data));
								});
								total_str =  C.s_lowest_val + D.s_colon + total.toStringAsFixed(2);
							}
						}
						break;
					case C.TOTAL_MAX:
						{
							if(entities[i].Type != 'char'){
								double total;
								entities[i].Data.forEach((data){
									if(total == null)
										total =  double.parse(data);
									else
										total = max(total, double.parse(data));
								});
								total_str = C.s_highest_val + D.s_colon + total.toStringAsFixed(2);
							}
						}
						break;
					case C.TOTAL_STDDEV:
						{}
						break;
				}
			}
			data_column.add(DataColumnErik(
				label: Expanded(
				  child: Column(
				  	mainAxisAlignment: MainAxisAlignment.spaceEvenly,
				  	crossAxisAlignment: CrossAxisAlignment.start,
				  	children: [
				  		Text(
				  			entities[i].ClmnName,
				  			style: TextStyle(fontSize: 14.0),
				  		),
				  		Text(total_str,	style: C.ts_TOTAL,)
					]
				  ),
				),
				numeric: (entities[i].Type == "char" ? false : true),
				onSort: (int columnIndex, bool ascending){
					if(entities[i].Type == "double" || entities[i].Type == "int"){
						ReportTableSort<num>((TRow d) => double.tryParse(d.StrItem[i+1]), columnIndex, ascending);
					}
					else if (entities[i].Type == "char"){
						ReportTableSort<String>((TRow d) => d.StrItem[i+1], columnIndex, ascending);
					}
				}
			));
		}
		return FormatData(data_column, data);
	}

	void ReportTableSort<T>(Comparable<T> getField(TRow d), int columnIndex, bool ascending) {
		Source.Sort<T>(getField, ascending);
		SortColumnIndex = columnIndex;
		SortAscending = ascending;
		ReDraw();
	}

	Future<int> GetGlobalAccountList(BuildContext context, String dataDomain)async
	{
		int ok = 0;
		Timer timer;
		var progress_dlg = ProgressDialog(context, type: ProgressDialogType.Normal);
		try{
			mq.RoutingParamEntry rpe = mq.RoutingParamEntry();
			rpe.SetupReserved(mq.VarMQ.rtrsrvRpc, dataDomain, '', 0);
			mq.MessageProperties props = mq.MessageProperties();
			props.replyTo = rpe.RpcReplyQueueName;
			props.timestamp = DateTime.now();
			props.corellationId = rpe.CorrelationId;
			props.priority = 5;
			props.expiration = "11000"; // время жизни сообщения в миллисекундах(11 секунд)
			mq.Exchange exchange_publ = await _ChannelMQ.exchange(rpe.ExchangeName, rpe.ExchangeType);
			mq.Exchange exchange_rpc = await _ChannelMQ.exchange(rpe.RpcReplyExchangeName, rpe.RpcReplyExchangeType);
			mq.Queue queue = await _ChannelMQ.queue(rpe.RpcReplyQueueName, autoDelete: true);
			await queue.bind(exchange_rpc, rpe.RpcReplyRoutingKey);
			mq.Consumer consumer = await queue.consume();
			consumer.listen((message) async{
				List<List> out = [];
				Iterable<XmlElement> xml = parse(message.payloadAsString).findAllElements('Iter');
				xml.forEach((e)async{
					List<String> temp_list = [];
					e.descendants.forEach((node){
						if(node is XmlText && node.text.trim().isNotEmpty)
							temp_list.add(node.text.trim());
					});
					out.add(temp_list);
				});
				await progress_dlg.hide();
				timer?.cancel();
				showDialog(
					context: context,
					builder: (context){
						return SimpleDialog(
							title: new Text(C.s_choiceAcc),
							children: List<Widget>.generate(out.length, (index){
								return SimpleDialogOption(
									child: Text(out[index][C.GGLAindexName]),
									onPressed: (){
										SetAuthName(out[index]);
										ReDraw();
										Navigator.pop(context);
									},
								);
							})
						);
					}
				);
				consumer.cancel();
			});
			progress_dlg.show();
			exchange_publ.publish(C.s_cmdGGAL, rpe.RoutingKey, properties: props);
			Scaffold.of(context).showSnackBar(SnackBar(content: Text(C.s_requestHasBeenSended), backgroundColor: Colors.green, duration: Duration(milliseconds: 500)));
			timer = Timer(Duration(seconds: 10), (){
				consumer.cancel();
				progress_dlg.hide();
				Scaffold.of(context).showSnackBar(SnackBar(content: Text(C.s_errorResponseFromServer), backgroundColor: Colors.red, duration: Duration(seconds: 2)));
			});
			ok = D.OK;
		}catch(e){
			print(e);
			print("Ошибка соединения. не был инициализирован канал связи с RabbitMQ");
		}
		return ok;
	}

	Future<int> LogIn({BuildContext context, File authFile, String password, bool rememberMe})async {
		int ok = D.OK;
		Timer timer;
		String temp_buf;
		if(authFile != null && authFile.existsSync()){
			temp_buf = authFile.readAsStringSync();
			if(temp_buf != null && temp_buf.isNotEmpty){
				print(temp_buf);
				var xml_auth = parse(temp_buf);
				_Auth.Name = xml_auth.findAllElements('Name').first.text;
				_Auth.NameID = int.parse(xml_auth.findAllElements('NameID').first.text);
				_Auth.DomainName = xml_auth.findAllElements('DomainName').first.text;
				_Auth.GUID = xml_auth.findAllElements('GUID').first.text;
				SetAuth(AccessState.auth);
			}
		}		
		else{
			if(password == null || rememberMe == null){
				ok = D.FAIL;
			}
			else{
				var progress_dlg = ProgressDialog(context, type: ProgressDialogType.Normal);
				String login_str = _Auth.Name + ':' + password;
				List<int> login_bin = sha1.convert(utf8.encode(login_str)).bytes;
				login_str = base64.encode(login_bin);
				String cmd_str = C.s_cmdVGA + " " +  _Auth.NameID.toString() + ': ' + login_str;
				mq.RoutingParamEntry rpe = mq.RoutingParamEntry();
				rpe.SetupReserved(mq.VarMQ.rtrsrvRpc, _Auth.DomainName, '', 0);
				mq.MessageProperties props = mq.MessageProperties();
				props.replyTo = rpe.RpcReplyQueueName;
				props.timestamp = DateTime.now();
				props.corellationId = rpe.CorrelationId;
				props.priority = 5;
				props.expiration = "11000"; // время жизни сообщения в миллисекундах(11 секунд)
				try{
					mq.Exchange exchange_rpc = await _ChannelMQ.exchange(rpe.RpcReplyExchangeName, rpe.RpcReplyExchangeType);
					mq.Queue queue = await _ChannelMQ.queue(rpe.RpcReplyQueueName, autoDelete: true);
					await queue.bind(exchange_rpc, rpe.RpcReplyRoutingKey);
					mq.Consumer consumer = await queue.consume();
					consumer.listen((message) async{
						if(message.payloadAsString != null && message.payloadAsString.isNotEmpty && message.payloadAsString != "Error"){
							_Auth.GUID = message.payloadAsString;
							SetAuth(AccessState.auth);
							if(rememberMe){
								String auth_xml = '''<?xml version="1.0"?>
<Auth>
    <Name>${_Auth.Name}</Name>
    <NameID>${_Auth.NameID.toString()}</NameID>
    <DomainName>${_Auth.DomainName}</DomainName>
    <GUID>${_Auth.GUID}</GUID>
    <BdTName>${_Auth.DbTableName}</BdTName>
    $_RowMqsConfigStr
</Auth>''';
								final File file = File("$Dir/${C.s_AUTHFILE}");
								file.writeAsStringSync(auth_xml);
								Scaffold.of(context).showSnackBar(SnackBar(content: Text('Доступ получен'), backgroundColor: Colors.green, duration: Duration(seconds: 2)));
							}
						}
						else{
							if(message.payloadAsString != null && message.payloadAsString.isNotEmpty){
								print(message.payloadAsString);
								Scaffold.of(context).showSnackBar(SnackBar(content: Text(message.payloadAsString), backgroundColor: Colors.red, duration: Duration(seconds: 2)));
							}
							else{
								Scaffold.of(context).showSnackBar(SnackBar(content: Text(C.s_error), backgroundColor: Colors.red, duration: Duration(seconds: 2)));
								print(C.s_error);
							}
						}
						consumer.cancel();
						progress_dlg.hide();
						timer?.cancel();
					});
					mq.Exchange exchange_publ = await _ChannelMQ.exchange(rpe.ExchangeName, rpe.ExchangeType);
					progress_dlg.show();
					exchange_publ.publish(cmd_str, rpe.RoutingKey, properties: props);
					Scaffold.of(context).showSnackBar(SnackBar(content: Text(C.s_requestHasBeenSended), backgroundColor: Colors.green, duration: Duration(milliseconds: 500)));
					timer = Timer(Duration(seconds: 10), (){
						consumer.cancel();
						progress_dlg.hide();
						Scaffold.of(context).showSnackBar(SnackBar(content: Text(C.s_errorResponseFromServer), backgroundColor: Colors.red, duration: Duration(seconds: 2)));
					});
				}catch(e){
					Scaffold.of(context).showSnackBar(SnackBar(content: Text(C.s_rabbitMQConnectionError), backgroundColor: Colors.red, duration: Duration(seconds: 2)));
					print(e);
					print("нет соединения с интернетом");
				}

			}
		}
		return ok;
	}

	void LogOut()async
	{
		_Auth.Z();
		ChoiceList = [];
		ReportWidget = null;
		if(_ConsumerMQ != null)
			_ConsumerMQ.cancel();
		final File file = File("$Dir/${C.s_AUTHFILE}");
		if(file != null && file.existsSync()){
			file.deleteSync();
		}
		ReDraw();
	}


	//new func
	Future<String> UhttRequestSetting()async
	{
		String responsed_setting_in_xml;
		String envelope= '''<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://service.uhtt.ru/">
  <SOAP-ENV:Body>
    <ns1:getCommonMqsConfig/>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
''';
		try{
			http.Response response = await http.post(
				"http://www.uhtt.ru/dispatcher/ws/iface",
				headers: {
					"Host": "www.uhtt.ru",
					"Content-Type": "text/xml; charset=utf-8",
					"SOAPAction": "",
				},
				body: envelope
			);
			responsed_setting_in_xml = response.body;
		}catch(e){
			print(e.toString());
			print("Запрос настроек не выполнен. нет соединения с интернетом");
		}

		return responsed_setting_in_xml;
	}

	int SetSettingFromXml(String settingsInXml) {
		int ok = 1;
		String temp_buf;
		try{
			XmlDocument xml_doc = parse(settingsInXml);
			Iterable<XmlElement> iter = xml_doc.findAllElements('result');
			iter.map((node) => node.text).forEach(((d){temp_buf = d.toString();}));
			encrypt.Encrypted encrypted = encrypt.Encrypted.fromBase64(temp_buf);
			encrypt.Key key = encrypt.Key.fromLength(16);
			key.bytes[2] = 1;
			key.bytes[7] = 17;
			encrypt.Encrypter encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ecb, padding: null));
			String decrypted = encrypter.decrypt(encrypted, iv: encrypt.IV.fromLength(16));
			_RowMqsConfigStr = decrypted.substring(decrypted.indexOf("\n")+1, decrypted.lastIndexOf(">")+1);
			print(_RowMqsConfigStr);
			xml_doc = parse(_RowMqsConfigStr);
			_MQCS.virtualHost = C.s_papyrus;
			_MQCS.host = xml_doc.findAllElements("host").first.text;
			_MQCS.authProvider = mq.PlainAuthenticator(xml_doc.findAllElements("user").first.text, xml_doc.findAllElements("secret").first.text);
		}
		catch(e){
			print(e);
			ok = 0;
		}
		return ok;
	}

	@override void dispose(){
		_ConsumerMQ.cancel();
		_ClientMQ.close();
		super.dispose();
	}

	//ReportTable
	ReportTable ReportWidget;
	int ReportRowsPerPage;
	Widget TableHeader;
	List<DataColumnErik> Columns;
	ReportTableSource  Source;
	int SortColumnIndex;
	bool SortAscending;
	//Drawer
	List<ExpansionListTile> ChoiceList;
	//
	mq.RoutingParamEntry _RoutingParam;
	String _RowMqsConfigStr;
	mq.ConnectionSettings _MQCS;
	mq.Client _ClientMQ;
	mq.Channel _ChannelMQ;
	mq.Consumer _ConsumerMQ;
	AuthEntry _Auth;
	PersonalSetting PersonSetting;
	String Dir;
}
