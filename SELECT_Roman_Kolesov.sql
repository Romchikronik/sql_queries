-- Which staff members made the highest revenue for each store and deserve a bonus for the year 2017?

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


-- Which five movies were rented more than the others, and what is the expected age of the audience for these movies?

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

--Which actors/actresses didn't act for a longer period of time than the others?

