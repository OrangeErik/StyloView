import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:StyloView/functional/StyloViewLib.dart';

class SqlRow {// Структура данных, с коротой работает класс SqlProvider.
	int Id = 0;
	final String ReportName;
	final String MetaData;
	final String DateTime;
	final List<int> CompressXmlData;
	final List<int> Total;
	final List<int> Reserve;

	SqlRow({this.Id, this.ReportName, this.MetaData, this.DateTime, this.CompressXmlData, this.Total, this.Reserve});
	Map<String, dynamic> toMap()
	{
		return {
			C.DB_ROW_FIELD_ID         : Id,
			C.DB_ROW_FIELD_REPORTNAME : ReportName,
			C.DB_ROW_FIELD_METADATA   : MetaData,
			C.DB_ROW_FIELD_DATETIME   : DateTime,
			C.DB_ROW_FIELD_XMLDATA    : CompressXmlData,
			C.DB_ROW_FIELD_TOTAL      : Total,
			C.DB_ROW_FIELD_RESERVE    : Reserve
		};
	}
	String toString()
	{
		return '{${C.DB_ROW_FIELD_ID}: $Id,' +
			' ${C.DB_ROW_FIELD_REPORTNAME}: $ReportName,' +
			' ${C.DB_ROW_FIELD_METADATA}: $MetaData,' +
			' ${C.DB_ROW_FIELD_DATETIME}: $DateTime,' +
			' ${C.DB_ROW_FIELD_XMLDATA}: $CompressXmlData,' +
			' ${C.DB_ROW_FIELD_TOTAL}: $Total,' +
			' ${C.DB_ROW_FIELD_RESERVE}: $Reserve}';
	}
	factory SqlRow.fromMap(Map<String, dynamic> data) => SqlRow(
		Id        : data[C.DB_ROW_FIELD_ID],
		ReportName: data[C.DB_ROW_FIELD_REPORTNAME],
		MetaData  : data[C.DB_ROW_FIELD_METADATA],
		DateTime  : data[C.DB_ROW_FIELD_DATETIME],
		CompressXmlData : data[C.DB_ROW_FIELD_XMLDATA],
		Total     : data[C.DB_ROW_FIELD_TOTAL],
		Reserve   : data[C.DB_ROW_FIELD_RESERVE]
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

	Future<int>SetRow(String tableName, SqlRow sqlRow) async
	{
		int raw;
		final db = await GetDb;
		await db.transaction((trx)async{
			await trx.execute(ExecuteString(tableName)).then((_)async{
				raw = await trx.rawInsert(
					'INSERT Into $tableName (${C.DB_ROW_FIELD_REPORTNAME}, ${C.DB_ROW_FIELD_METADATA}, ${C.DB_ROW_FIELD_DATETIME}, ${C.DB_ROW_FIELD_XMLDATA}, ${C.DB_ROW_FIELD_TOTAL}, ${C.DB_ROW_FIELD_RESERVE}) VALUES (?,?,?,?,?,?)',
					[sqlRow.ReportName, sqlRow.MetaData, sqlRow.DateTime, sqlRow.CompressXmlData, sqlRow.Total, sqlRow.Reserve]
				);
			});
		});
		return raw;
	}

	Future<SqlRow> GetRow(String tableName, int id) async
	{
		final db = await GetDb;
		SqlRow sql_data;
		List<Map<String, dynamic>> res;
		await db.transaction((trx)async{
			await trx.execute(ExecuteString(tableName)).then((_)async{
				res = await trx.query(tableName, where: 'id = ?', whereArgs: [id]);
			});
		});
		if(res.isNotEmpty)
			sql_data =  SqlRow.fromMap(res.first);
		return sql_data;
	}

	Future<SqlRow> GetRowByNameAndDate(String tableName, String name, String dateTime) async
	{
		final db = await GetDb;
		SqlRow sql_data;
		List<Map<String, dynamic>> res;
		await db.transaction((trx)async{
			await trx.execute(ExecuteString(tableName)).then((_)async{
				res = await trx.query(tableName, where: 'report_name = ? AND date_time = ?', whereArgs: [name, dateTime]);
			});
		});
		if(res.isNotEmpty)
			sql_data =  SqlRow.fromMap(res.first);
		return sql_data;
	}

	Future<List<SqlRow>> GetTable(String tableName) async
	{
		final Database db = await GetDb;  // Get a reference to the database.
		List<Map<String, dynamic>> maps;
		await db.transaction((trx)async{
			await trx.execute(ExecuteString(tableName)).then((_)async{
				maps = await trx.query(tableName);
			});
			// Query the table for all The SqlData.
		});
		return List.generate(maps.length, (i) {  // Convert the List<Map<String, dynamic> into a List<SqlData>.
			return SqlRow(
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

	Future DeleteRow(String tableName, int rowID) async
	{
		final db = await GetDb;//Get a reference to the database.    // Use a `where` clause to delete a specific XMLFile.
		await db.delete(tableName, where: 'id = ?', whereArgs: [rowID],); // Pass the XMLFile's id as a whereArg to prevent SQL injection.
	}

	Future ClearTable(String tableName) async
	{
		final db = await GetDb;
		db.transaction((trx)=>trx.rawDelete('DELETE * FROM $tableName'));
	}

	Future<List<Map<String, dynamic>>> GetColumns(String tableName, List<String> columnsNames)async
	{
		List<Map<String, dynamic>> out_list = [];
		final db = await GetDb;
		await db.transaction((trx)async{
			await trx.execute(ExecuteString(tableName)).then((_)async{
				await trx.rawQuery('SELECT DISTINCT ${columnsNames.join(', ')} FROM $tableName').then((List response){
					out_list = response;
				});
			});
		});
		return out_list;
	}

	String ExecuteString(String tableName) {
		return 'CREATE TABLE IF NOT EXISTS $tableName (${C.DB_ROW_FIELD_ID} INTEGER PRIMARY KEY, ${C.DB_ROW_FIELD_REPORTNAME} TEXT, ${C.DB_ROW_FIELD_METADATA} TEXT, ${C.DB_ROW_FIELD_DATETIME} TEXT, ${C.DB_ROW_FIELD_XMLDATA} BLOB, ${C.DB_ROW_FIELD_RESERVE} BLOB, ${C.DB_ROW_FIELD_TOTAL} BLOB)';
	}
}