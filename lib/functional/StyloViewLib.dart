import 'package:flutter/material.dart';

/*
descr:
Эти префиксы ОБЯЗАТЕЛЬНЫ. Все целочисленные значения не имеют префикса типа
fn_ - double
s_  - String
c_  - Color
ts_ - TextStyle

Контекстные префиксы
DS_ - defaultSetting
 */

abstract class C {
	static const String s_papyrus = "papyrus";
	static const String s_enterYourDomain = "Введите ваш домен";
	static const String s_enterYourLogin = "Введите ваш логин";
	static const String s_enterYourPass  = "Введите ваш пароль";
	static const String s_choiceAcc = "Выберите учетную запись";
	static const String s_reportSetting = "Настройка отчетов";
	static const String s_loginRequest = "Запрос авторизации";
	static const String s_setting = "Настройки";
	static const String s_signout = "Выход";
	static const String s_signin  = "Вход";
	static const String s_cancel  = "Отмена";
	static const String s_domain  = "Домен";
	static const String s_reset   = "Сбросить";
	static const String s_login   = "Логин";
	static const String s_accs    = "Учетные записи";
	static const String s_auth    = "Авторизация";
	static const String s_pass    = "Пароль";
	static const String s_integer = "Целое число";
	static const String s_rememberMe = "Запомнить меня";
	static const String s_apply = "Применить";
	static const String s_resetSetting = "Сброс настроек";
	static const String s_styloview = "StyloView";
	static const String s_amount = "Количество";
	static const String s_sum = "Сумма";
	static const String s_average  = "Среднее";
	static const String s_lowest_val = "Наименьшее";
	static const String s_highest_val = "Наибольшее";
	static const String s_storageReportsDuration = "Длительность хранения отчета";
	static const String s_storageReportsCount = "Количество хранимых версий отчетов";
	static const String s_requestHasBeenSended = "Запрос отправлен";
	static const String s_errorResponseFromServer = "Ошибка! Нет ответа от сервера.";
	static const String s_rabbitMQConnectionError = "Ошибка подключения. Скорее всего траблы с интернетом";
	static const String s_coution_reset_storage_report_setting = "Вы уверены, что хотите сбросить настройки?";
	static const String s_error = "Error!!!";

	/*Константы для комбинирования выборки значений*/
	static const int TOTAL_NONE   = 0;
	static const int TOTAL_COUNT  = 1; // Количество
	static const int TOTAL_SUM    = 2; // Сумма
	static const int TOTAL_AVG    = 3; // Среднее арифметическое
	static const int TOTAL_MIN    = 4; // Минимум среди значений
	static const int TOTAL_MAX    = 5; // Максимум среди значений
	static const int TOTAL_STDDEV = 6; // Стандартное отклонение

	/*команды PPY*/
	static const String s_cmdGGAL = "GetGlobalAccountList";
	static const String s_cmdVGA  = "VerifyGlobalAccount";

	//fileSystem variables
	static const String s_BDNAME   = 'data_base_ppy.db';
	static const String s_DOMAINNAMEFILE = "domainname.txt";
	static const String s_AUTHFILE = "auth.txt";
	static const String s_PERSONALSETTINGFILE = "personsetting.txt";
	static const String s_SETTINGFILE = "setting.txt";

	//структура данных из XML после команды cmdGGAL
	static const int GGLAindexID = 0;
	static const int GGLAindexParentID = 1;
	static const int GGLAindexName = 2;

	/*Style Const*/
	static const Color c_TEAL = Colors.teal;
	static const TextStyle ts_TOTAL = TextStyle(color: C.c_TEAL, fontSize: 14.0);

	static String Dir;

	static const int day = 1;
	static const int week = 7;
	static const int month = 30;
	static const int year = 365;
	static const int always = -1;

	static const List<DropdownMenuItem<int>> StorageReportsDurations = [
		DropdownMenuItem<int>(
			value: C.day,
			child: Text("День"),
		),
		DropdownMenuItem<int>(
			value: C.week,
			child: Text("Неделя"),
		),
		DropdownMenuItem<int>(
			value: C.month,
			child: Text("Месяц"),
		),
		DropdownMenuItem<int>(
			value: C.year,
			child: Text("Год"),
		),
	];

	//defaultSetting constants
	static const int DS_STORAGE_REPORT_DURATION = week;
	static const int DS_STORAGE_REPORT_COUNT = 10;

	//SQLite fields
	static const String DB_ROW_FIELD_ID         = 'id';
	static const String DB_ROW_FIELD_REPORTNAME = 'report_name';
	static const String DB_ROW_FIELD_METADATA   = 'meta_data';
	static const String DB_ROW_FIELD_DATETIME   = 'date_time';
	static const String DB_ROW_FIELD_XMLDATA    = 'xml_data';
	static const String DB_ROW_FIELD_TOTAL      = 'total';
	static const String DB_ROW_FIELD_RESERVE    = 'reserve';

}