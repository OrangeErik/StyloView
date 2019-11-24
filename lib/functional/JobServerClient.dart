// JOBSERVERCLIENT.DART
// Copyright (c) E.Sobolev, 2019
// @codepage UTF-8
//
import 'dart:typed_data';
import 'dart:convert' as convert;
import 'dart:io';
import 'package:StyloView/functional/SELib.dart';

abstract class Defs {
	/* Flags */
	static final int FLG_TRFFTA = 0x0001;

	/* Errors */
	static final int NO_ERROR = 0;
	static final int ERROR_OK = NO_ERROR;
	static final int ERR_UNKNOWN = 1001;
	static final int ERR_INTERNAL = 1002;
	static final int ERR_INCORRECT_REQUEST = 1003;
	static final int ERR_NO_FREE_SESSIONS = 1004;
	static final int ERR_INVARGVALUE = 1005;
	static final int ERR_INVUSERORPWD = 1006;
	static final int ERR_INVEMAIL = 1007;
	static final int ERR_INVAUTHTOKEN = 1008;
	static final int ERR_OBJECT_NOT_INIT = 1009;
	static final int ERR_OBJECT_NOT_FOUND = 1010;
	static final int ERR_OBJECT_ALREADY_EXIST = 1011;
	static final int ERR_UNKNOWN_OBJECT_TYPE = 1012;
	static final int ERR_INVALID_IDENTIFIER = 1013;
	static final int ERR_NO_RESOURCE = 1014;
	static final int ERR_INVALID_TEMPLATE = 1015;
	static final int ERR_INVALID_BASE64 = 1016;
	static final int ERR_BASE64_ENCODE_FAILED = 1017;
	static final int ERR_BASE64_DECODE_FAILED = 1018;
	static final int ERR_UNKNOWN_FILE_TYPE = 1019;
	static final int ERR_NO_DATA = 1020;
	static final int ERR_CONTENT_TYPE_NOT_SPECIFIED = 1021;
	static final int ERR_ENCODING_NOT_SPECIFIED = 1022;
	static final int ERR_FILE_NAME_NOT_SPECIFIED = 1023;
	static final int ERR_FILE_SIZE_NOT_SPECIFIED = 1024;
	static final int ERR_EXCEED_MAX_FILE_SIZE = 1025;
	static final int ERR_INVALID_BUFFER_SIZE = 1026;
	static final int ERR_PERIOD_NOT_SPECIFIED = 1027;
	static final int ERR_JSRV_ADDR_NOT_SPECIFIED = 1028;
	static final int ERR_JSRV_DBSYMB_NOT_SPECIFIED = 1029;
	static final int ERR_JSRV_USERNAME_NOT_SPECIFIED = 1030;
	static final int ERR_PERSON_KIND_NOT_FOUND = 1031;
	static final int ERR_PERSON_CREATION_FAILED = 1032;
	static final int ERR_GUA_CREATION_FAILED = 1033;
	static final int ERR_NO_AUTH_TOKEN = 1034;
	static final int ERR_OBJ_CREATION_FAILED = 1035;
	static final int ERR_EMAIL_NOT_SPECIFIED = 1036;
	static final int ERR_PWD_NOT_SPECIFIED = 1037;
	static final int ERR_GOODS_NAME_NOT_SPECIFIED = 1038;
	static final int ERR_BARCODE_NOT_SPECIFIED = 1039;
	static final int ERR_UNIT_NOT_SPECIFIED = 1040;
	static final int ERR_PHUNIT_NOT_SPECIFIED = 1041;
	static final int ERR_PHUPERU_RATIO_NOT_SPECIFIED = 1042;
	static final int ERR_INCORRECT_GOODS_ID = 1043;
	static final int ERR_INCORRECT_BARCODE = 1044;
	static final int ERR_INCORRECT_PARENT_ID = 1045;
	static final int ERR_INCORRECT_BRAND_ID = 1046;
	static final int ERR_INCORRECT_UNIT_ID = 1047;
	static final int ERR_INCORRECT_PHUNIT_ID = 1048;
	static final int ERR_INCORRECT_PHUPERU_RATIO = 1049;
	static final int ERR_GGROUP_NOT_FOUND = 1050;
	static final int ERR_BRAND_NOT_FOUND = 1051;
	static final int ERR_UNIT_NOT_FOUND = 1052;
	static final int ERR_PHUNIT_NOT_FOUND = 1053;
	static final int ERR_PERSON_NAME_NOT_SPECIFIED = 1054;
	static final int ERR_PERSON_KIND_NOT_SPECIFIED = 1055;
	static final int ERR_INN_NOT_SPECIFIED = 1056;
	static final int ERR_ADDRESS_NOT_SPECIFIED = 1057;
	static final int ERR_ADDRESS_CODE_NOT_SPECIFIED = 1058;
	static final int ERR_CITY_ID_NOT_SPECIFIED = 1059;
	static final int ERR_INCORRECT_CITY_ID = 1060;
	static final int ERR_INCORRECT_PERSON_ID = 1061;
	static final int ERR_INCORRECT_PERSON_STATUS_ID = 1062;
	static final int ERR_INCORRECT_PERSON_CATEGORY_ID = 1063;
	static final int ERR_INCORRECT_PERSON_KIND_ID = 1064;
	static final int ERR_INCORRECT_INN = 1065;
	static final int ERR_INCORRECT_REG_TYPE_ID = 1066;
	static final int ERR_INCORRECT_LOCATION_ID = 1067;
	static final int ERR_INCORRECT_LOCATION_KIND = 1068;
	static final int ERR_PERSON_NOT_FOUND = 1069;
	static final int ERR_REGISTER_TYPE_NOT_FOUND = 1070;
	static final int ERR_LOCATION_NOT_FOUND = 1071;
	static final int ERR_CITY_NOT_FOUND = 1072;
	static final int ERR_INCORRECT_CONTENT_TYPE = 1073;
	static final int ERR_INCORRECT_ENCODING = 1074;
	static final int ERR_SPCSRS_SERIAL_NOT_SPECIFIED = 1075;
	static final int ERR_SPCSRS_INFO_IDENT_NOT_SPECIFIED = 1076;
	static final int ERR_SPCSRS_INFO_DATE_NOT_SPECIFIED = 1077;
	static final int ERR_INCORRECT_MANUFACTOR_ID = 1078;
	static final int ERR_MANUFACTOR_NOT_FOUND = 1079;
	static final int ERR_SPCSRS_INCORRECT_INFO_KIND = 1080;
	static final int ERR_INCORRECT_DATE_FORMAT = 1081;
	static final int ERR_INCORRECT_QUOTE_KIND_ID = 1082;
	static final int ERR_INCORRECT_SELLER_ID = 1083;
	static final int ERR_INCORRECT_WAREHOUSE_ID = 1084;
	static final int ERR_INCORRECT_BUYER_ID = 1085;
	static final int ERR_INCORRECT_CURRENCY_ID = 1086;
	static final int ERR_INCORRECT_QUOTE_MIN_QTTY = 1087;
	static final int ERR_INCORRECT_QUOTE_ACTUAL_PERIOD = 1088;
	static final int ERR_INCORRECT_QUOTE_VALUE = 1089;
	static final int ERR_QUOTE_KIND_NOT_FOUND = 1090;
	static final int ERR_GOODS_NOT_FOUND = 1091;
	static final int ERR_SELLER_NOT_FOUND = 1092;
	static final int ERR_WAREHOUSE_NOT_FOUND = 1093;
	static final int ERR_BUYER_NOT_FOUND = 1094;
	static final int ERR_CURRENCY_NOT_FOUND = 1095;
	static final int ERR_INCORRECT_AMOUNT = 1096;
	static final int ERR_SCARD_NUMBER_NOT_SPECIFIED = 1097;
	static final int ERR_LOCATION_SYMBOL_NOT_SPECIFIED = 1098;
	static final int ERR_CURRENCY_NAME_NOT_SPECIFIED = 1099;
	static final int ERR_CURRENCY_SYMB_NOT_SPECIFIED = 1100;
	static final int ERR_INCORRECT_CURRENCY_DIGITCODE = 1101;
	static final int ERR_INVOPSYMB = 1102;
	static final int ERR_INVLOCID = 1103;
	static final int ERR_INVARID = 1104;
	static final int ERR_INVAGENTID = 1105;
	static final int ERR_INVDLVRLOCID = 1106;
	static final int ERR_INCORRECT_WORKBOOK_ID = 1107;
	static final int ERR_WORKBOOK_CODE_NOT_SPECIFIED = 1108;
	static final int ERR_STYLODEVICENAME_NOT_SPECIFIED = 1109;
	static final int ERR_MAGICSYMB_NOT_SPECIFIED = 1110;
	static final int ERR_INCORRECT_DATETIME_FORMAT = 1111;
	static final int ERR_TSESSCODE_NOT_SPECIFIED = 1112;
	static final int ERR_TSESSPRC_NOT_SPECIFIED = 1113;
	static final int ERR_TSESSSTTIME_NOT_SPECIFIED = 1114;
	static final int ERR_TSESS_CREATION_INPUT = 1115;
	static final int ERR_PROCESSORNAME_NOT_SPECIFIED = 1116;
	static final int ERR_PROCESSORSYMB_NOT_SPECIFIED = 1117;
	static final int ERR_INVARGUUID = 1118;
	static final int ERR_INVARGPRCID = 1119;
	static final int ERR_TSESSF_SINCE_INPUT = 1120;
	static final int ERR_TSESSCIPOP_INVOP = 1121; // @v8.8.2
	static final int ERR_TSESSCIPOP_INVSESID = 1122; // @v8.8.2

	static final int E_VALIDATION_FAILED = 2001;
	static final int E_DATA_RECV_FAILED = 2002;
	static final int E_OBJECT_CREAT_FAILED = 2003;

	/* Messages */
	static final int MSG_JOBSERVER_CONNECT_FAILED = 10001;
	static final int MSG_JOBSERVER_HSH_FAILED = 10002;
	static final int MSG_JOBSERVER_LOGIN_FAILED = 10003;
	static final int MSG_WRONG_EMAIL_OR_PWD = 10004;
	static final int MSG_GOODS_BARCODE_SUBSTR_LENGTH = 10005;
	static final int MSG_TMPL_GOODS_ID_CREATED_SUCCESFUL = 10006;
	static final int MSG_TMPL_PERSON_ID_CREATED_SUCCESFUL = 10007;

	/* Commands */
	static final int JSRVCMD_HELLO = 1001;
	static final int JSRVCMD_HSH = 1002;
	static final int JSRVCMD_GETLASTERR = 1003;
	static final int JSRVCMD_QUIT = 1004;
	static final int JSRVCMD_LOGIN = 1005;
	static final int JSRVCMD_LOGOUT = 1006;
	static final int JSRVCMD_EXPTARIFFTA = 1007;
	static final int JSRVCMD_GETTDDO = 1008;
	static final int JSRVCMD_SELECT = 1009;
	static final int JSRVCMD_SET = 1010;
	static final int JSRVCMD_SETGLOBALUSER = 1011;
	static final int JSRVCMD_GETIMAGE = 1012;
	static final int JSRVCMD_CCHECKCREATE = 1013;
	static final int JSRVCMD_SCARDWITHDRAW = 1014;
	static final int JSRVCMD_SCARDREST = 1015;
	static final int JSRVCMD_SENDSMS = 1016;
	static final int JSRVCMD_BILLCREATE = 1017;
	static final int JSRVCMD_BILLADDLINE = 1018;
	static final int JSRVCMD_BILLFINISH = 1019;
	static final int JSRVCMD_DRAFTTRANSITGOODSREST = 1020;
	static final int JSRVCMD_DRAFTTRANSITGOODSRESTLIST = 1021;
	static final int JSRVCMD_SETPERSONREL = 1022;
	static final int JSRVCMD_GETPERSONREL = 1023;
	static final int JSRVCMD_SETOBJECTTAG = 1024;
	static final int JSRVCMD_INCOBJECTTAG = 1025;
	static final int JSRVCMD_DECOBJECTTAG = 1026;
	static final int JSRVCMD_GETOBJECTTAG = 1027;
	static final int JSRVCMD_GETWORKBOOKCONTENT = 1028;

	/* Object types */
	static final int OBJ_UNIT = 5;
	static final int OBJ_PERSONKIND = 8;
	static final int OBJ_PERSONSTATUS = 9;
	static final int OBJ_OPRKIND = 12;
	static final int OBJ_CURRENCY = 34;
	static final int OBJ_CURRATETYPE = 35;
	static final int OBJ_STYLOPALM = 43;
	static final int OBJ_PERSONCATEGORY = 50;
	static final int OBJ_GLOBALUSER = 61;
	static final int OBJ_UHTTSTORE = 70;
	static final int OBJ_WORKBOOK = 72;
	static final int OBJ_PERSON = 1004;
	static final int OBJ_ARTICLE = 1006;
	static final int OBJ_GOODSGROUP = 1008;
	static final int OBJ_GOODS = 1009;
	static final int OBJ_LOCATION = 1010;
	static final int OBJ_BILL = 1011;
	static final int OBJ_SCARD = 1031;
	static final int OBJ_CCHECK = 1032;
	static final int OBJ_BRAND = 1034;
	static final int OBJ_PROCESSOR = 1037;
	static final int OBJ_TSESSION = 1039;
	static final int OBJ_WORLD = 1043;
	static final int OBJ_DL600DATA = 1049;
	static final int OBJ_QUOT = 1051;
	static final int OBJ_GOODSARCODE = 1052;
	static final int OBJ_SPECSERIES = 1058;
	static final int OBJ_GTA = 1060;
	static final int OBJ_CURRATEIDENT = 1061;

	/* Tag type ID */
	static final int OTTYP_BOOL = 1;
	static final int OTTYP_STRING = 2;
	static final int OTTYP_NUMBER = 3;
	static final int OTTYP_ENUM = 4;
	static final int OTTYP_INT = 5;
	static final int OTTYP_OBJLINK = 6;
	static final int OTTYP_DATE = 7;
	static final int OTTYP_GUID = 8;
	static final int OTTYP_IMAGE = 9;
	static final int OTTYP_TIMESTAMP = 10;

	// -------------------------------------------------------------------------
	static final String UHTT_EMAIL_ADM_ADDRESS = "admin@uhtt.ru";
	static final String UHTT_EMAIL_ADM_PASSWORD = "15EUaeCHhgli";
	static final String UHTT_WEBID = "uhtt.ru";

	/* Properties file name */
	static final String UHTT_PROPERTIES_FILE_NAME = "uhtt.properties";

	/* Preferences */
	static final String PREFS_JOBSRV_DEFAULT_ADDR = "localhost";
	static final String PREFS_JOBSRV_DEFAULT_PORT = "28015";
	static final String PREFS_JOBSRV_DEFAULT_DBSYMB = "uhtt";
	static final String PREFS_JOBSRV_DEFAULT_USERNAME = "master";
	static final String PREFS_JOBSRV_DEFAULT_PASSWORD = "";

	/* UHTT Global Account ID */
	static final int UHTT_GLOBAL_ACCOUNT_ID = 1;

	/* Accounts */
	static final String UHTTACCT_KIND_SYMB = "UHTTACCT";
	static final String UHTTACCT_KIND_NAME = "Universe-HTT Account";
	static final String UHTTACCT_SCARDSERIES_SYMB = "GlobalAccount";

	static final String UHTT_PSNREL_MASTER_SYMB = "UHTT_PSNREL_MASTER";

	/* Currency */
	static final String CBR_CUR_RATE_URL = "http://www.cbr.ru/scripts/XML_daily.asp";

	static final String UHTT_CURRATE_CBR_SYMB = "UHTT_CBR_CR";
	static final String UHTT_CURRATE_CBR_NAME = "Курс ЦБ РФ (Universe-HTT)";

	// -------------------------------------------------------------------------
	static final String UHTT_BASECUR_SYMB = "RUB";
	static final String UHTT_BASECUR_NAME = "Российский рубль";
	static final int UHTT_BASECUR_DIGITCODE = 810;

	/* Resources */
	static final String STRING_POOL_FILE_NAME = "uhtt.strings";
	static final String DL_IMAGES_FOLDER_NAME = "Images";

	/* Log */
	static final String STD_LOG_DELIMITER = "\t";

	/* PERSON */
	// -------------------------------------------------------------------------
	static final int UHTT_PERSON_LOC_KIND_LEGAL = 1;
	static final int UHTT_PERSON_LOC_KIND_RESIDANCE_PLACE = 2;
	static final int UHTT_PERSON_LOC_KIND_DELIVERY_ADDRESS = 3;

	// -------------------------------------------------------------------------
	static final int UHTT_PERSON_REG_TYPE_INN = 3;

	/* QUOTE */
	// -------------------------------------------------------------------------
	static final String UHTTQUOTE_CODE = "UHTTQUOT";

	/* TAG */
	// -------------------------------------------------------------------------
	static final String UHTT_TAG_LIKE_COUNT = "LIKECOUNT";
	static final String UHTT_TAG_DISLIKE_COUNT = "DISLIKECOUNT";
}

class HighHeader {
	static final int ZERO_SIZE = 2;
	static final int SIZE = 16; // Размер заголовка
	int Zero;
	int ProtocolVer;
	int DataLenWithHdr;
	int Type;
	int Flags;
	HighHeader({Zero = 0, Protocolver = 0, DataLenWithHdr = 0, Type = 0, Flags = 0});
}

class JobServerFrame {
	JobServerFrame() {
		_header = HighHeader();
		DataLen = 0;
//		_DataType = STRING_DATA;
		_Data = [];
	}

	static final int BINARY_DATA = 1;
	static final int STRING_DATA = 2;
	var _header; // Заголовок
	List _Data; // Данные
	int DataLen;
//	int _DataType;

	void unpack(Int8List buf) {
		_header.Zero = ((buf[0] & 0xff) |
		((buf[1] & 0xff) << 8)).toInt();
		_header.ProtocolVer = ((buf[2] & 0xff) |
		((buf[3] & 0xff) << 8)).toInt();
		_header.DataLenWithHdr = (buf[4] & 0xff) |
		((buf[5] & 0xff) << 8) |
		((buf[6] & 0xff) << 16) |
		((buf[7] & 0xff) << 24);
		_header.Type = (buf[8] & 0xff) |
		((buf[9] & 0xff) << 8) |
		((buf[10] & 0xff) << 16) |
		((buf[11] & 0xff) << 24);
		_header.Flags = (buf[12] & 0xff) |
		((buf[13] & 0xff) << 8) |
		((buf[14] & 0xff) << 16) |
		((buf[15] & 0xff) << 24);
		DataLen = _header.DataLenWithHdr - HighHeader.SIZE;
//		_DataType = BINARY_DATA;
	}

	List pack() {
		List buf = List(
			HighHeader.SIZE + ((_Data == null) ? 0 : _Data.length));
		/* header.Zero */
		buf[0] = _header.Zero.toInt();
		buf[1] = (_header.Zero >> 8).toInt();
		/* header.ProtocolVer */
		buf[2] = _header.ProtocolVer.toInt();
		buf[3] = (_header.ProtocolVer >> 8).toInt();
		/* header.DataLenWithHdr */
		buf[4] = _header.DataLenWithHdr.toInt();
		buf[5] = (_header.DataLenWithHdr >> 8).toInt();
		buf[6] = (_header.DataLenWithHdr >> 16).toInt();
		buf[7] = (_header.DataLenWithHdr >> 24).toInt();
		/* header.Type */
		buf[8] = _header.Type.toInt();
		buf[9] = (_header.Type >> 8).toInt();
		buf[10] = (_header.Type >> 16).toInt();
		buf[11] = (_header.Type >> 24).toInt();
		/* header.Flags */
		buf[12] = _header.Flags.toInt();
		buf[13] = (_header.Flags >> 8).toInt();
		buf[14] = (_header.Flags >> 16).toInt();
		buf[15] = (_header.Flags >> 24).toInt();
		if(_Data != null) {
			List.copyRange(
				_Data, 0, buf, HighHeader.SIZE, _Data.length);
		}
		return buf;
	}

	String getData() {
		convert.Utf8Decoder codec;
		String buf = "";
		if(_Data != null) {
			buf = codec.convert(_Data);
		}
		else {
			buf = "";
		}
		return buf.trim();
	}

	List getRawData() {
		return _Data;
	}
}

class LowHeader {
	LowHeader() {  //конструктор
		cookie = 0;
		crtTime = 0;
		accsTime = 0;
		modTime = 0;
		size = 0;
		format = 0;
		flags = 0;
		partSize = 0;
		hash = Int8List(32);
		transmType = 0;
		reserve = 0;
		objType = 0;
		objID = 0;
		reserve2 = Int8List(32);
		name = '';
	}

	static int SIZE = 368; // Размер заголовка
	int      cookie; // @anchor Идентификатор, необходимый для продолжения скачивания файла.
	int      crtTime; // Время создания файла
	int      accsTime; // Время последнего доступа к файлу
	int      modTime; // Время последней модификации файла
	int      size; // Полный размер файла
	int      format; // SFileFormat::XXX
	int      flags; // @flags @reserve
	int      partSize; // Размер части файла, передаваемой данным пакетом
	Int8List hash; // Hash-функция полного файла (возможно, пустая).
	int      transmType; // Тип передачи
	int      reserve; // @reserve
	int      objType; // Тип объекта
	int      objID; // Идентификатор объекта
	Int8List reserve2; // @reserve
	String   name; // Наименование файла (без пути - только имя с расширением)
}

class JobServerFileTransFrame {
	JobServerFileTransFrame();

	LowHeader _header = LowHeader(); // Заголовок
	Int8List _data; // Данные

	void unpack(Int8List buf) {
		_header.cookie = (buf[0] & 0xff) |
		((buf[1] & 0xff) << 8) |
		((buf[2] & 0xff) << 16) |
		((buf[3] & 0xff) << 24);
		_header.crtTime = (buf[4] & 0xff) |
		((buf[5] & 0xff) << 8) |
		((buf[6] & 0xff) << 16) |
		((buf[7] & 0xff) << 24) |
		((buf[8] & 0xff) << 32) |
		((buf[9] & 0xff) << 40) |
		((buf[10] & 0xff) << 48) |
		((buf[11] & 0xff) << 56);
		_header.accsTime = (buf[12] & 0xff) |
		((buf[13] & 0xff) << 8) |
		((buf[14] & 0xff) << 16) |
		((buf[15] & 0xff) << 24) |
		((buf[16] & 0xff) << 32) |
		((buf[17] & 0xff) << 40) |
		((buf[18] & 0xff) << 48) |
		((buf[19] & 0xff) << 56);
		_header.modTime = (buf[20] & 0xff) |
		((buf[21] & 0xff) << 8) |
		((buf[22] & 0xff) << 16) |
		((buf[23] & 0xff) << 24) |
		((buf[24] & 0xff) << 32) |
		((buf[25] & 0xff) << 40) |
		((buf[26] & 0xff) << 48) |
		((buf[27] & 0xff) << 56);
		_header.size = (buf[28] & 0xff) |
		((buf[29] & 0xff) << 8) |
		((buf[30] & 0xff) << 16) |
		((buf[31] & 0xff) << 24) |
		((buf[32] & 0xff) << 32) |
		((buf[33] & 0xff) << 40) |
		((buf[34] & 0xff) << 48) |
		((buf[35] & 0xff) << 56);
		_header.format = (buf[36] & 0xff) |
		((buf[37] & 0xff) << 8) |
		((buf[38] & 0xff) << 16) |
		((buf[39] & 0xff) << 24);
		_header.flags = (buf[40] & 0xff) |
		((buf[41] & 0xff) << 8) |
		((buf[42] & 0xff) << 16) |
		((buf[43] & 0xff) << 24);
		_header.partSize = (buf[44] & 0xff) |
		((buf[45] & 0xff) << 8) |
		((buf[46] & 0xff) << 16) |
		((buf[47] & 0xff) << 24);
		List.copyRange(buf, 48, _header.hash, 0, 32);
		_header.transmType = ((buf[80] & 0xff) |
		((buf[81] & 0xff) << 8)).toInt();
		_header.reserve = ((buf[82] & 0xff) |
		((buf[83] & 0xff) << 8)).toInt();
		_header.objType = (buf[84] & 0xff) |
		((buf[85] & 0xff) << 8) |
		((buf[86] & 0xff) << 16) |
		((buf[87] & 0xff) << 24);
		_header.objID = (buf[88] & 0xff) |
		((buf[89] & 0xff) << 8) |
		((buf[90] & 0xff) << 16) |
		((buf[91] & 0xff) << 24);
		List.copyRange(buf, 92, _header.reserve2, 0, 20);
		Int8List fn = Int8List(256);
		List.copyRange(buf, 112, fn, 0, 256);
		_header.name = fn.toString().trim();
		List data = List(buf.length - LowHeader.SIZE);
		List.copyRange(
			buf, LowHeader.SIZE, data, 0, data.length);
	}

	List pack() {
		List buf = List(LowHeader.SIZE +
			((_data == null) ? 0 : _data.length));
		/* header.Cookie */
		buf[0] = _header.cookie.toInt();
		buf[1] = (_header.cookie >> 8).toInt();
		buf[2] = (_header.cookie >> 16).toInt();
		buf[3] = (_header.cookie >> 24).toInt();
		/* header.CrtTime */
		buf[4] = _header.crtTime.toInt();
		buf[5] = (_header.crtTime >> 8).toInt();
		buf[6] = (_header.crtTime >> 16).toInt();
		buf[7] = (_header.crtTime >> 24).toInt();
		buf[8] = (_header.crtTime >> 32).toInt();
		buf[9] = (_header.crtTime >> 40).toInt();
		buf[10] = (_header.crtTime >> 48).toInt();
		buf[11] = (_header.crtTime >> 56).toInt();
		/* header.AccsTime */
		buf[12] = _header.accsTime.toInt();
		buf[13] = (_header.accsTime >> 8).toInt();
		buf[14] = (_header.accsTime >> 16).toInt();
		buf[15] = (_header.accsTime >> 24).toInt();
		buf[16] = (_header.accsTime >> 32).toInt();
		buf[17] = (_header.accsTime >> 40).toInt();
		buf[18] = (_header.accsTime >> 48).toInt();
		buf[19] = (_header.accsTime >> 56).toInt();
		/* header.ModTime */
		buf[20] = _header.modTime.toInt();
		buf[21] = (_header.modTime >> 8).toInt();
		buf[22] = (_header.modTime >> 16).toInt();
		buf[23] = (_header.modTime >> 24).toInt();
		buf[24] = (_header.modTime >> 32).toInt();
		buf[25] = (_header.modTime >> 40).toInt();
		buf[26] = (_header.modTime >> 48).toInt();
		buf[27] = (_header.modTime >> 56).toInt();
		/* header.Size */
		buf[28] = _header.size.toInt();
		buf[29] = (_header.size >> 8).toInt();
		buf[30] = (_header.size >> 16).toInt();
		buf[31] = (_header.size >> 24).toInt();
		buf[32] = (_header.size >> 32).toInt();
		buf[33] = (_header.size >> 40).toInt();
		buf[34] = (_header.size >> 48).toInt();
		buf[35] = (_header.size >> 56).toInt();
		/* header.Format */
		buf[36] = _header.format.toInt();
		buf[37] = (_header.format >> 8).toInt();
		buf[38] = (_header.format >> 16).toInt();
		buf[39] = (_header.format >> 24).toInt();
		/* header.Flags */
		buf[40] = _header.flags.toInt();
		buf[41] = (_header.flags >> 8).toInt();
		buf[42] = (_header.flags >> 16).toInt();
		buf[43] = (_header.flags >> 24).toInt();
		/* header.PartSize */
		buf[44] = _header.partSize.toInt();
		buf[45] = (_header.partSize >> 8).toInt();
		buf[46] = (_header.partSize >> 16).toInt();
		buf[47] = (_header.partSize >> 24).toInt();
		/* header.Hash */
		List.copyRange(_header.hash, 0, buf, 48, 32);
		/* header.TransmType */
		buf[80] = _header.transmType.toInt();
		buf[81] = (_header.transmType >> 8).toInt();
		/* header.Reserve */
		buf[82] = _header.reserve.toInt();
		buf[83] = (_header.reserve >> 8).toInt();
		/* header.ObjType */
		buf[84] = _header.objType.toInt();
		buf[85] = (_header.objType>> 8).toInt();
		buf[86] = (_header.objType >> 16).toInt();
		buf[87] = (_header.objType >> 24).toInt();
		/* header.ObjID */
		buf[88] = _header.objID.toInt();
		buf[89] = (_header.objID >> 8).toInt();
		buf[90] = (_header.objID >> 16).toInt();
		buf[91] = (_header.objID >> 24).toInt();
		/* header.Reserve2 */
		List.copyRange(_header.reserve2, 0, buf, 92, 20);
		/* header.Name */
		if(_header.name != null && _header.name.isNotEmpty) {
			var codec = convert.Utf8Encoder();
			List fn = List(256);
			List.copyRange(codec.convert(_header.name), 0, fn, 0, _header.name.length);
			List.copyRange(fn, 0, buf, 112, 256);
		}
		if(_data != null)
			List.copyRange(_data, 0, buf, LowHeader.SIZE, _data.length);
		return buf;
	}
}

class JobServerClient {
	JobServerClient();   //конструктор
	JobServerClient.connect(String ip_addr, int port) {  //именованный конструктор
		connect(ip_addr, port);
	}
	Socket    _socket;
	bool      _flgConnected = false;
	List<int> _bufData = [];
	JobServerFrame          _reply = JobServerFrame();
	JobServerFileTransFrame _datJob = JobServerFileTransFrame();
	String     _VarOut = '';                                //VariableOutput запоняется исключительно в одном месте,
	                                                        //  и только если было прянято много инф-ии в виде байт.
	                                                        //  Как раз из нее мы и будем получать все данные
	//
	// "создание Сокета" и прослушка сигналов от сервера
	//
	int connect(String ip_addr, int port) {

		int ok = D.OK;
		if(_flgConnected)
			disconnect();
		Socket.connect(ip_addr, (port > 0) ? port : 28015).then((Socket sock) {
			_socket = sock;
			listenStreams(sock);
			_flgConnected = true;
		});
		return ok;
	}
	//
	// прослушка потоков Сокета
	//
	void listenStreams(Socket sock) {
		_socket.listen(dataHandler, onError: errorHandler, cancelOnError: false);
	}

	void errorHandler(error, StackTrace trace) {
		print(error);
		_flgConnected = false;
	}

	void dataHandler(List<int> data){
		if((data[0] == 0) && (data[1] == 0)) { // binary data
			_bufData.clear();
			Int8List headerFirstBin = Int8List.fromList(data.getRange(0, 16).toList());
			Int8List headerSecondBin = Int8List.fromList(data.getRange(16, 384).toList());
			_reply.unpack(headerFirstBin);
			_datJob.unpack(headerSecondBin);
			//в идеале надо заполнять и _datJob.Data, но нет необходимости
		}
		else
			print(data);
		_bufData.addAll(data);
		if(_reply.DataLen > 0 && _bufData.length >= _reply._header.DataLenWithHdr) {
			List<int> tmpList = List.from(_bufData.getRange(384, _bufData.length)); //чистые данные файла без headerОВ
			_VarOut = convert.utf8.decode(tmpList).trim(); // декодируем инф-ию из байт в utf-8
		}
	}
	//
	//отправка запроса серверу в виде строковой команды
	//
	int sendRequest(String request){
		int ok = D.OK;
		try{
		_socket.write(request);
		}catch(e){
			print(e);
			ok = D.FAIL;
		}
		return ok;
	}
	//
	//получение ответа от сервера
	//
	String takeResponse(){
		String out = _VarOut;
		return out;
	}

	int disconnect() {
		int ok = D.OK;
		if(_flgConnected) {
			_bufData.clear();
			_socket.destroy();
			print("connected is break");
			_flgConnected = false;
		}
		return ok;
	}
	//
	//проверка, установлено ли соединение
	//
	bool isConnected() {
		return _flgConnected;
	}
}
