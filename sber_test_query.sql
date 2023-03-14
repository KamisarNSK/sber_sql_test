/*
* Найдите номера моделей и цены всех имеющихся в продаже продуктов (любого типа) производителя B (латинская буква).
*
* (Подзапрос можно сделать один раз после объединения, но, возможно, так будет быстрее на больших данных)
*/

SELECT model, price FROM pc WHERE model IN (SELECT model FROM product WHERE maker = 'B')
UNION
SELECT model, price FROM laptop WHERE model IN (SELECT model FROM product WHERE maker = 'B')
UNION
SELECT model, price FROM printer WHERE model IN (SELECT model FROM product WHERE maker = 'B');


/* 
 * Найти производителей, которые выпускают только принтеры или только PC.
 * При этом искомые производители PC должны выпускать не менее 3 моделей.
 * 
 * Что-то не так: A выпускает и то, и другое, суммарное число моделей 7;
 * B выпускает компьютеры и ноутбуки, но моделей всего 2;
 * C выпускает только ноутбуки;
 * D выпускает только принтеры, но моделей 2;
 * E выпускате и то и другое.
 * 
 * В этом конкретном датасете нет подходящих вариантов.
 * Для проверки я поставил ограничение >= 2, а не >= 3.
 */

SELECT maker
FROM (
	SELECT
		maker,
		SUM(CASE WHEN type = 'PC' THEN models ELSE 0 END) pc,
		SUM(CASE WHEN type = 'Printer' THEN models ELSE 0 END) printer,
		MIN(total_models) total_models
	FROM (
		SELECT
			maker,
			type,
			COUNT(model) models,
			MIN(total_models) total_models
		FROM product
		JOIN (
			SELECT
				maker,
				COUNT(model) total_models
			FROM product
			GROUP BY maker
		) a USING(maker)
		GROUP BY maker, type
	) a
	WHERE type != 'Laptop'
	GROUP BY maker
) a
WHERE (total_models >= 2) and (pc = 0 OR printer = 0)
ORDER BY maker;


/* Пронумеровать уникальные пары {maker, type} из Product, упорядочив их следующим образом:
 * - имя производителя (maker) по возрастанию;
 * - тип продукта (type) в порядке PC, Laptop, Printer.
 * 
 * Если некий производитель выпускает несколько типов продукции, то выводить его имя только в первой строке;
 * остальные строки для ЭТОГО производителя должны содержать пустую строку символов ('').  
 */

SELECT
	pair_number,
	CASE WHEN x = 1 THEN maker ELSE '' END maker,
	type
FROM (
	SELECT
		ROW_NUMBER() OVER (ORDER BY maker, LENGTH(type)) pair_number,
		ROW_NUMBER() OVER (PARTITION BY maker ORDER BY maker, LENGTH(type)) x,
		maker,
		type
	FROM (
		SELECT DISTINCT
			maker,
			type
		FROM product
	) a
	ORDER BY maker, LENGTH(type)
) a;


/* Найдите производителей самых дешевых цветных принтеров. Вывести: maker, price */

SELECT
	maker,
	price
FROM printer
JOIN product USING(model)
WHERE color = 'y' AND price = (
	SELECT MIN(price)
	FROM printer
	WHERE color = 'y'
);