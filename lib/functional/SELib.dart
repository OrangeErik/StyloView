//Sobolev Erik's Dart and Flutter library  change 13.09.2019
import 'dart:core';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

/*
descr:
Эти флаги ОБЯЗАТЕЛЬНЫ. Все целочисленные значения не имеют флагов типа
fn_ - double
s_  - String
c_  - Color
ts_ - TextStyle
 */
//int THROW(var anything, String ErrMsg){
//	if(anything != null && anything != 0){
//		return D.OK;
//	}
//	else{
//		print(ErrMsg);
//		return D.NULLFAIL;
//	}
//}
abstract class D {
	/* Common */
	static const int OK = 1;
	static const int FAIL = 0;
//	static const int NULLFAIL = null;
	static const int E_CRITICAL = -1;
	static const int ON = 1;
	static const int OFF = 0;
	// -------------------------------------------------------------------------
	static const int BYTE = 1;
	static const int KB = 1024*BYTE;
	static const int MB = 1024*KB;
	static const int GB = 1024*MB;
	static const int TB = 1024*GB;
	// -------------------------------------------------------------------------
	static const int MILLISECOND = 1;
	static const int SECOND = 1000*MILLISECOND;
	static const int MINUTE = 60*SECOND;
	static const int HOUR = 60*MINUTE;
	static const int DAY = 24*HOUR;
	static const int WEEK = 7*DAY;

	/* File formats */
	static const int Unkn             =  0;
	static const int Txt              =  1;
	static const int Jpeg             =  2;
	static const int Png              =  3;
	static const int Tiff             =  4;
	static const int Gif              =  5;
	static const int Bmp              =  6;
	static const int Ico              =  7;
	static const int Cur              =  8;
	static const int Svg              =  9;
	static const int Html             = 10;  //
	static const int Xml              = 11;  //
	static const int Ini              = 12;  //
	static const int TxtBomUTF8       = 13;  // Текстовый файл с сигнатурой типа кодировка (BOM)
	static const int TxtBomUTF16BE    = 14;  // Текстовый файл с сигнатурой типа кодировка (BOM)
	static const int TxtBomUTF16LE    = 15;  // Текстовый файл с сигнатурой типа кодировка (BOM)
	static const int TxtBomUTF32BE    = 16;  // Текстовый файл с сигнатурой типа кодировка (BOM)
	static const int TxtBomUTF32LE    = 17;  // Текстовый файл с сигнатурой типа кодировка (BOM)
	static const int TxtBomUTF7       = 18;  // Текстовый файл с сигнатурой типа кодировка (BOM)
	static const int TxtBomUTF1       = 19;  // Текстовый файл с сигнатурой типа кодировка (BOM)
	static const int TxtBomUTF_EBCDIC = 20;  // Текстовый файл с сигнатурой типа кодировка (BOM)
	static const int TxtBomSCSU       = 21;  // Текстовый файл с сигнатурой типа кодировка (BOM)
	static const int TxtBomBOCU1      = 22;  // Текстовый файл с сигнатурой типа кодировка (BOM)
	static const int TxtBomGB18030    = 23;  // Текстовый файл с сигнатурой типа кодировка (BOM)
	static const int Latex            = 24;  // LATEX
	static const int Pdf              = 25;
	static const int Rtf              = 26;
	static const int Mdb              = 27;
	static const int AccDb            = 28;  // Access
	static const int WbXml            = 29;  // Binary XML
	static const int Wmf              = 30;
	static const int Eps              = 31;
	static const int Hlp              = 32;
	static const int Ppd              = 33;  // PostScript
	static const int PList            = 34;  // Property List
	static const int Mat              = 35;  // Matlab
	static const int Pdb              = 36;
	static const int WcbffOld         = 37;  // Windows Compound Binary File Format
	static const int Zip              = 38;  // @v9.0.0 Archive
	static const int Rar              = 39;  // @v9.0.0 Archive
	static const int Gz               = 40;  // @v9.0.0 Archive
	static const int Tar              = 41;  // @v9.0.0 Archive
	static const int Bz2              = 42;  // @v9.0.0 Archive
	static const int SevenZ           = 43;  // @v9.0.0 Archive
	static const int Xz               = 44;  // @v9.0.0 Archive
	static const int Z                = 45;  // @v9.0.0 Archive
	static const int Cab              = 46;  // @v9.0.0 Archive
	static const int Arj              = 47;  // @v9.0.0 Archive
	static const int Lzh              = 48;  // @v9.0.0 Archive
	static const int Xar              = 49;  // @v9.0.0 Archive
	static const int Pmd              = 50;  // @v9.0.0 Archive
	static const int Deb              = 51;  // @v9.0.0 Archive
	static const int Rpm              = 52;  // @v9.0.0 Archive
	static const int Chm              = 53;  // @v9.0.0 Archive
	static const int Iso              = 54;  // @v9.0.0 Archive
	static const int Vhd              = 55;  // @v9.0.0 Archive
	static const int Wim              = 56;  // @v9.0.0 Archive
	static const int Mdf              = 57;  // @v9.0.0 Archive
	static const int Nri              = 58;  // @v9.0.0 Archive
	static const int Swf              = 59;  // @v9.0.0 Archive
	static const int Mar              = 60;  // @v9.0.0 Archive
	static const int Mkv              = 61;  // @v9.0.9 Video
	static const int Avi              = 62;  // @v9.0.9 Video
	static const int Mp4              = 63;  // @v9.0.9 Video
	static const int Wmv              = 64;  // @v9.0.9 Video
	static const int Mpg              = 65;  // @v9.0.9 Video
	static const int Flv              = 66;  // @v9.0.9 Video
	static const int Mov              = 67;  // @v9.0.9 Video
	static const int F4f              = 68;  // @v9.0.9 Video
	static const int Class            = 69;  // @v9.0.9 binary:class 0:CAFEBABE
	static const int Exe              = 70;  // @v9.0.9 binary:exe   0:4D5A
	static const int Dll              = 71;  // @v9.0.9 binary:dll   0:4D5A
	static const int Pcap             = 72;  // @v9.0.9 binary:pcap  0:D4C3B2A1
	static const int Pyo              = 73;  // @v9.0.9 binary:pyo   0:03F30D0A
	static const int So               = 74;  // @v9.0.9 binary:so    0:7F454C46
	static const int Mo               = 75;  // @v9.0.9 binary:mo    0:DE120495
	static const int Mui              = 76;  // @v9.0.9 binary:mui   0:50413330
	static const int Cat              = 77;  // @v9.0.9 binary:cat   0:30 6:2A864886
	static const int Xsb              = 78;  // @v9.0.9 binary:xsb   0:DA7ABABE
	static const int Key              = 79;  // @v9.0.9 binary:key   0:4B4C737727
	static const int Sq3              = 80;  // @v9.0.9 binary:sq3   0:53514C697465
	static const int Qst              = 81;  // @v9.0.9 binary:qst   0:0401C4030000 binary:qst   0:040180040000
	static const int Crx              = 82;  // @v9.0.9 binary:crx   0:43723234
	static const int Utx              = 83;  // @v9.0.9 binary:utx   0:4C0069006E006500610067006500
	static const int Rx3              = 84;  // @v9.0.9 binary:rx3   0:52583362
	static const int Kdc              = 85;  // @v9.0.9 binary:kdc   0:44494646
	static const int Xnb              = 86;  // @v9.0.9 binary:xnb   0:584E42
	static const int Blp              = 87;  // @v9.0.9 binary:blp   0:424C5031 binary:blp   0:424C5032
	static const int Big              = 88;  // @v9.0.9 binary:big   0:42494746
	static const int Mdl              = 89;  // @v9.0.9 binary:mdl   0:49445354
	static const int Spr              = 90;  // @v9.0.9 binary:spr   0:CDCC8C3F
	static const int Sfo              = 91;  // @v9.0.9 binary:sfo   0:00505346
	static const int Mpq              = 92;  // @v9.0.9 binary:mpq   0:4D50511A
	static const int Nes              = 93;  // @v9.0.9 binary:nes   0:4E45531A
	static const int Dmp              = 94;  // @v9.0.9 binary:dmp   0:4D444D5093A7
	static const int Dex              = 95;  // @v9.0.9 binary:dex   0:6465780a30333500 binary:dex   0:6465780a30333600
	static const int Gim              = 96;  // @v9.0.9 binary:gim   0:4D49472E30302E31505350
	static const int Amxx             = 97;  // @v9.0.9 binary:amxx  0:58584D41
	static const int Sln              = 98;  // Visual Studio Solution
	static const int VCProj           = 99;  // Visual Studio Project
	static const int Asm              = 100; // Assempbler source file
	static const int C                = 101; // C source file
	static const int CPP              = 102; // CPP source file
	static const int H                = 103; // C header file
	static const int Perl             = 104; // perl source code
	static const int Php              = 105; // php source code
	static const int Java             = 106; // java source code
	static const int Py               = 107; // Python source code
	static const int UnixShell        = 108; // Unix Shell script
	static const int Msi              = 109; // Microsoft Installer package
	static const int TxtUtf8          = 110; // @v9.3.6 Текст в формате utf8
	static const int TxtAscii         = 111; // @v9.3.6 Текст в котором только ASCII-символы
	static const int Log              = 112; // @v9.7.1 Файл журнала (by ext only)
	static const int Properties       = 113; // @v9.7.1 Файл properties. Обычно текстовый файл аналогичный ini, но без зональности ([]).
	static const int Css              = 114; // @v9.7.1 CSS
	static const int JavaScript       = 115; // @v9.7.1 JS
	static const int Json             = 116; // @v9.7.2
	static const int Pbxproj          = 117; // @v9.8.1 Файл проекта xcode
	static const int PapyruDbDivXchg  = 118; // @v9.8.11 Приватный формат проекта Papyrus: файл обмена данными между разделами
	static const int FirstUser        = 10000;

	static const String s_colon = ":";
}


//__WIDGETS__//
class UniCont extends StatelessWidget {
	UniCont({this.child, this.BGColor});
	final Widget child;
	final Color BGColor;
	@override
	Widget build(BuildContext context) {
		return Container(
			decoration: BoxDecoration( // если есть декоратор, то все красота наводится внутри него2
				color: BGColor ?? Colors.white,
				borderRadius: BorderRadius.circular(10.0)
			),
			margin: EdgeInsets.all(5.0),
			child: child,
		);
	}
}

class MyInputField extends StatelessWidget {
	MyInputField({@required this.label, @required this.callback});
	final String label;
	final  String Function(String) callback;

	@override
	Widget build(BuildContext context) {
		return Padding( //ввод имени
			padding: const EdgeInsets.all(8.0),
			child: TextFormField(
				decoration:  InputDecoration(
					labelText: label,
					border   : OutlineInputBorder(
						gapPadding  : 3.3,
						borderRadius: BorderRadius.circular(3.3)
					)
				),
				validator: callback,
			),
		);
	}
}

void goToPage(BuildContext context, Widget goTo){
	Navigator.push(context, MaterialPageRoute(builder: (context) => goTo));
}



String CreateEnvelope(String command,{Map<String, String> params})
{
	String envelope;
	String  temp_buf = "";
	if(params != null){
		params.forEach((key, value){
			temp_buf += "<$key>$value<\/$key>";
		});
		envelope = '''<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://service.uhtt.ru/">
  <SOAP-ENV:Body>
    <ns1:$command>
      $temp_buf
    </ns1:$command>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
''';
	}
	else{
		envelope = '''<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://service.uhtt.ru/">
  <SOAP-ENV:Body>
    <ns1:$command/>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
''';
	}
	return envelope;
}

Future<int> UhttRequest(String host, String url, String command, Function callback(http.Response response),{Map<String, String> params})async
{
	String temp_buf;
	String envelope;
	if(params != null){
		params.forEach((key, value){
			temp_buf += "<$key>$value<\/$key>";
		});
		envelope = '''<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://service.uhtt.ru/">
  <SOAP-ENV:Body>
    <ns1:$command>
      $temp_buf
    </ns1:$command>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
''';
	}
	else{
		envelope = '''<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://service.uhtt.ru/">
  <SOAP-ENV:Body>
    <ns1:$command/>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
''';
	}
	await http.post(
		url,
		headers: {
			"Host": host,
			"Content-Type": "text/xml; charset=utf-8",
			"SOAPAction": "",
		},
		body: envelope
	).then(callback);
	return 0;
}

Function callbackGetCFG = (http.Response response){
	String temp_buf;
	xml.XmlDocument doc = xml.parse(response.body);
	Iterable<xml.XmlElement> iter = doc.findAllElements('result');
	iter.map((node) => node.text).forEach(((d){temp_buf = d.toString();}));
	enc.Encrypted encrypted = enc.Encrypted.fromBase64(temp_buf);
	enc.Key key = enc.Key.fromLength(16);
	key.bytes[2] = 1;
	key.bytes[7] = 17;
	enc.Encrypter encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.ecb, padding: null));
	String decrypted = encrypter.decrypt(encrypted, iv: enc.IV.fromLength(16));
	print(decrypted);
};

String XmlSymbReplace(String str){
	Map<String, String> symbs = {".":"&dot;", ",":"&comma;", "/":"&fwsl;"};
	symbs.forEach((key, val){
		str = str.replaceAll(val, key);
	});
	return str;
}