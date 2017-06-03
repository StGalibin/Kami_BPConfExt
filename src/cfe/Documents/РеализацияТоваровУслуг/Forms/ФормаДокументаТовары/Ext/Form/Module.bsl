﻿

&НаСервере
Процедура РасшСН_ЗаполнитьВходящиеЦеныНаСервере(ТолькоНезаполненныеПозиции = Истина, ПересчитатьСуммы = Истина)
	
ПараметрыОтбора = Неопределено;

Если ТолькоНезаполненныеПозиции Тогда

ПараметрыОтбора = новый Структура();
ПараметрыОтбора.Вставить("ЦенаВХ", 0);

КонецЕсли;

СписокНоменклатур = Объект.Товары.Выгрузить(ПараметрыОтбора,"Номенклатура");
	
	
Запрос=новый запрос;
			запрос.УстановитьПараметр("Счет",ПланыСчетов.Хозрасчетный.ТоварыНаСкладах);
			запрос.УстановитьПараметр("Склад",Объект.Склад);
			запрос.УстановитьПараметр("Номенклатура",СписокНоменклатур);	
			запрос.УстановитьПараметр("Организация",Объект.Организация);	
			запрос.УстановитьПараметр("Период",Объект.Дата);
			
			текстзапроса="ВЫБРАТЬ
			             |	ХозрасчетныйОстатки.Счет КАК СчетЗ,
			             |	ХозрасчетныйОстатки.Субконто1 КАК Субконто1З,
			             |	ХозрасчетныйОстатки.Субконто3 КАК Субконто2З,
			             |	СУММА(ХозрасчетныйОстатки.СуммаОстаток) КАК СуммаОстатокЗ,
			             |	СУММА(ХозрасчетныйОстатки.КоличествоОстаток) КАК КоличествоОстатокЗ,
			             |	ХозрасчетныйОстатки.Организация
			             |ИЗ
			             |	РегистрБухгалтерии.Хозрасчетный.Остатки(&период, , , ) КАК ХозрасчетныйОстатки
			             |ГДЕ
			             |	ХозрасчетныйОстатки.Субконто1 В (&Номенклатура)
						 |	И ХозрасчетныйОстатки.Счет = &Счет
						 |	И ХозрасчетныйОстатки.КоличествоОстаток > 0";
						 если значениезаполнено(Объект.Склад) тогда
						 текстзапроса=текстзапроса+"
						 |	И ХозрасчетныйОстатки.Субконто3 = &Склад";
			             конецесли;
			             если значениезаполнено(Объект.Организация) тогда
						 текстзапроса=текстзапроса+"
			             |	И ХозрасчетныйОстатки.Организация = &Организация";
						 конецесли;
						 текстзапроса=текстзапроса+"
			             |СГРУППИРОВАТЬ ПО
			             |	ХозрасчетныйОстатки.Субконто1,
			             |	ХозрасчетныйОстатки.Счет,
			             |	ХозрасчетныйОстатки.Субконто3,
			             |	ХозрасчетныйОстатки.Организация
			             |ИТОГИ
			             |	СУММА(СуммаОстатокЗ),
			             |	СУММА(КоличествоОстатокЗ)
			             |ПО
			             |	Субконто1З";
			Себестоимость=0;		
			запрос.Текст=текстзапроса;
			ТЗСебестоимость=запрос.Выполнить().Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкам);
			
			Для каждого СтрокаТовары Из Объект.Товары Цикл
			
				Если ЗначениеЗаполнено(СтрокаТовары.ЦенаВх) и ТолькоНезаполненныеПозиции Тогда
					Продолжить;
				КонецЕсли;
				
				СтрокаСебестоимость = ТЗСебестоимость.Строки.Найти(СтрокаТовары.Номенклатура, "Субконто1З");
				
				Если СтрокаСебестоимость = Неопределено Тогда
					Продолжить;
				КонецЕсли;
				
				СтрокаТовары.ЦенаВХ = окр(СтрокаСебестоимость.СуммаОстатокЗ/СтрокаСебестоимость.КоличествоОстатокЗ,2,1);
			    СтрокаТовары.СуммаВх=СтрокаТовары.ЦенаВХ*СтрокаТовары.Количество;
				
				Если ПересчитатьСуммы Тогда
					
				Если ЗначениеЗаполнено(СтрокаТовары.ЦенаВх) Тогда
	
Если ЗначениеЗаполнено(СтрокаТовары.ПроцентНаценки) Тогда 
	
СтрокаТовары.Цена = СтрокаТовары.ЦенаВХ + СтрокаТовары.ЦенаВХ*СтрокаТовары.ПроцентНаценки/100;

КонецЕсли;

СтрокаТовары.СуммаНаценки = СтрокаТовары.ПроцентНаценки*СтрокаТовары.СуммаВХ/100;

	
КонецЕсли;

	КонецЕсли;
			
			КонецЦикла;
			
	
КонецПроцедуры


&НаКлиенте
Процедура РасшСН_ЗаполнитьВходящиеЦены(Команда)
	РасшСН_ЗаполнитьВходящиеЦеныНаСервере(,Ложь);
КонецПроцедуры

&НаКлиенте
Процедура РасшСН_ЗаполнитьВсеИПересчитать(Команда)
	РасшСН_ЗаполнитьВходящиеЦеныНаСервере(Ложь);
	ОбработкаТабличныхЧастейКлиентСервер.ПриИзмененииКоличествоЦена(ЭтаФорма, "Товары");

КонецПроцедуры


&НаКлиенте
Процедура РасшСН_ТоварыКоличествоПриИзмененииПосле(Элемент)
	
СтрокаТовары = Элементы.Товары.ТекущиеДанные;

Если ЗначениеЗаполнено(СтрокаТовары.ЦенаВх) Тогда 
	
СтрокаТовары.СуммаВх=СтрокаТовары.ЦенаВХ*СтрокаТовары.Количество;
СтрокаТовары.СуммаНаценки = СтрокаТовары.ПроцентНаценки*СтрокаТовары.СуммаВХ/100;
	
КонецЕсли;
	
КонецПроцедуры


&НаКлиенте
Процедура РасшСН_ТоварыПроцентНаценкиПриИзмененииВместо(Элемент)
	
СтрокаТовары = Элементы.Товары.ТекущиеДанные;

Если ЗначениеЗаполнено(СтрокаТовары.ЦенаВх) Тогда
	
Если ЗначениеЗаполнено(СтрокаТовары.ПроцентНаценки) Тогда 
	
СтрокаТовары.Цена = СтрокаТовары.ЦенаВХ + СтрокаТовары.ЦенаВХ*СтрокаТовары.ПроцентНаценки/100;
ОбработкаТабличныхЧастейКлиентСервер.ПриИзмененииКоличествоЦена(ЭтаФорма, "Товары");

КонецЕсли;

СтрокаТовары.СуммаНаценки = СтрокаТовары.ПроцентНаценки*СтрокаТовары.СуммаВХ/100;

	
КонецЕсли;
	
	
КонецПроцедуры


&НаКлиенте
Процедура РасшСН_ТоварыЦенаПриИзмененииПосле(Элемент)
	
СтрокаТовары = Элементы.Товары.ТекущиеДанные;

Если ЗначениеЗаполнено(СтрокаТовары.ЦенаВх) Тогда 
	
СтрокаТовары.ПроцентНаценки = СтрокаТовары.Цена/СтрокаТовары.ЦенаВХ*100-100;
СтрокаТовары.СуммаНаценки = СтрокаТовары.ПроцентНаценки*СтрокаТовары.СуммаВХ/100;
	
КонецЕсли;
	
	
КонецПроцедуры

&НаСервере
Процедура РасшСН_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	
	Если ЗначениеЗаполнено(Объект.Ссылка) Тогда
		
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ХранилищеДанныхОбъектовРасширений.Данные
		|ИЗ
		|	РегистрСведений.ХранилищеДанныхОбъектовРасширений КАК ХранилищеДанныхОбъектовРасширений
		|ГДЕ
		|	ХранилищеДанныхОбъектовРасширений.Владелец = &Владелец";
	
	Запрос.УстановитьПараметр("Владелец", Объект.Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если не РезультатЗапроса.Пустой() Тогда
		
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	ВыборкаДетальныеЗаписи.Следующий();
	
	ТЗДанныхДокумента = ВыборкаДетальныеЗаписи.Данные.Получить();
	
	Для каждого СтрокаТовары Из Объект.Товары Цикл
		
		СтрокаТЗ = ТЗДанныхДокумента.Найти(СтрокаТовары.НомерСтроки, "LineNumber");
				
				Если СтрокаТЗ = Неопределено Тогда
					Продолжить;
				КонецЕсли;
				
			ЗаполнитьЗначенияСвойств(СтрокаТовары, СтрокаТЗ);
			
			КонецЦикла;
		

	КонецЕсли;

КонецЕсли;

	
КонецПроцедуры


&НаСервере
Процедура РасшСН_ПриЗаписиНаСервереПосле(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
ХранилищеДанных = новый ХранилищеЗначения (Объект.Товары.Выгрузить(,"НомерСтроки, ЦенаВх, СуммаВх, ПроцентНаценки,СуммаНаценки"));

МенеджерЗаписи = РегистрыСведений.ХранилищеДанныхОбъектовРасширений.СоздатьМенеджерЗаписи();
	
МенеджерЗаписи.Владелец = Объект.Ссылка;
МенеджерЗаписи.Данные = ХранилищеДанных;
МенеджерЗаписи.Записать();	
	
	
КонецПроцедуры


&НаКлиенте
Процедура РасшСН_ТоварыЦенаВХПриИзмененииВместо(Элемент)

СтрокаТовары = Элементы.Товары.ТекущиеДанные;

СтрокаТовары.СуммаВх=СтрокаТовары.ЦенаВХ*СтрокаТовары.Количество;

Если ЗначениеЗаполнено(СтрокаТовары.ПроцентНаценки) Тогда
	
СтрокаТовары.Цена = СтрокаТовары.ЦенаВХ + СтрокаТовары.ЦенаВХ*СтрокаТовары.ПроцентНаценки/100;
СтрокаТовары.СуммаНаценки = СтрокаТовары.ПроцентНаценки*СтрокаТовары.СуммаВХ/100;
ОбработкаТабличныхЧастейКлиентСервер.ПриИзмененииКоличествоЦена(ЭтаФорма, "Товары");

КонецЕсли;

КонецПроцедуры

