-- query #1 количество фильмов в каждой категории
SELECT  df2.name AS category_name, COUNT(df1.film_id) AS mov_in_category
FROM film_category AS df1 
INNER JOIN category AS df2 ON df1.category_id = df2.category_id
GROUP BY category_name
ORDER BY mov_in_category DESC;

-- query #2 10 актеров, чьи фильмы большего всего арендовали (по продолжительности аренды)
SELECT df4.actor_id, df4.first_name, df4.last_name,
justify_hours(SUM(df1.return_date-df1.rental_date)) AS sum_rental_duration
FROM rental AS df1
INNER JOIN inventory AS df2 ON df1.inventory_id = df2.inventory_id
INNER JOIN film_actor AS df3 ON df2.film_id = df3.film_id
INNER JOIN actor AS df4 ON df3.actor_id = df4.actor_id
GROUP BY df4.actor_id
ORDER BY sum_rental_duration DESC
LIMIT 10;

-- query #2 (по продолжительности аренды, вариант без самой продолжительности)
SELECT df4.actor_id, df4.first_name, df4.last_name
FROM rental AS df1
INNER JOIN inventory AS df2 ON df1.inventory_id = df2.inventory_id
INNER JOIN film_actor AS df3 ON df2.film_id = df3.film_id
INNER JOIN actor AS df4 ON df3.actor_id = df4.actor_id
GROUP BY df4.actor_id
ORDER BY SUM(df1.return_date-df1.rental_date) DESC
LIMIT 10;

-- query #3.0 категория фильмов, на которую потратили больше всего денег
SELECT df5.name
FROM payment AS df1
INNER JOIN rental AS df2 ON df1.rental_id = df2.rental_id
INNER JOIN inventory AS df3 ON df2.inventory_id = df3.inventory_id
INNER JOIN film_category AS df4 ON df3.film_id = df4.film_id
INNER JOIN category AS df5 ON df4.category_id = df5.category_id
GROUP BY df5.category_id
ORDER BY SUM(df1.amount) DESC
LIMIT 1;

-- query #3 (вариант с исключением значений, когда одинаковый rental_id указан для нескольких customer_id)
SELECT df5.name
FROM payment AS df1
INNER JOIN rental AS df2 ON df1.rental_id = df2.rental_id
INNER JOIN inventory AS df3 ON df2.inventory_id = df3.inventory_id
INNER JOIN film_category AS df4 ON df3.film_id = df4.film_id
INNER JOIN category AS df5 ON df4.category_id = df5.category_id
WHERE NOT (df1.rental_id = 4591
AND df1.customer_id IN (577, 16, 259, 401, 546))
GROUP BY df5.category_id
ORDER BY SUM(df1.amount) DESC
LIMIT 1;

-- query #4 названия фильмов, которых нет в inventory
SELECT df1.title
FROM film AS df1
LEFT JOIN inventory AS df2 ON df1.film_id = df2.film_id
WHERE df2.film_id IS NULL;

-- query #5 топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”
WITH pre_result
AS
(SELECT df4.first_name, df4.last_name, COUNT(df3.film_id) AS movies_in_children_category
FROM film_category AS df1
INNER JOIN category AS df2 ON df1.category_id = df2.category_id
INNER JOIN film_actor AS df3 ON df1.film_id = df3.film_id
INNER JOIN actor AS df4 ON df3.actor_id = df4.actor_id
WHERE  df2.name = 'Children'
GROUP BY df4.actor_id 
ORDER BY movies_in_children_category DESC)

SELECT first_name, last_name, movies_in_children_category
FROM pre_result
WHERE movies_in_children_category IN (SELECT DISTINCT movies_in_children_category
									 FROM pre_result 
									 ORDER BY movies_in_children_category DESC
									 LIMIT 3);

-- query #6 города с количеством активных и неактивных клиентов
SELECT df3.city, SUM(df1.active) AS total_active, 
(COUNT(df1.active) - SUM(df1.active)) AS total_non_active
FROM customer AS df1
INNER JOIN address AS df2 ON df1.address_id = df2.address_id
INNER JOIN city AS df3 ON df2.city_id = df3.city_id
GROUP BY  df3.city
ORDER BY total_non_active DESC; 

/*query #7.1 категория фильмов, у которой самое большое кол-во часов суммарной аренды в городах,
которые начинаются на букву “a” (без учета регистра)*/
SELECT df4.name
FROM rental AS df1
INNER JOIN inventory AS df2 ON df1.inventory_id = df2.inventory_id
INNER JOIN film_category AS df3 ON df2.film_id = df3.film_id
INNER JOIN category AS df4 ON df3.category_id = df4.category_id
INNER JOIN customer AS df5 ON df1.customer_id = df5.customer_id
INNER JOIN address AS df6 ON df5.address_id = df6.address_id
INNER JOIN city AS df7 ON df6.city_id = df7.city_id
WHERE LOWER(df7.city) LIKE 'a%'
GROUP BY df4.name
ORDER BY SUM(df1.return_date-df1.rental_date) DESC
LIMIT 1;

/*query #7.2 категория фильмов, у которой самое большое кол-во часов суммарной аренды в городах,
в которых есть символ “-”*/
SELECT df4.name
FROM rental AS df1
INNER JOIN inventory AS df2 ON df1.inventory_id = df2.inventory_id
INNER JOIN film_category AS df3 ON df2.film_id = df3.film_id
INNER JOIN category AS df4 ON df3.category_id = df4.category_id
INNER JOIN customer AS df5 ON df1.customer_id = df5.customer_id
INNER JOIN address AS df6 ON df5.address_id = df6.address_id
INNER JOIN city AS df7 ON df6.city_id = df7.city_id
WHERE df7.city LIKE '%-%'
GROUP BY df4.name
ORDER BY SUM(df1.return_date-df1.rental_date) DESC
LIMIT 1;
