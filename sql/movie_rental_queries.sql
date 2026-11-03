
USE sakila;

/*
=========================================================
Q1: Customers who spent above the average customer total
Method: Subquery with AVG and HAVING

Logic:
1. Calculate total spending for each customer.
2. Calculate the average of all customer spending totals.
3. Return customers whose total spending exceeds that average.
4. Sort results from highest to lowest spending.

Result: 285 customers above the average total of 112.53
=========================================================
*/

SELECT
    customer_id,
    SUM(amount) AS total_spending
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > (
    SELECT AVG(customer_total)
    FROM (
        SELECT
            customer_id,
            SUM(amount) AS customer_total
        FROM payment
        GROUP BY customer_id
    ) AS average_customer_totals
)
ORDER BY total_spending DESC;


/*
=========================================================
Q1 (Version B): Customers who spent above the average customer total
Method: Derived table with WHERE and a scalar subquery

Logic:
1. Build each customer's total spending as a derived table.
2. Calculate the average of those totals in a scalar subquery.
3. Use WHERE to keep customers above that average.
4. Sort from highest to lowest spending.

Result: 285 customers (same as Version A)
=========================================================
*/

SELECT
    customer_totals.customer_id,
    customer_totals.total_spending
FROM (
    SELECT
        customer_id,
        SUM(amount) AS total_spending
    FROM payment
    GROUP BY customer_id
) AS customer_totals
WHERE customer_totals.total_spending > (
    SELECT AVG(average_customer_totals.customer_total)
    FROM (
        SELECT SUM(amount) AS customer_total
        FROM payment
        GROUP BY customer_id
    ) AS average_customer_totals
)
ORDER BY customer_totals.total_spending DESC;

/*
=========================================================
Q2: Top 10 most rented films compared with average rentals
Method: Correlated subquery and scalar subqueries

Logic:
1. Count rentals for each film.
2. Calculate average rentals per film across the database.
3. Display the 10 most rented films.
4. Sort by rental count in descending order.

Result: 10 films (top 10); average is 16.044 rentals per film
=========================================================
*/

SELECT
    film.film_id,
    film.title,
    (
        SELECT COUNT(*)
        FROM rental
        JOIN inventory
            ON rental.inventory_id = inventory.inventory_id
        WHERE inventory.film_id = film.film_id
    ) AS rental_count,
    (
        SELECT COUNT(*)
        FROM rental
    ) / (
        SELECT COUNT(*)
        FROM film
    ) AS average_rentals_per_film
FROM film
ORDER BY rental_count DESC, film.title
LIMIT 10;


/*
=========================================================
Q3: Films that have never been rented
Method: NOT IN subquery

Logic:
1. Find distinct film IDs that appear in rental records.
2. Match rental records to inventory using inventory_id.
3. Exclude those film IDs from the film table.
4. Display films that have never been rented.

Result: 42 films never rented
=========================================================
*/

SELECT
    film.film_id,
    film.title
FROM film
WHERE film.film_id NOT IN (
    SELECT DISTINCT
        inventory.film_id
    FROM rental
    JOIN inventory
        ON rental.inventory_id = inventory.inventory_id
)
ORDER BY film.title;

/*
=========================================================
Q3 (Version B): Films that have never been rented
Method: NOT EXISTS correlated subquery

Logic:
1. For each film, look for at least one rental of any of its copies.
2. Keep the film only if no such rental exists.
3. Sort results by title.

Result: 42 films (same as Version A)
=========================================================
*/

SELECT
    film.film_id,
    film.title
FROM film
WHERE NOT EXISTS (
    SELECT 1
    FROM inventory
    JOIN rental
        ON rental.inventory_id = inventory.inventory_id
    WHERE inventory.film_id = film.film_id
)
ORDER BY film.title;

/*
=========================================================
Q4: Customers renting more than their store's average
Method: Correlated subquery and derived table

Logic:
1. Calculate the rental count for each customer.
2. Calculate the average rental count for each store.
3. Compare each customer's rentals with their store average.
4. Return customers whose rental count is above their store average.

Result: 296 customers above their store average
=========================================================
*/

SELECT
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    customer.store_id,
    COUNT(rental.rental_id) AS rental_count
FROM customer
JOIN rental
    ON rental.customer_id = customer.customer_id
GROUP BY
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    customer.store_id
HAVING COUNT(rental.rental_id) > (
    SELECT AVG(store_customer_rentals.rental_count)
    FROM (
        SELECT
            customer_inner.customer_id,
            customer_inner.store_id,
            COUNT(*) AS rental_count
        FROM customer AS customer_inner
        JOIN rental AS rental_inner
            ON rental_inner.customer_id = customer_inner.customer_id
        GROUP BY
            customer_inner.customer_id,
            customer_inner.store_id
    ) AS store_customer_rentals
    WHERE store_customer_rentals.store_id = customer.store_id
)
ORDER BY customer.store_id, rental_count DESC;


/*
=========================================================
Q5: Revenue by film category and percentage of total revenue
Method: Derived table and scalar subquery

Logic:
1. Connect payments to rentals, inventory, films and categories.
2. Calculate total revenue for each film category.
3. Calculate each category's percentage of total payment revenue.
4. Sort categories by revenue in descending order.

Result: 16 categories
=========================================================
*/

SELECT
    category_revenue.category,
    category_revenue.revenue,
    ROUND(
        100 * category_revenue.revenue /
        (SELECT SUM(amount) FROM payment),
        2
    ) AS percentage_of_total
FROM (
    SELECT
        category.name AS category,
        SUM(payment.amount) AS revenue
    FROM payment
    JOIN rental
        ON payment.rental_id = rental.rental_id
    JOIN inventory
        ON rental.inventory_id = inventory.inventory_id
    JOIN film_category
        ON inventory.film_id = film_category.film_id
    JOIN category
        ON film_category.category_id = category.category_id
    GROUP BY category.name
) AS category_revenue
ORDER BY category_revenue.revenue DESC;


/*
=========================================================
Q6: Staff members with above-average payment transactions
Method: Subquery with AVG and HAVING

Logic:
1. Count the payments processed by each staff member.
2. Calculate the average payment count across staff members.
3. Return staff members whose payment count exceeds the average.
4. Sort by transactions in descending order.

Result: 1 staff member above average (2 staff in total)
=========================================================
*/

SELECT
    staff.staff_id,
    staff.first_name,
    staff.last_name,
    COUNT(payment.payment_id) AS transaction_count
FROM staff
JOIN payment
    ON payment.staff_id = staff.staff_id
GROUP BY
    staff.staff_id,
    staff.first_name,
    staff.last_name
HAVING COUNT(payment.payment_id) > (
    SELECT AVG(staff_payment_counts.transaction_count)
    FROM (
        SELECT
            staff_id,
            COUNT(*) AS transaction_count
        FROM payment
        GROUP BY staff_id
    ) AS staff_payment_counts
)
ORDER BY transaction_count DESC;


/*
=========================================================
Q7: Customer lifetime value ranking
Method: Subquery-based ranking

Logic:
1. Calculate total payment amount for each customer.
2. Compare each customer's lifetime value with other customers.
3. Count customers with a higher lifetime value.
4. Add 1 to calculate the customer's rank.
5. Sort customers by lifetime value rank.

Result: 599 customers ranked
=========================================================
*/

SELECT
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    customer_lifetime_value.lifetime_value,
    (
        SELECT COUNT(*) + 1
        FROM (
            SELECT
                customer_id,
                SUM(amount) AS lifetime_value
            FROM payment
            GROUP BY customer_id
        ) AS higher_value_customers
        WHERE higher_value_customers.lifetime_value >
              customer_lifetime_value.lifetime_value
    ) AS lifetime_value_rank
FROM customer
JOIN (
    SELECT
        customer_id,
        SUM(amount) AS lifetime_value
    FROM payment
    GROUP BY customer_id
) AS customer_lifetime_value
    ON customer.customer_id = customer_lifetime_value.customer_id
ORDER BY lifetime_value_rank, customer.customer_id;

/*
=========================================================
Q8: Base dataset for Excel PivotTables and dashboard
(Supporting query, not one of the 7 business questions)
Method: Multi-table JOIN, one row per rental

Logic:
1. Start from each rental.
2. Add customer, film, category and payment details.
3. Use LEFT JOIN for payment so every rental is kept.
4. Sort by rental_id.

Result: 16044 rows
=========================================================
*/

SELECT
    rental.rental_id,
    DATE(rental.rental_date) AS rental_date,
    customer.customer_id,
    CONCAT(customer.first_name, ' ', customer.last_name) AS customer_name,
    customer.store_id,
    film.film_id,
    film.title,
    film.rating,
    category.name AS category,
    payment.staff_id,
    payment.amount
FROM rental
JOIN customer
    ON rental.customer_id = customer.customer_id
JOIN inventory
    ON rental.inventory_id = inventory.inventory_id
JOIN film
    ON inventory.film_id = film.film_id
JOIN film_category
    ON film.film_id = film_category.film_id
JOIN category
    ON film_category.category_id = category.category_id
LEFT JOIN payment
    ON payment.rental_id = rental.rental_id
ORDER BY rental.rental_id;
