-- 1. Who is the senior most employee based on job title?
SELECT first_name, last_name, levels from employee
ORDER by levels desc
LIMIT 1

-- 2. Which countries have the most Invoices?
SELECT count(*) as c, billing_country from invoice
group by billing_country
order by c DESC

-- 3. What are top 3 values of total invoice?
SELECT total from invoice
ORDER by total desc
LIMIT 3

-- 4 Which city has the best customers? We would like to throw a promotional Music 
-- Festival in the city we made the most money. Write a query that returns one city that 
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice 
-- totals 

SELECT billing_city, sum(total) as TotalInvoices 
from invoice
GROUP by billing_city
order by TotalInvoices desc

-- 5 Who is the best customer? The customer who has spent the most money will be 
-- declared the best customer. Write a query that returns the person who has spent the 
-- most money

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as s
from customer
join invoice
ON customer.customer_id = invoice.customer_id
GROUP by customer.customer_id
ORDER by s desc
LIMIT 1

--6 Write query to return the email, first name, last name, & Genre of all Rock Music 
-- listeners. Return your list ordered alphabetically by email starting with A

SELECT distinct email, first_name, last_name, genre.name
from customer
join invoice on customer.customer_id= invoice.invoice_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id= track.track_id
join genre on track.genre_id = genre.genre_id
	where genre.name = 'Rock'
order by email asc


--7 Let's invite the artists who have written the most rock music in our dataset. Write a 
-- query that returns the Artist name and total track count of the top 10 rock bands

SELECT artist.name, artist.artist_id, count(artist.artist_id)
from artist
join album on artist.artist_id=album.artist_id
join track on album.album_id=track.album_id
JOIN genre on track.genre_id= genre.genre_id
GROUP by artist.artist_id
order by count(artist.artist_id) DESC
limit 10

--8 Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the 
-- longest songs listed first
SELECT  "name" as na, milliseconds from track
WHERE milliseconds > (
				select avg(milliseconds) from track
)
order by milliseconds desc


--9 Find how much amount spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent

SELECT distinct(c.customer_id), c.first_name, c.last_name, art.name, 
SUM(il.unit_price*il.quantity) AS amount_spent
from customer c
JOIN invoice as i on i.customer_id = c.customer_id
JOIN invoice_line as il on il.invoice_id = i.invoice_id
join track as t on t.track_id = il.track_id
JOIN album as alb on alb.album_id = t.album_id
JOIN artist as art on art.artist_id = alb.artist_id
GROUP by 1,2,3,4
ORDER by amount_spent DESC


--10 We want to find out the most popular music Genre for each country. We determine the 
-- most popular genre as the genre with the highest amount of purchases. Write a query 
-- that returns each country along with the top Genre. For countries where the maximum 
-- number of purchases is shared return all Genres

WITH MostPopulerMusic as(
	SELECT c.country, count(il.quantity) as purchases, g.name as Genre_name,
	ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS RowNo
	from  invoice i
	join customer c on c.customer_id = i.customer_id
	join invoice_line as il on il.invoice_id = i.invoice_id
	JOIN track as t on t.track_id = il.track_id
	JOIN genre as g on g.genre_id= t.genre_id
	GROUP by 1,3
	ORDER by 1 DESC
	)
SELECT * from MostPopulerMusic
where RowNo =1



--11 Write a query that determines the customer that has spent the most on music for each 
-- country. Write a query that returns the country along with the top customer and how
-- much they spent. For countries where the top amount spent is shared, provide all 
-- customers who spent this amount

with high_spent_customer as(
	select c.customer_id, c.first_name, c.last_name, billing_country,sum(i.total) as totalAmount,
	row_number() over (partition by billing_country order by sum(i.total) ) as rownumber
	from invoice i
	join customer c on c.customer_id = i.customer_id
	group by 4,1
	ORDER by 4 ASC
	)
select * from high_spent_customer
where rownumber =1;

