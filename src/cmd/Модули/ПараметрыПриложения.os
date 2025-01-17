// MIT License
// Copyright (c) 2020 Silverbulleters LLC
// All rights reserved.

#Использовать logos
#Использовать tempfiles

Перем ЛогПриложения;
Перем КаталогПроекта;

Функция КаталогПроекта() Экспорт

	Рез = КаталогПроекта;
	
	Если Не ЗначениеЗаполнено(КаталогПроекта) Тогда
		ТекущийКаталог =  ТекущийСценарий().Каталог;
		Рез = ОбъединитьПути(ТекущийСценарий(), ТекущийКаталог, "../..");
		Файл = Новый Файл(Рез);
		Рез = Файл.ПолноеИмя;
		ЛогПриложения.Отладка("Каталог проекта: " + Рез);	
		КаталогПроекта = Рез;
	КонецЕсли;

	Возврат Рез;

КонецФункции

Функция ИмяФайлаНастройкиПакетнойСинхронизации() Экспорт
	Возврат "prepare.json";
КонецФункции

Функция КаталогЭкспорта() Экспорт
	Возврат ВременныеФайлы.СоздатьКаталог("export");
КонецФункции

Функция КаталогВременныхФайлов() Экспорт
	Возврат ВременныеФайлы.СоздатьКаталог("tmp");
КонецФункции

Функция СтруктураПараметровПриложения() Экспорт
	
	Параметры = Новый Структура();
	Параметры.Вставить("ВерсияПлатформы"                     , "8.3");
	Параметры.Вставить("Хранилище_Путь"                      , "");
	Параметры.Вставить("Хранилище_Пользователь"              , "");
	Параметры.Вставить("Хранилище_Пароль"                    , "");
	Параметры.Вставить("КаталогЭкспорта"                     , "");
	Параметры.Вставить("КаталогВременныхФайлов"              , "");
	Параметры.Вставить("ПутьКФайлуAUTHORS"                   , "");
	Параметры.Вставить("ПроверятьАвторов"                    , Ложь);  
	Параметры.Вставить("БазаСинхронизации_СтрокаПодключения" , ""); 
	Параметры.Вставить("БазаСинхронизации_Пользователь"      , ""); 
	Параметры.Вставить("БазаСинхронизации_Пароль"            , ""); 
	Параметры.Вставить("ВременнаяБаза_СтрокаПодключения"     , ""); 
	Параметры.Вставить("ВременнаяБаза_Пользователь"          , ""); 
	Параметры.Вставить("ВременнаяБаза_Пароль"                , ""); 
	Параметры.Вставить("НачальныйНомерКоммита"               , 0);

	Возврат Параметры; 

КонецФункции

// Получить объект логирования. Кешируется
//
//  Возвращаемое значение:
//   Лог - объект Лог для приложения
//
Функция Лог() Экспорт

	Если ЛогПриложения = Неопределено Тогда
		ЛогПриложения = Логирование.ПолучитьЛог(ИмяЛогаПриложения());
		ЛогПриложения.УстановитьУровень(УровниЛога.Информация);
	КонецЕсли;

	Возврат ЛогПриложения;

КонецФункции

Функция ИмяЛогаПриложения() Экспорт
	Возврат "oscript.app." + ИмяПриложения();
КонецФункции

Функция ИмяПриложения() Экспорт

	Возврат "rector";
		
КонецФункции

Функция Версия() Экспорт
	
	Возврат "0.2.0";
			
КонецФункции
