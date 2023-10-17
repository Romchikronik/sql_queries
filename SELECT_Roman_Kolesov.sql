-- Which staff members made the highest revenue for each store and deserve a bonus for the year 2017?

-- First option
WITH StaffRevenue AS (
    SELECT
        s.store_id,
        s.staff_id,
        s.first_name,
        s.last_name,
        SUM(p.amount) AS total_revenue
    FROM
        staff s
    JOIN rental r ON s.staff_id = r.staff_id
    JOIN payment p ON r.rental_id = p.rental_id
    WHERE
        EXTRACT(YEAR FROM p.payment_date) = 2017
    GROUP BY
        s.store_id,
        s.staff_id,
        s.first_name,
        s.last_name
)
, RankedStaffRevenue AS (
    SELECT
        store_id,
        staff_id,
        first_name,
        last_name,
        total_revenue,
        ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY total_revenue DESC) AS rank
    FROM
        StaffRevenue
)
SELECT
    r.store_id,
    r.staff_id,
    r.first_name,
    r.last_name,
    r.total_revenue
FROM
    RankedStaffRevenue r
WHERE
    r.rank = 1;
    
-- Second option (using subqueries)

SELECT
    store_id,
    staff_id,
    first_name,
    last_name,
    total_revenue
FROM (
    SELECT
        s.store_id,
        s.staff_id,
        s.first_name,
        s.last_name,
        SUM(p.amount) AS total_revenue,
        ROW_NUMBER() OVER (PARTITION BY s.store_id ORDER BY SUM(p.amount) DESC) AS rank
    FROM
        staff s
    JOIN rental r ON s.staff_id = r.staff_id
    JOIN payment p ON r.rental_id = p.rental_id
    WHERE
        EXTRACT(YEAR FROM p.payment_date) = 2017
    GROUP BY
        s.store_id,
        s.staff_id,
        s.first_name,
        s.last_name
) AS RankedStaffRevenue
WHERE rank = 1;

-- Which five movies were rented more than the others, and what is the expected age of the audience for these movies?

-- First option

WITH Top5Movies AS (
    SELECT
        f.film_id,
        f.title,
        f.rating,
        COUNT(r.rental_id) AS rental_count
    FROM
        film f
    JOIN rental r ON f.film_id = r.inventory_id
    GROUP BY
        f.film_id, f.title, f.rating
    ORDER BY
        rental_count DESC
    LIMIT 5
)

SELECT
    t.film_id,
    t.title,
    t.rating,
    t.rental_count
FROM
    Top5Movies t
ORDER BY
    t.rental_count DESC;
    
-- Second option (using subqueries)

SELECT
    t.film_id,
    t.title,
    t.rating,
    t.rental_count
FROM (
    SELECT
        f.film_id,
        f.title,
        f.rating,
        COUNT(r.rental_id) AS rental_count
    FROM
        film f
    JOIN rental r ON f.film_id = r.inventory_id
    GROUP BY
        f.film_id, f.title, f.rating
    ORDER BY
        rental_count DESC
    LIMIT 5
) AS t
ORDER BY
    t.rental_count DESC;

--Which actors/actresses didn't act for a longer period of time than the others?

-- First option

WITH ActorLastActivity AS (
  SELECT
    a.actor_id,
    a.first_name,
    a.last_name,
    MAX(f.last_update) AS last_film_update
  FROM
    actor a
    JOIN film_actor fa ON a.actor_id = fa.actor_id
    JOIN film f ON fa.film_id = f.film_id
  GROUP BY
    a.actor_id, a.first_name, a.last_name
)

SELECT
  actor_id,
  first_name,
  last_name,
  CASE
    WHEN last_film_update IS NOT NULL THEN NOW() - last_film_update
    ELSE NULL
  END AS inactive_period
FROM
  ActorLastActivity
ORDER BY
  inactive_period DESC;
  
-- Second option (using subqueries)

SELECT
  actor_id,
  first_name,
  last_name,
  CASE
    WHEN last_film_update IS NOT NULL THEN NOW() - last_film_update
    ELSE NULL
  END AS inactive_period
FROM (
  SELECT
    a.actor_id,
    a.first_name,
    a.last_name,
    MAX(f.last_update) AS last_film_update
  FROM
    actor a
    JOIN film_actor fa ON a.actor_id = fa.actor_id
    JOIN film f ON fa.film_id = f.film_id
  GROUP BY
    a.actor_id, a.first_name, a.last_name
) AS ActorLastActivity
ORDER BY
  inactive_period DESC;


