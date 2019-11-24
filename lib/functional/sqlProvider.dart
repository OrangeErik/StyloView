import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:StyloView/functional/StyloViewLib.dart';

class SqlData {// Структура данных, с коротой работает класс SqlProvider.
	int Id = 0;
	final String ReportName;
	final String MetaData;
	final String DateTime;
	final List<int> CompressXmlData;
	final List<int> Total;
	final List<int> Reserve;

	SqlData({this.Id, this.ReportName, this.MetaData, this.DateTime, this.CompressXmlData, this.Total, this.Reserve});
	Map<String, dynamic> toMap()
	{
		return {
			'id'       : Id,
			'report_name': ReportName,
			'meta_data'  : MetaData,
			'date_time': DateTime,
			'xml_data' : CompressXmlData,
			'total'    : Total,
			'reserve'  : Reserve
		};
	}
	String toString()
	{
		return '{id: $Id,' +
			' report_name: $ReportName,' +
			' meta_data: $MetaData,' +
			' date_time: $DateTime,' +
			' xml_data: $CompressXmlData,' +
			' total: $Total,' +
			' reserve: $Reserve}';
	}
	factory SqlData.fromMap(Map<String, dynamic> data) => SqlData(
		Id        : data['id'],
		ReportName: data['report_name'],
		MetaData  : data['meta_data'],
		DateTime  : data['date_time'],
		CompressXmlData   : data['xml_data'],
		Total     : data['total'],
		Reserve   : data['reserve']
	);

	Map MDToMap(){
		Map<String, String> meta_map = new Map();
		MetaData.substring(1, MetaData.length-1).split(", ").forEach((String metaItem){
			List elem = metaItem.split(": ");
			meta_map[elem[0]] = elem[1];
		});
		return meta_map;
	}
}

class SqlProvider{
	SqlProvider._();
	static final SqlProvider Db = SqlProvider._();
	Database _DB;  //объект для работы с базой данных, с которым мы работаем в классе.
	Future<Database> get GetDb async {
		if (_DB == null)
			_DB = await OpenDB();
		return _DB;
	}

	Future OpenDB()async
	{
		String path = join(C.Dir, C.s_BDNAME); //'data_base_ppy.db'
		return await openDatabase(path);
	}

	Future DeleteDB()async
	{
		String path = join(C.Dir, C.s_BDNAME);
		return await deleteDatabase(path);
	}

	Future DeleteTable(String tableName)async
	{
		final db = await GetDb;
		db.transaction((trn)async{
			await trn.execute('DROP TABLE IF EXISTS $tableName');
		});
	}

	Future<int>SetRow(String tableName, SqlData sd) async
	{
		int raw;
		final db = await GetDb;
		await db.transaction((trx)async{
			await trx.execute('CREATE TABLE IF NOT EXISTS $tableName (id INTEGER PRIMARY KEY, report_name TEXT, meta_data TEXT, date_time TEXT, xml_data BLOB, reserve BLOB, total BLOB)').then((_)async{
				raw = await trx.rawInsert(
					'INSERT Into $tableName (report_name, meta_data, date_time, xml_data, total, reserve) VALUES (?,?,?,?,?,?)',
					[sd.ReportName, sd.MetaData, sd.DateTime, sd.CompressXmlData, sd.Total, sd.Reserve]
				);
			});
		});
		return raw;
	}

	Future<SqlData> GetRow(String tableName, int id) async
	{
		final db = await GetDb;
		SqlData sql_data;
		List<Map<String, dynamic>> res;
		await db.transaction((trx)async{
			await trx.execute('CREATE TABLE IF NOT EXISTS $tableName (id INTEGER PRIMARY KEY, report_name TEXT, meta_data TEXT, date_time TEXT, xml_data BLOB, reserve BLOB, total BLOB)').then((_)async{
				res = await trx.query(tableName, where: 'id = ?', whereArgs: [id]);
			});
		});
		if(res.isNotEmpty)
			sql_data =  SqlData.fromMap(res.first);
		return sql_data;
	}

	Future<SqlData> GetRowByNameAndDate(String tableName, String name, String date_time) async
	{
		final db = await GetDb;
		SqlData sql_data;
		List<Map<String, dynamic>> res;
		await db.transaction((trx)async{
			await trx.execute('CREATE TABLE IF NOT EXISTS $tableName (id INTEGER PRIMARY KEY, report_name TEXT, meta_data TEXT, date_time TEXT, xml_data BLOB, reserve BLOB, total BLOB)').then((_)async{
				res = await trx.query(tableName, where: 'report_name = ? AND date_time = ?', whereArgs: [name, date_time]);
			});
		});
		if(res.isNotEmpty)
			sql_data =  SqlData.fromMap(res.first);
		return sql_data;
	}

	Future<List<SqlData>> GetTable(String tableName) async
	{
		final Database db = await GetDb;  // Get a reference to the database.
		List<Map<String, dynamic>> maps;
		await db.transaction((trx)async{
			await trx.execute('CREATE TABLE IF NOT EXISTS $tableName (id INTEGER PRIMARY KEY, report_name TEXT, meta_data TEXT, date_time TEXT, xml_data BLOB, reserve BLOB, total BLOB)').then((_)async{
				maps = await trx.query(tableName);
			});
			// Query the table for all The SqlData.
		});
		return List.generate(maps.length, (i) {  // Convert the List<Map<String, dynamic> into a List<SqlData>.
			return SqlData(
				Id        : maps[i]['id'],
				ReportName: maps[i]['report_name'],
				MetaData  : maps[i]['meta_data'],
				DateTime  : maps[i]['date_time'],
				CompressXmlData   : maps[i]['xml_data'],
				Total     : maps[i]['total'],
				Reserve   : maps[i]['reserve']
			);
		});
	}

	Future DeleteRow(String tableName, int id) async
	{  //Remove the XMLFile from the database.
		final db = await GetDb;//Get a reference to the database.    // Use a `where` clause to delete a specific XMLFile.
		await db.delete(tableName, where: 'id = ?', whereArgs: [id],); // Pass the XMLFile's id as a whereArg to prevent SQL injection.
	}

	Future ClearTable(String tableName) async
	{
		final db = await GetDb;
		db.transaction((trx)=>trx.rawDelete('DELETE * FROM $tableName'));
	}

	Future<Map<String, List<String>>> GetReportsTitle(String tableName, List<String> clmnsNames)async
	{
		Map<String, List<String>> result = Map();
		List<Map<String, dynamic>> out_list = [];
		final db = await GetDb;
		await db.transaction((trx)async{
			await trx.execute('CREATE TABLE IF NOT EXISTS $tableName (id INTEGER PRIMARY KEY, report_name TEXT, meta_data TEXT, date_time TEXT, xml_data BLOB, reserve BLOB, total BLOB)').then((_)async{
				await trx.rawQuery('SELECT DISTINCT ${clmnsNames.join(', ')} FROM $tableName').then((List response){
					out_list = response;
				});
			});
		});
		for(int i=0; i < out_list.length; i++){
			if(! result.containsKey(out_list[i]['report_name'])){
				result[out_list[i]['report_name']] = [out_list[i]['date_time']];
			}
			else{
				result[out_list[i]['report_name']].add(out_list[i]['date_time']);
			}
		}
		return result;
	}
}