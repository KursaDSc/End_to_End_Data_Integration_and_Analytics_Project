-- Top 10 rental movies:
SELECT f.film_id, f.title, COUNT(r.rental_id) AS rentals
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
GROUP BY f.film_id, f.title
ORDER BY rentals DESC
LIMIT 10;


-- Total number of rentals by country:
SELECT co.country, COUNT(r.rental_id) AS rentals
FROM rental r
JOIN customer c ON r.customer_id = c.customer_id
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
GROUP BY co.country
ORDER BY rentals DESC;


-- Total payout per customer:
SELECT c.customer_id, CONCAT(c.first_name,' ',c.last_name) AS name, SUM(p.amount) AS total_paid
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN customer c ON r.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY total_paid DESC
LIMIT 20;


-- Monthly income by payment date:
SELECT DATE_FORMAT(p.payment_date, '%Y-%m') AS ym, SUM(p.amount) AS revenue
FROM payment p
GROUP BY ym
ORDER BY ym;


-- Cities with the most rentals:
SELECT ci.city, COUNT(r.rental_id) AS rentals
FROM rental r
JOIN customer c ON r.customer_id = c.customer_id
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
GROUP BY ci.city
ORDER BY rentals DESC
LIMIT 10;
