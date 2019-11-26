import 'dart:io';
import 'dart:async';
import 'package:archive/archive.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:utf/utf.dart';
import 'package:http/http.dart' as http;
import 'package:dart_amqp/dart_amqp.dart' as mq;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:xml/xml.dart';
import 'dart:math';
import 'package:StyloView/WindowsAndWidgets/ExpansionListTile.dart';
import 'package:StyloView/functional/StyloViewLib.dart';
import 'package:StyloView/functional/sqlProvider.dart';
import 'package:StyloView/WindowsAndWidgets/ReportTable.dart';
import 'package:StyloView/functional/SELib.dart';
import 'package:StyloView/functional/SE_AMQP.dart';


class SState{
	SState(this.State, this.StateCode);
	bool State;
	int StateCode;
}

enum AccessState{
	not_auth,
	auth,
}

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

//__________________________GlobalAcc______________________________//
class AuthEntry{
	AuthEntry([this.AuthState = AccessState.not_auth]);
	String get Name => _Name;
	String get BdTName => _DBTName;

	set Name(String name){
		_Name = name;
		_DBTName = name + '_table';
	}

	Z()
	{
		AuthState = AccessState.not_auth;
		GUID = null;
		_Name = null;
		DomainName = null;
		TimeDate = null;
		_DBTName = null;
	}

	AccessState AuthState;
	int NameID;
	DateTime TimeDate;
	String _Name;
	String DomainName;
	String GUID;
	String _DBTName;


}

class FormatData{
	FormatData(this.DC, this.Data);
	List<DataColumn> DC;
	List<TRow> Data;
}

class TRow {// Data class. каждый объект этого класса - это строка в таблице
	TRow(this.StrItem);
	List<String> StrItem;
	bool Selected = false;
}

//Именно в таком виде выводятся строки таблицу PeginatedDataTable. Они все должны быть обебрнуты в этот класс
class ReportTableSource extends DataTableSource {
	ReportTableSource(this._strings, this._numColumns);

	//берем каждый элемент _strings и выводим в наш виджет.
	//причем кол-во выводимых полей в строке всегда равно кол-ву колонок
	@override DataRow getRow(int index)
	{
		//В виде DataCell выводятся данные. Это функция - преобразователь
		List<DataCell> toDataCellList(TRow str, int numColumns){
			List<DataCell> data_cell = [];
			for(int i = 0; i < numColumns; i++){
				data_cell.add(DataCell(Text('${str.StrItem[i]}')));
			}
			return data_cell;
		}
		assert(index >= 0);
		if (index >= _strings.length)
			return null;
		final TRow string = _strings[index];
		return DataRow(
			selected: string.Selected,
			onSelectChanged: (bool value) {
					_selectedCount += value ? 1 : -1;
					string.Selected = value;
					notifyListeners();
			},
			cells: toDataCellList(string, _numColumns));
	}
	@override int  get rowCount => _strings.length;
	@override bool get isRowCountApproximate => false;
	@override int  get selectedRowCount => _selectedCount;

	int _selectedCount = 0;
	List<TRow> _strings;
	final int _numColumns;
}

class AppState extends ChangeNotifier{
	AppState(){
		_auth = AuthEntry();
		_MQCS = mq.ConnectionSettings(host: "");
		getExternalStorageDirectory().then((directory)async{
			C.Dir = directory.path;
			final File file = File("${C.Dir}/${C.s_AUTHFILE}");
			String temp_buf;
			if(file != null && file.existsSync()){
				temp_buf = file.readAsStringSync();
				if(temp_buf != null && temp_buf.isNotEmpty){
					var xml_auth = parse(temp_buf);
					_commonMqsConfigStr = xml_auth.findAllElements("CommonMqsConfig").first.toString();
					XmlDocument doc = parse(_commonMqsConfigStr);
					temp_buf = doc.findAllElements("host").first.text;
					_MQCS.host = temp_buf;
					temp_buf  = doc.findAllElements("user").first.text;
					_MQCS.virtualHost = "papyrus";
					_MQCS.authProvider = mq.PlainAuthenticator(temp_buf, doc.findAllElements("secret").first.text);
				}
			}
			if(_MQCS.host.isEmpty){
				await uhttRequestSetting(); // инициализируем _MQCS (MQconnectionSettings)  если не была запомнена авторизация, то заново запрашиваем данные с сервера
			}
			_clientMQ = mq.Client(settings: _MQCS);
			_clientMQ.channel().then((chnl)async{
				stateCode = D.OK;
				_channelMQ = chnl;
				logIn(authFile: file);
			}, onError: (e){
				stateCode = D.FAIL;
				print(e.toString());
				print("CONNECTION ERROR");
			});
		});
	}

	//Авторизация
	void reDraw(){notifyListeners();}
	AuthEntry get getAuth => _auth;
	void setAuthDomain(String domainName){_auth.DomainName = domainName;}
	void setAuthName(List name)
	{
		_auth.Name    = name[C.GGLAindexName];
		_auth.NameID = int.parse(name[C.GGLAindexID]);
	}
	void setAuthTimeDate(DateTime dt){_auth.TimeDate = dt;}
	void setAuth(AccessState aState)async
	{
		if(aState == AccessState.auth){  // Если авторизация, то...
			//ТУТ РАБОТАЕМ С КРОЛИКОМ
			_auth.AuthState = AccessState.auth;
			RoutingParamEntry rpe = RoutingParamEntry();
			rpe.SetupReserved(VarMQ.rtrsrvStyloView, _auth.DomainName, _auth.GUID, 0);
			mq.Exchange mq_exchange = await _channelMQ.exchange(rpe.ExchangeName, rpe.ExchangeType);
			mq.Queue mq_queue = await _channelMQ.queue(rpe.QueueName);
			await mq_queue.bind(mq_exchange, rpe.RoutingKey);
			await listenReports(mq_queue);
			Timer.periodic(Duration(minutes: 1), (_)async{
				listenReports(mq_queue);
			});
			toDrawer();
		}
	}

	Future listenReports(mq.Queue mqQueue) async
	{
		if(_consumerMQ != null)
			await _consumerMQ.cancel(noWait: false);
		_consumerMQ = await mqQueue.consume();
		_consumerMQ.listen((message){  // тут уже слушаем очередь, в которую сливаются отчеты
			String report_name = message.properties.headers['namedfilt-name'].toString();
			DateTime date_time = message.properties.timestamp;
			Map meta_data = message.properties.headers; // доп. инфа по фильтру
			List<int> xml_data = message.payload.toList();
			SqlData sql_data = SqlData(
				DateTime  : date_time.toString(),
				ReportName: report_name,
				MetaData  : meta_data.toString(),
				CompressXmlData   : xml_data,
				Total     : [0],
				Reserve   : [0],
			);
			if(dataTest(sql_data).State){
				SqlProvider.Db.SetRow(_auth.BdTName, sql_data).then((_){
					toDrawer();
				});
			}
		});
	}

	SState dataTest(SqlData sqlData)
	{
		SState ok;
		String temp_buf;
		Iterable<XmlElement> temp_iter;
		Map<String, String> meta_map = new Map();
		meta_map = sqlData.MDToMap();
		List<int> bytes_buf = ZLibDecoder().decodeBytes(sqlData.CompressXmlData);
		temp_buf = decodeUtf8(bytes_buf);
		temp_buf = XmlSymbReplace(temp_buf);
		XmlDocument xml_document = parse(temp_buf);  // парсим весь документ
		temp_iter = xml_document.findAllElements("Types");
		if(temp_iter.isNotEmpty){
			temp_iter = xml_document.findAllElements("ViewDescription");
			if(temp_iter.isNotEmpty){
				temp_iter = temp_iter.first.findAllElements('Item'); //все Itemы в ViewDescription
				if(temp_iter.isNotEmpty) {
					if(meta_map.containsKey("filename")){
						ok = SState(true, 1); //Все ок
					}
					else ok = SState(false, 5); //ошибка метаданных
				}
				else ok = SState(false, 4); //нет "строк" (Iterов) в файле
			}
			else ok = SState(false, 3);//неопределены поля вывода
		}
		else ok = SState(false, 2);// если нет DTD в файле, и нет типов полей
		return ok;
	}

	void toDrawer(){
		//ТУТ РАБОТАЕМ С SQLite
		SqlProvider.Db.GetReportsTitle(_auth.BdTName, ['report_name', 'date_time']).then((data){
			_choiceList = List<ExpansionListTile>.generate(data.length, (i){
				List dates_list = data[data.keys.toList()[i]].reversed.toList();
				String report_name = data.keys.toList()[i];
				String report_date = dates_list[dates_list.length-1];
				List<DataColumn> columns;
				DataTableSource  source;
				return ExpansionListTile(
					onLongPress: (){
						xmlDataFromSql(_auth.BdTName, report_name, dates_list[dates_list.length-1]).then((entities){
							if(entities != null && entities.isNotEmpty){
								FormatData fd = dataCast(entities);
								columns = fd.DC;
								source =  ReportTableSource(fd.Data, fd.DC.length);
								_reportWidget = ReportTable(source, columns, Text("$report_name от ${report_date.substring(0, 10)}"));
								reDraw();
							}
						});
					},
					title: Text(report_name),
					children: List<Widget>.generate(dates_list.length, (j){
						String report_date = dates_list[j];
						return ListTile(
							title: Text(report_date.substring(0, report_date.length-4)),
							onTap: (){
								xmlDataFromSql(_auth.BdTName, report_name, report_date).then((entities){
									if(entities != null && entities.isNotEmpty){
										FormatData fd = dataCast(entities);
										columns = fd.DC;
										source =  ReportTableSource(fd.Data, fd.DC.length);
										_reportWidget = ReportTable(source, columns, Text("$report_name от ${report_date.substring(0, 10)}"));
										reDraw();
									}
								});
							},
						);
					}),
				);
			});
			reDraw();
		}, onError: (e){
			print(e);
		});
	}

	Future<List<DataEtty>> xmlDataFromSql(String tableName, String reportName, String dateTime)async{
		String temp_buf;
		Iterable<XmlElement> temp_iter;
		XmlElement temp_element;
		DataEtty entity = DataEtty('', '', '', 0, '', []);
		List<DataEtty>  entities = [];
		await SqlProvider.Db.GetRowByNameAndDate(tableName, reportName, dateTime).then((SqlData d){
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

	FormatData dataCast(List<DataEtty> entities)
	{
		List<String>  tmp_str = [];
		List<TRow> data = [];
		List<DataColumn> data_column = [];
		String total_str = '';
		for(int i = 0; i < entities[0].Data.length; i ++){ //строки
			tmp_str.clear();
			entities.forEach((entity){
				tmp_str.add(entity.Data[i]);
			});
			data.add(TRow(tmp_str.sublist(0)));
		}
		for(int i = 0; i < entities.length; i++, total_str = ''){
			if(entities[i].Total > 0){
				switch(entities[i].Total){
					case C.TOTAL_COUNT:
						{
							total_str = "\n" + C.s_amount + D.s_colon + entities[i].Data.length.toString();
						}
						break;
					case C.TOTAL_SUM:
						{
							if(entities[i].Type != 'char'){
								double total = 0.0;
								entities[i].Data.forEach((data){
									total += double.parse(data);
								});
								total_str = "\n" + C.s_sum + D.s_colon + total.toStringAsFixed(2);
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
								total_str = "\n" + C.s_average+ D.s_colon + total.toStringAsFixed(2);
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
								total_str =  "\n" + C.s_lowest_val + D.s_colon + total.toStringAsFixed(2);
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
								total_str = "\n" + C.s_highest_val + D.s_colon + total.toStringAsFixed(2);
							}
						}
						break;
					case C.TOTAL_STDDEV:
						{}
						break;
				}
			}
			data_column.add(DataColumn(
				label: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: <Widget>[
						Text(
							entities[i].ClmnName,
							style: TextStyle(fontSize: 14.0),
						),
						Text(total_str,	style: C.ts_TOTAL,)
					],
				),
				numeric: (entities[i].Type == "char" ? false : true),
			));
		}
		return FormatData(data_column, data);
	}

	Future<int> getGlobalAccountList(BuildContext context, String dataDomain)async
	{
		int ok = 0;
		Timer timer;
		var progress_dlg = ProgressDialog(context, type: ProgressDialogType.Normal);
		progress_dlg.show();
		RoutingParamEntry rpe = RoutingParamEntry();
		rpe.SetupReserved(VarMQ.rtrsrvRpc, dataDomain, '', 0);
		mq.MessageProperties props = mq.MessageProperties();
		props.replyTo = rpe.RpcReplyQueueName;
		props.timestamp = DateTime.now();
		props.corellationId = rpe.CorrelationId;
		props.priority = 5;
		props.expiration = "11000"; // время жизни сообщения в миллисекундах(11 секунд)
		mq.Exchange exchange_publ = await _channelMQ.exchange(rpe.ExchangeName, rpe.ExchangeType);
		mq.Exchange exchange_rpc = await _channelMQ.exchange(rpe.RpcReplyExchangeName, rpe.RpcReplyExchangeType);
		mq.Queue queue = await _channelMQ.queue(rpe.RpcReplyQueueName, autoDelete: true);
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
									setAuthName(out[index]);
									reDraw();
									Navigator.pop(context);
								},
							);
						})
					);
				}
			);
			consumer.cancel();
		});
		exchange_publ.publish(C.s_cmdGGAL, rpe.RoutingKey, properties: props);
		Scaffold.of(context).showSnackBar(SnackBar(content: Text("Запрос отправлен"), backgroundColor: Colors.green, duration: Duration(milliseconds: 500)));
		timer = Timer(Duration(seconds: 10), (){
			consumer.cancel();
			progress_dlg.hide();
			Scaffold.of(context).showSnackBar(SnackBar(content: Text("Ошибка! Нет ответа от сервера."), backgroundColor: Colors.red, duration: Duration(seconds: 2)));
		});
		ok = D.OK;
		return ok;
	}

	Future<int> logIn({BuildContext context, File authFile, String password, bool rememberMe})async {
		int ok = D.OK;
		Timer timer;
		String temp_buf;
		if(authFile != null && authFile.existsSync()){
			temp_buf = authFile.readAsStringSync();
			if(temp_buf != null && temp_buf.isNotEmpty){
				print(temp_buf);
				var xml_auth = parse(temp_buf);
				_auth.Name = xml_auth.findAllElements('Name').first.text;
				_auth.NameID = int.parse(xml_auth.findAllElements('NameID').first.text);
				_auth.DomainName = xml_auth.findAllElements('DomainName').first.text;
				_auth.GUID = xml_auth.findAllElements('GUID').first.text;
				setAuth(AccessState.auth);
			}
		}		
		else{
			if(password == null || rememberMe == null){
				ok = D.FAIL;
			}
			else{
				var progress_dlg = ProgressDialog(context, type: ProgressDialogType.Normal);
				progress_dlg.show();
				String login_str = _auth.Name + ':' + password;
				List<int> login_bin = sha1.convert(utf8.encode(login_str)).bytes;
				login_str = base64.encode(login_bin);
				String cmd_str = C.s_cmdVGA + " " +  _auth.NameID.toString() + ': ' + login_str;
				RoutingParamEntry rpe = RoutingParamEntry();
				rpe.SetupReserved(VarMQ.rtrsrvRpc, _auth.DomainName, '', 0);
				mq.MessageProperties props = mq.MessageProperties();
				props.replyTo = rpe.RpcReplyQueueName;
				props.timestamp = DateTime.now();
				props.corellationId = rpe.CorrelationId;
				props.priority = 5;
				props.expiration = "11000"; // время жизни сообщения в миллисекундах(11 секунд)
				mq.Exchange exchange_rpc = await _channelMQ.exchange(rpe.RpcReplyExchangeName, rpe.RpcReplyExchangeType);
				mq.Queue queue = await _channelMQ.queue(rpe.RpcReplyQueueName, autoDelete: true);
				await queue.bind(exchange_rpc, rpe.RpcReplyRoutingKey);
				mq.Consumer consumer = await queue.consume();
				consumer.listen((message) async{
					if(message.payloadAsString != null && message.payloadAsString.isNotEmpty && message.payloadAsString != "Error"){
						_auth.GUID = message.payloadAsString;
						setAuth(AccessState.auth);
						if(rememberMe){
							String auth_xml = '''<?xml version="1.0"?>
<Auth>
    <Name>${_auth.Name}</Name>
    <NameID>${_auth.NameID.toString()}</NameID>
    <DomainName>${_auth.DomainName}</DomainName>
    <GUID>${_auth.GUID}</GUID>
    <BdTName>${_auth.BdTName}</BdTName>
    $_commonMqsConfigStr
</Auth>''';
							final File file = File("${C.Dir}/${C.s_AUTHFILE}");
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
							Scaffold.of(context).showSnackBar(SnackBar(content: Text("Error!!!"), backgroundColor: Colors.red, duration: Duration(seconds: 2)));
							print("Error!!!");
						}
					}
					consumer.cancel();
					progress_dlg.hide();
					timer?.cancel();
				});
				mq.Exchange exchange_publ = await _channelMQ.exchange(rpe.ExchangeName, rpe.ExchangeType);
				exchange_publ.publish(cmd_str, rpe.RoutingKey, properties: props);
				Scaffold.of(context).showSnackBar(SnackBar(content: Text("Запрос отправлен"), backgroundColor: Colors.green, duration: Duration(milliseconds: 500)));
				timer = Timer(Duration(seconds: 10), (){
					consumer.cancel();
					progress_dlg.hide();
					Scaffold.of(context).showSnackBar(SnackBar(content: Text("Ошибка! Нет ответа от сервера."), backgroundColor: Colors.red, duration: Duration(seconds: 2)));
				});
			}
		}
		return ok;
	}

	void logOut()async
	{
		_auth.Z();
		_choiceList = [];
		_reportWidget = null;
		if(_consumerMQ != null)
			_consumerMQ.cancel();
		final File file = File("${C.Dir}/${C.s_AUTHFILE}");
		if(file != null && file.existsSync()){
			file.deleteSync();
		}
		reDraw();
	}


	//new func
	Future<int> uhttRequestSetting()async
	{
		String envelope= '''<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://service.uhtt.ru/">
  <SOAP-ENV:Body>
    <ns1:getCommonMqsConfig/>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
''';
		await http.post(
			"http://www.uhtt.ru/dispatcher/ws/iface",
			headers: {
				"Host": "www.uhtt.ru",
				"Content-Type": "text/xml; charset=utf-8",
				"SOAPAction": "",
			},
			body: envelope
		).then((http.Response response){
			String temp_buf;
			XmlDocument doc = parse(response.body);
			Iterable<XmlElement> iter = doc.findAllElements('result');
			iter.map((node) => node.text).forEach(((d){temp_buf = d.toString();}));
			encrypt.Encrypted encrypted = encrypt.Encrypted.fromBase64(temp_buf);
			encrypt.Key key = encrypt.Key.fromLength(16);
			key.bytes[2] = 1;
			key.bytes[7] = 17;
			encrypt.Encrypter encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ecb, padding: null));
			String decrypted = encrypter.decrypt(encrypted, iv: encrypt.IV.fromLength(16));
			_commonMqsConfigStr = decrypted.substring(decrypted.indexOf("\n")+1, decrypted.lastIndexOf(">")+1);
			print(_commonMqsConfigStr);
			doc = parse(_commonMqsConfigStr);
			temp_buf = doc.findAllElements("host").first.text;
			_MQCS.host = temp_buf;
			temp_buf  = doc.findAllElements("user").first.text;
			_MQCS.virtualHost = "papyrus";
			_MQCS.authProvider = mq.PlainAuthenticator(temp_buf, doc.findAllElements("secret").first.text);
		});
		return 0;
	}

	void dispose(){
		_consumerMQ.cancel();
		_clientMQ.close();
	}

	int stateCode;
	ReportTable _reportWidget;
	ReportTable get ReportWidget => _reportWidget;
	List<ExpansionListTile> _choiceList;
	List<ExpansionListTile> get choiceList => _choiceList;
	String _commonMqsConfigStr;
	mq.ConnectionSettings _MQCS;
	mq.Client _clientMQ;
	mq.Channel _channelMQ;
	//RabbitMQ object for get reports
	mq.Consumer _consumerMQ;
	AuthEntry _auth;
}
