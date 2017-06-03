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
				
			КонецЦикла;
			
	
КонецПроцедуры


&НаКлиенте
Процедура РасшСН_ЗаполнитьВходящиеЦены(Команда)
	РасшСН_ЗаполнитьВходящиеЦеныНаСервере(,Ложь);
КонецПроцедуры

&НаКлиенте
Процедура РасшСН_ЗаполнитьВсеИПересчитать(Команда)
	РасшСН_ЗаполнитьВходящиеЦеныНаСервере(Ложь);
КонецПроцедуры


&НаКлиенте
Процедура РасшСН_ТоварыКоличествоПриИзмененииПосле(Элемент)
	
СтрокаТовары = Элементы.Товары.ТекущиеДанные;

Если ЗначениеЗаполнено(СтрокаТовары.ЦенаВх) Тогда 
	
СтрокаТовары.СуммаВх=СтрокаТовары.ЦенаВХ*СтрокаТовары.Количество;
	
КонецЕсли;
	
КонецПроцедуры

