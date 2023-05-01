/*

Music Store Data Exploration

*/

-- Q1. Find the top 10 countries with highest number of customer engagement.

select COUNT(invoice_id) AS Invoice_count
  , billing_country
from 
	invoice
group by
	billing_country
ORDER BY
	Invoice_count DESC
LIMIT 10;


-- Q2. The company would like to have an event by inviting a pop singer in the city which has the highest sales.

SELECT billing_city AS City
	, ROUND(SUM(total),2) AS Sales
FROM
	invoice
GROUP BY 
	City
ORDER BY
	Sales DESC
LIMIT 1;


-- Q3. The company would like to know the country that is the greatest contributor in driving its sales forward. (highest sales)

SELECT billing_country AS Country
	, ROUND(SUM(total),2) AS Sales
FROM
	invoice
GROUP BY 
	Country
ORDER BY
	Sales DESC
LIMIT 1;


-- Q4. The company would like to distribute a special voucher to the top 5 customers in United States.

SELECT customer_id AS Customer_ID
	, ROUND(SUM(total),2) AS Amount_spent
FROM
	invoice
WHERE
	billing_country = 'USA'
GROUP BY 
	Customer_ID
ORDER BY
	Amount_spent DESC
LIMIT 5;


-- Q5. Find the customer who is the MVP - has the highest purchase amount at global level.

SELECT c.customer_id
    , c.first_name
    , c.last_name
    , SUM(i.total) AS Purchase_total
FROM
    customer c
    JOIN invoice i
    ON c.customer_id = i.customer_id
GROUP BY
    c.customer_id
    , c.first_name
    , c.last_name
ORDER BY
	Purchase_total DESC
LIMIT 1;


-- Q6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A.

SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoiceline ON invoice.invoice_id = invoiceline.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;


Q7. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands.

SELECT AR.artist_id AS Artist_ID
    , AR.name AS Band_Name
    , COUNT(AR.artist_id) AS Track_count
FROM
	Track t
    JOIN album_data A ON t.album_id = A.album_id
    JOIN artist AR ON A.artist_id = AR.artist_id
    JOIN genre g ON t.genre_id = g.genre_id
WHERE
	g.name LIKE 'Rock'
GROUP BY
	AR.artist_id
    , AR.name
ORDER BY
	Track_count DESC
LIMIT 10;
   

-- Q8. Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.

SELECT name
	, milliseconds
FROM
	track
WHERE
	milliseconds > (SELECT AVG(milliseconds) AS Average_track_length
			FROM 
                            track)
ORDER BY
	milliseconds DESC;


-- Q9. Find how much amount was spent by each customer on artists? Write a query to return customer name, artist name and total amount spent.

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* Q10. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)

SELECT * 
FROM popular_genre 
WHERE RowNo <= 1;
