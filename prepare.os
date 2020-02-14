#Использовать logos
#Использовать fs
#Использовать gitrunner
#Использовать cmdline
#Использовать v8storage

Перем КаталогРепозитаря;
Перем КаталогИсходниковРепозитария;
Перем URLРепозитария;
Перем КаталогИсходников;
Перем ГитРепозиторий;
Перем ПутьХранилища;
Перем ХранилищеКонфигурации;
Перем ПользовательХранилища;
Перем ПарольПользователяХранилища;
Перем АвторКоммитаХранилища;
Перем АвторКоммитаGit;
Перем ЭлектроннаяПочтаАвтора;
// Перем ПредставлениеАвтора;

Процедура Инициализация()
	
	Парсер = Новый ПарсерАргументовКоманднойСтроки();
		
	Парсер.ДобавитьИменованныйПараметр("--projectPath", "Каталог проекта");
	Парсер.ДобавитьИменованныйПараметр("--storagePath", "Каталог хранилища");
	Парсер.ДобавитьИменованныйПараметр("--storage_psw", "Пользователь хранилища");
	Парсер.ДобавитьИменованныйПараметр("--storage_user", "Пароль пользователя хранилища");

	Параметры = Парсер.Разобрать(АргументыКоманднойСтроки);
	КаталогРепозитаря = Параметры["--projectPath"];
	Если КаталогРепозитаря = Неопределено Тогда
		КаталогРепозитаря = ОбъединитьПути(ТекущийКаталог(), "project");
		ФС.ОбеспечитьПустойКаталог(КаталогРепозитаря);
	КонецЕсли;
	КаталогИсходниковРепозитария = ОбъединитьПути(КаталогРепозитаря, "src", "cf");

	URLРепозитария = Параметры["--repoURL"];
	КаталогИсходников = Параметры["--srcPath"];

	Если КаталогИсходников = Неопределено Тогда
		КаталогИсходников = ОбъединитьПути(ТекущийКаталог(), "src", "cf");
	КонецЕсли;

	ПутьХранилища = Параметры["--storagePath"];
	ПользовательХранилища = Параметры["--storage_user"];
	ПарольПользователяХранилища = Параметры["--storage_psw"];

КонецПроцедуры

Процедура ОсновнаяРабота()
	
	ИнициализацияПроекта();
	ВыгрузитьИсходники();
КонецПроцедуры 


Процедура ВыгрузитьИсходники()
	ХранилищеКонфигурации = Новый МенеджерХранилищаКонфигурации();
	ХранилищеКонфигурации.УстановитьПутьКХранилищу(ПутьХранилища);

	Если (ПользовательХранилища <> Неопределено и ПарольПользователяХранилища <> Неопределено) Тогда
		ХранилищеКонфигурации.УстановитьПараметрыАвторизации(ПользовательХранилища, ПарольПользователяХранилища);
	КонецЕсли;

	Сообщить("Получаю таблицу версий хранилища");
	ТаблицаВерсийХранилища = ХранилищеКонфигурации.ПолучитьТаблицуВерсий();
	Сообщить("найденно " + ТаблицаВерсийХранилища.Количество() + " версий");
	// Отладка = Ложь;

	// ФС.ОбеспечитьПустойКаталог(КаталогРепозитаря);
	// НоваяКонфигурацияПоставщика = "D:\tmp\prepareproject\src\cf\Ext\ParentConfigurations\ТестоваяПоставка.cf";
	// СтараяКонфигурацияПоставщика = КаталогИсходниковРепозитария + "\Ext\ParentConfigurations\ТестоваяПоставка.cf";
	НоваяКонфигурацияПоставщика = "D:\tmp\prepareproject\src\cf\Ext\ParentConfigurations\ТестоваяПоставка.cf";
	СтараяКонфигурацияПоставщика = КаталогИсходниковРепозитария + "\Ext\ParentConfigurations\ТестоваяПоставка.cf";
	

	ПутьКФайлуСопоставления = ОбъединитьПути(КаталогИсходниковРепозитария, "AUTHORS");
	
	Сообщить("Получаю таблицу авторов");
	ТаблицаСопоставления = ПолучитьТаблицуАвторов(ПутьКФайлуСопоставления);

	Для каждого ВерсияХранилища Из ТаблицаВерсийХранилища Цикл
		Если ВерсияХранилища.Номер = 2 Тогда
			ИнициализироватьGitsync(ВерсияХранилища.Дата);
		КонецЕсли;

		СтрокаПользователя = ТаблицаСопоставления.Найти(ВерсияХранилища.Автор, "Автор");
		Если СтрокаПользователя = Неопределено Тогда
			ПредставлениеАвтора = СтрШаблон("%1 <%1@%2>", ВерсияХранилища.Автор, Строка(ДоменПочтыДляGit()));
		Иначе
			ПредставлениеАвтора = СтрокаПользователя.ПользовательGit + " <" + СтрокаПользователя.ПочтаПользователяGit + ">";
		КонецЕсли;

		Сообщить("Получаю таблицу версию" + ВерсияХранилища.Номер + " хранилища");
		ПолучитьВерсиюХранилища(ВерсияХранилища); 

		Если НЕ ФС.ФайлСуществует(СтараяКонфигурацияПоставщика) ИЛИ НЕ ФайлыРавны(НоваяКонфигурацияПоставщика, СтараяКонфигурацияПоставщика) Тогда
			Сообщить("Выгружаю конфигурацию поставщика");
			ВыгрузитьОбновлениеКонфигурацииПоставщика(ВерсияХранилища.Комментарий, СтрокаПользователя.ПользовательGit, СтрокаПользователя.ПочтаПользователяGit, ВерсияХранилища.Дата, НоваяКонфигурацияПоставщика);
		Иначе
			Сообщить("Выгружаю конфигурацию разработки");
			ВыгрузитьКонфигураациюРазработчика(ВерсияХранилища.Комментарий, СтрокаПользователя.ПользовательGit, СтрокаПользователя.ПочтаПользователяGit, ВерсияХранилища.Дата);
		КонецЕсли;
		// Отладка = Истина;
	КонецЦикла;
КонецПроцедуры

Процедура ВыгрузитьОбновлениеКонфигурацииПоставщика(Комментарий, ПользовательGit, ПочтаПользователяGit, Дата, НоваяКонфигурацияПоставщика);
	// Создаем и переходим в ветку base1C
	Сообщить("Получаю список веток");
	КолекцияВетокРепозитария = ГитРепозиторий.ПолучитьСписокВеток();
	Если КолекцияВетокРепозитария.Найти("base1c", "Имя") = Неопределено Тогда
		Сообщить("Ветка base1C не существует - создаем и переходим");
		ГитРепозиторий.ПерейтиВВетку("base1c", Истина);
	Иначе
		Сообщить("Ветка base1C существует - переходим");
		ГитРепозиторий.ПерейтиВВетку("base1c", , Истина);
	КонецЕсли;
	
	// выружаем конфигурацию поставщика
	Конфигуратор = Новый УправлениеКонфигуратором();
	Сообщить("Загружаю конфигурацию поставщика во временную ИБ");
	Конфигуратор.ЗагрузитьКонфигурациюИзФайла(НоваяКонфигурацияПоставщика);
	Сообщить("Выгружаю исходники конфигурации поставщика");
	Конфигуратор.ВыгрузитьКонфигурациюВФайлы(КаталогИсходников);
	ФС.КопироватьСодержимоеКаталога(КаталогИсходников, КаталогИсходниковРепозитария);
	ФайлВерсии = ОбъединитьПути(КаталогИсходниковРепозитария, "Configuration.xml");
	СохранитьИзмененияGit("Обновление конфигурации на версию поставщика: " + ПолучитьВерсиюКонфигурации(ФайлВерсии), "1c", "1c@1c.ru", Дата);
	
	ГитРепозиторий.ПерейтиВВетку("master", , Истина);
	ПараметрыКоманды = Новый Массив();
	ПараметрыКоманды.Добавить("merge");
	ПараметрыКоманды.Добавить("base1c");
	ПараметрыКоманды.Добавить("-Xtheirs");
	ПараметрыКоманды.Добавить("--no-commit");
	Сообщить("Мержим изменения из base1C");
	ГитРепозиторий.ВыполнитьКоманду(ПараметрыКоманды);
	ВыгрузитьКонфигураациюРазработчика(Комментарий, ПользовательGit, ПочтаПользователяGit, Дата);

	//делаем слияние с base 1c
	

КонецПроцедуры

Процедура ВыгрузитьКонфигураациюРазработчика(Комментарий, ПользовательGit, ПочтаПользователяGit, Дата)
	Сообщить("Выгружаем конфигурацию разработчика");
	КаталогИсходниковВРепозитарии = ОбъединитьПути(КаталогРепозитаря, "src", "cf");
	Сообщить("Копируем изменения из рабочего квталога в репозитарий");
	ФС.КопироватьСодержимоеКаталога(КаталогИсходников, КаталогИсходниковВРепозитарии);
	СохранитьИзмененияGit(Комментарий, ПользовательGit, ПочтаПользователяGit, Дата)
КонецПроцедуры


Процедура ПолучитьВерсиюХранилища(ВерсияХранилища)
	ИмяФайлаКофигурации =  ОбъединитьПути(ТекущийКаталог(), "config.cf");
	ХранилищеКонфигурации.СохранитьВерсиюКонфигурацииВФайл(ВерсияХранилища.Номер, ИмяФайлаКофигурации);
	Конфигуратор = Новый УправлениеКонфигуратором();
	Конфигуратор.ЗагрузитьКонфигурациюИзФайла(ИмяФайлаКофигурации);
	Конфигуратор.ВыгрузитьКонфигурациюВФайлы(КаталогИсходников);
КонецПроцедуры

Процедура ИнициализацияПроекта()
	// Создем новый git репозитарий
	//
	Сообщить(КаталогРепозитаря);
	ГитРепозиторий = Новый ГитРепозиторий();
	ГитРепозиторий.УстановитьРабочийКаталог(КаталогРепозитаря);
	ГитРепозиторий.Инициализировать();
	ФС.КопироватьСодержимоеКаталога(ОбъединитьПути(ТекущийКаталог(), "resources", "repo"), КаталогРепозитаря);
	ГитРепозиторий.УстановитьНастройку("user.name", "ci-bot");
	ГитРепозиторий.УстановитьНастройку("user.email", "ci-bot@1bit.com");
	ГитРепозиторий.УстановитьНастройку("core.quotePath", "true", РежимУстановкиНастроекGit.Локально);
	Если URLРепозитария <> Неопределено Тогда
		ГитРепозиторий.ДобавитьВнешнийРепозиторий("origin", "http://github.com/EvilBeaver/oscript-library");
	КонецЕсли;
	СохранитьИзмененияGit("Инициализация репозитария", "ci-bot", "ci-bot@!1bit.com",  Дата("20150101"));
КонецПроцедуры

Процедура ИнициализироватьGitsync(ДатаКоммита)
	ФС.КопироватьСодержимоеКаталога(ОбъединитьПути(ТекущийКаталог(), "resources", "gitsync"), КаталогИсходниковРепозитария);
	СохранитьИзмененияGit("Инициализация gitsync", "ci-bot", "ci-bot@test.com", ДатаКоммита);
КонецПроцедуры

Процедура СохранитьИзмененияGit(ТекстСообщения, АвторКоммита, ПочтаАвтораКоммита, Дата)
	
	Если Дата = Неопределено Тогда
		Дата = ТекущаяДата();
	КонецЕсли;

	ДатаДляГит = ДатаPOSIX(Дата);
	Сообщить("ДатаДляГит " + ДатаДляГит);

	Сообщить("Добавляем изменения в Git");
	ГитРепозиторий.ДобавитьФайлВИндекс(".");
	ГитРепозиторий.УстановитьНастройку("user.name", АвторКоммита);
	ГитРепозиторий.УстановитьНастройку("user.email", ПочтаАвтораКоммита);
	ПредставлениеАвтора = АвторКоммита + " <" + ПочтаАвтораКоммита + ">";
	ГитРепозиторий.Закоммитить(ТекстСообщения, Истина, , ПредставлениеАвтора);
КонецПроцедуры



// Вычиcлсяет значение хеш-суммы (контрольной суммы) для указанного файлов по алгоритму SHA-1.
//
// Параметры:
//  <ПутьКФайлу>  - Строка - Путь к файлу, сумму котрого необходимо вычислить
//
// Возвращаемое значение:
//   Строка   - Контрольная сумма файла
//
Функция ПолучитьСуммуФайлаSHA1(ПутьКФайлу) Экспорт

	Если НЕ ФС.ФайлСуществует(ПутьКФайлу) Тогда
		ВызватьИсключение "Выбран каталог или файла " + ПутьКФайлу +" не существует";
	КонецЕсли;

	Команда = Новый Команда;
	СистемнаяИнформация = Новый СистемнаяИнформация;
    ЭтоWindows = Найти(НРег(СистемнаяИнформация.ВерсияОС), "windows") > 0;
    Если ЭтоWindows Тогда
		Команда.УстановитьКоманду("certutil");
		Команда.ДобавитьПараметр("-hashfile");
		Команда.ДобавитьПараметр(ПутьКФайлу);
		Команда.Исполнить();
		Ответ = Команда.ПолучитьВывод();
		Результат =  СокрЛП(СтрПолучитьСтроку(СтрЗаменить(Ответ, " ", ""), 2));
	Иначе
		Команда.УстановитьКоманду("sha1sum");
		Команда.ДобавитьПараметр(ПутьКФайлу);
		Команда.Исполнить();
		Результат =  СтрРазделить(Команда.ПолучитьВывод(), " ")[0];
	КонецЕсли;
	Сообщить(Результат);
	Возврат Результат;
КонецФункции

// Сравнивает хеш-суммы 2-х переданных файлов
//
// Параметры:
//  <ПервыйФайл>  - Строка - Путь к первому файлу.
//
//  <ПервыйФайл>  - Строка - Путь ко второму файлу.
//
// Возвращаемое значение:
//   Булево   - Результат сравнения
//
Функция ФайлыРавны(ПервыйФайл , ВторойФайл) Экспорт
	Возврат ПолучитьСуммуФайлаSHA1(ПервыйФайл) = ПолучитьСуммуФайлаSHA1(ВторойФайл);
КонецФункции


// Получает таблицу авторов из файла
//
// Параметры:
//   ПутьКФайлуАвторов - Строка - путь к файлу авторов
//
// Возвращаемое значение:
//   ТаблицаЗначений - таблица пользователей с колонками
//     * Автор               - Строка - имя автора версии в хранилище
//     * ПредставлениеАвтора - Строка - представление автора для коммита в git
//
Функция ПолучитьТаблицуАвторов(Знач ПутьКФайлуАвторов) Экспорт
	
	СтандартнаяОбработка = Истина;

	ТаблицаАвторов = НоваяТаблицаАвторов();

	Если СтандартнаяОбработка Тогда
		ПрочитатьФайлАвторов(ПутьКФайлуАвторов, ТаблицаАвторов);
	КонецЕсли;
	
	Возврат ТаблицаАвторов;

КонецФункции

Процедура ПрочитатьФайлАвторов(ПутьКФайлуАвторов, ТаблицаАвторов)
	
	Если НЕ ЗначениеЗаполнено(ПутьКФайлуАвторов) Тогда
		Возврат;
	КонецЕсли;

	Файл = Новый Файл(ПутьКФайлуАвторов);
	Если Не Файл.Существует() Тогда
		Возврат;
	КонецЕсли;

	ТекстовыйФайл = Новый ЧтениеТекста(ПутьКФайлуАвторов, "utf-8");
	ТекстФайла = ТекстовыйФайл.Прочитать();
	
	МассивСтрокФайла = СтрРазделить(ТекстФайла, Символы.ПС, Ложь);

	Для каждого СтрокаФайла Из МассивСтрокФайла Цикл

		Если СтрНачинаетсяС(СокрЛП(СтрокаФайла), "//") Тогда
			Продолжить;
		КонецЕсли;

		МассивКлючей =  СтрРазделить(СтрокаФайла, "=", Ложь);

		// Если Не МассивКлючей.Количество() = 2 Тогда
		// 	Лог.Предупреждение("Ошибка чтения файла авторов строка <%1>", СтрокаФайла);
		// 	Продолжить;
		// КонецЕсли;

		НоваяСтрока = ТаблицаАвторов.Добавить();
		НоваяСтрока.Автор = СокрЛП(МассивКлючей[0]);
		ПредставлениеАвтора = СокрЛП(МассивКлючей[1]);
		Сообщить("ПредставлениеАвтора: " + ПредставлениеАвтора);

		ПользовательGit = СтрРазделить(ПредставлениеАвтора," ")[0];
		НоваяСтрока.ПользовательGit = ПользовательGit;
		Сообщить("Пользователь GIT: " + ПользовательGit);

		ПочтаПользователяGit = СтрРазделить(ПредставлениеАвтора, " ")[1];
		ПочтаПользователяGit = СтрЗаменить(ПочтаПользователяGit, "<", "");

		Сообщить("Почта пользователя GIT:" + ПочтаПользователяGit);
		НоваяСтрока.ПочтаПользователяGit = СтрЗаменить(ПочтаПользователяGit, ">", "");

	КонецЦикла;

	ТекстовыйФайл.Закрыть();

	Если ТекстовыйФайл <> Неопределено Тогда
		ОсвободитьОбъект(ТекстовыйФайл);
	КонецЕсли;

КонецПроцедуры

Функция НоваяТаблицаАвторов()
	
	Таблица = Новый ТаблицаЗначений;
	Таблица.Колонки.Добавить("Автор");
	Таблица.Колонки.Добавить("ПользовательGit");
	Таблица.Колонки.Добавить("ПочтаПользователяGit");
	
	Возврат Таблица;
	
КонецФункции

Функция ДатаPOSIX(Знач Дата)
	
	Возврат "" + Год(Дата) + "-" + ФорматДвузначноеЧисло(Месяц(Дата)) + "-" + ФорматДвузначноеЧисло(День(Дата)) + " "
	+ ФорматДвузначноеЧисло(Час(Дата)) + ":" + ФорматДвузначноеЧисло(Минута(Дата))
	+ ":" + ФорматДвузначноеЧисло(Секунда(Дата));
	
КонецФункции

Функция ФорматДвузначноеЧисло(ЗначениеЧисло)
	ЧислоСтрокой = Строка(ЗначениеЧисло);
	Если СтрДлина(ЧислоСтрокой) < 2 Тогда
		ЧислоСтрокой = "0" + ЧислоСтрокой;
	КонецЕсли;
	
	Возврат ЧислоСтрокой;
КонецФункции

Функция ДоменПочтыДляGit() 
	Возврат "1bit.com"	
КонецФункции

Функция ПолучитьВерсиюКонфигурации(ФайлВерсии)
	Файл = Новый ЧтениеТекста(ФайлВерсии);
	ФайлСтрокой = Файл.Прочитать();
	Файл.Закрыть();
	РВ = Новый РегулярноеВыражение("<Version>(.*)<\/Version>");
	Совпадения = РВ.НайтиСовпадения(ФайлСтрокой);
	Если Совпадения.Количество() > 0 Тогда
		Результат =  Совпадения[0].Значение;
		Результат = СтрЗаменить(Результат, "<Version>", "");
		Результат = СтрЗаменить(Результат, "</Version>", "");
		Возврат Результат; 
	КонецЕсли;
КонецФункции

Лог = Логирование.ПолучитьЛог("oscript.app.PrepareBase");

Инициализация();

Попытка
	ОсновнаяРабота();
Исключение
	Сообщить(ОписаниеОшибки());
КонецПопытки;