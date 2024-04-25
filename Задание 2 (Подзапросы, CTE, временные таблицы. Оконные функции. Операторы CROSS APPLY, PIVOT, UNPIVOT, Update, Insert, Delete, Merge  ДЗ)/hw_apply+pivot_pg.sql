CREATE EXTENSION IF NOT EXISTS tablefunc;

CREATE TEMP TABLE harvesting_fruits (company_id int, apple int, grape int, year int) ON COMMIT DROP;

CREATE TEMP TABLE company (id int primary key, name varchar(45)) ON COMMIT DROP;

insert into harvesting_fruits values
 (1, 1000, 2000, 2015)
,(1, 5000, 3000, 2016)
,(1, 5000, 3000, 2017)
,(1, 5000, 3000, 2018)
,(2, 9995, 8880, 2015)
,(2, 9990, 8880, 2016)
,(2, 9990, 6660, 2017)
,(2, 9990, 5550, 2018)
,(3, 3995, 3880, 2015)
,(3, 3990, 4880, 2016)
,(3, 3990, 5660, 2017)
,(3, 3990, 6550, 2018);

insert into company values
 (1, 'FGS')
,(2, 'Village')
,(3, 'Best Fruit');

--Имеем сводный набор данных:
select * from harvesting_fruits f
inner join company c on c.id = f.company_id;

--APPLAY
--Сначала собираем табличку в разрезе компаний и при этом объединим названия фруктов с годом:
SELECT c.name, fruits_by_year.*
FROM harvesting_fruits fruits
INNER JOIN company c ON fruits.company_id = c.id
CROSS JOIN LATERAL (VALUES (CONCAT('APPLES - ', year), apple),
                    (CONCAT('GRAPES - ', year), grape)
            ) fruits_by_year (fruit_year, amount);

--PIVOT - группируем и разворачиваем только за три выбранных года
SELECT *
FROM crosstab(
  'SELECT с.name, 
          CONCAT(fruit_type, '' - '', f.year) AS fruit_year,
          amount
   FROM (
       SELECT company_id, year, ''apples'' AS fruit_type, apple AS amount FROM harvesting_fruits
       UNION
       SELECT company_id, year, ''grapes'' AS fruit_type, grape AS amount FROM harvesting_fruits
   ) AS f
   JOIN company с ON f.company_id = с.id
   ORDER BY 1, 2',
  'VALUES (''apples - 2015''), (''apples - 2016''), (''apples - 2017''), 
          (''grapes - 2015''), (''grapes - 2016''), (''grapes - 2017'')'
) AS ct (
  "Name" text,
  "apples - 2015" int, "apples - 2016" int, "apples - 2017" int,
  "grapes - 2015" int, "grapes - 2016" int, "grapes - 2017" int
);