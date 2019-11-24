import 'package:flutter/material.dart';

/*
descr:
Эти флаги ОБЯЗАТЕЛЬНЫ. Все целочисленные значения не имеют флагов типа
fn_ - double
s_  - String
c_  - Color
ts_ - TextStyle
 */

abstract class C {
	static const String papyrus = "papyrus";
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
	static const String s_login   = "Логин";
	static const String s_accs    = "Учетные записи";
	static const String s_auth    = "Авторизация";
	static const String s_pass    = "Пароль";
	static const String s_rememberMe = "Запомнить меня";
	static const String s_apply = "Применить";
	static const String s_resetSetting = "Сброс настроек";
	static const String s_styloview = "StyloView";
	static const String s_amount = "Количество";
	static const String s_sum = "Сумма";
	static const String s_average  = "Среднее";
	static const String s_lowest_val = "Наименьшее";
	static const String s_highest_val = "Наибольшее";

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

	//структура данных из XML после команды cmdGGAL
	static const int GGLAindexID = 0;
	static const int GGLAindexParentID = 1;
	static const int GGLAindexName = 2;

	/*Style Const*/
	static const Color c_TEAL = Colors.teal;
	static const TextStyle ts_TOTAL = TextStyle(color: C.c_TEAL, fontSize: 16.0);

	static String Dir;
}