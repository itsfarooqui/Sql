USE TEST;

/*Obtain all orders for the customer named Cisnerous. 
(Assume you don't know his customer no. (cnum)).*/

SELECT * FROM ORDERS
WHERE CNUM = (SELECT CNUM FROM CUST
				WHERE CNAME='CISNEROUS');

/*Produce the names and rating of all customers who have above average orders.*/

SELECT  ONUM, AVG(AMT) AS AVG_AMT
FROM ORDERS GROUP BY ONUM
HAVING AVG(AMT) > 100;

/*Find total amount in orders for each salesperson for whom
this total is greater than the amount of the largest order in the table.*/

Select snum,sum(amt)
from orders
group by snum
having sum(amt) > ( select max(amt)
           from orders);

/*Find all customers with order on 3rd Oct.*/

SELECT * FROM ORDERS;

SELECT * FROM CUST;

Select cname
from cust a, orders b
where a.cnum = b.cnum and
            odate = '03-OCT-94';

/*Find names and numbers of all salesperson who have more than one customer.*/

SELECT SNAME, SNUM
FROM SALESPEOPLE
WHERE SNUM IN (SELECT SNUM FROM CUST
					GROUP BY SNUM
						HAVING COUNT(SNUM) > 1);

/*Check if the correct salesperson was credited with each sale.*/

SELECT ONUM, A.CNUM, A.SNUM, B.SNUM
FROM ORDERS A, CUST B
WHERE A.CNUM = B.CNUM
AND A.SNUM != B.SNUM;

/*Find all orders with above average amounts for their customers.*/

SELECT ONUM, CNUM, AMT
FROM ORDERS A
WHERE AMT > (SELECT AVG(AMT) FROM ORDERS B
				WHERE A.CNUM = B.CNUM
					GROUP BY CNUM);

/*Find the sums of the amounts from order table grouped by date,
eliminating all those dates where the sum was not at least 
2000 above the maximum amount.*/

SELECT ODATE, SUM(AMT)
FROM ORDERS A
GROUP BY ODATE
HAVING SUM(AMT) > (SELECT MAX(AMT) FROM ORDERS B
						WHERE A.ODATE = B.ODATE
						GROUP BY ODATE);

/*Find names and numbers of all customers with ratings equal to the maximum for their city.*/

SELECT A.CNAME, A.CNUM FROM CUST A
WHERE A.RATING = (SELECT MAX(RATING) FROM CUST B
						WHERE A.CITY = B.CITY);

/*Find all salespeople who have customers in their cities who they don't service.
( Both way using Join and Correlated subquery.)*/

SELECT DISTINCT CNAME
FROM CUST A, SALESPEOPLE B
WHERE A.CITY = B.CITY AND A.SNUM != B.SNUM;

SELECT CNAME
FROM CUST
WHERE CNAME IN(SELECT CNAME FROM CUST A, SALESPEOPLE B
					WHERE A.CITY = B.CITY AND A.SNUM != B.SNUM);

/*Extract cnum,cname and city from customer table if and only if one or more of the
customers in the table are located in San Jose.*/

SELECT * FROM CUST
WHERE 2 < (SELECT COUNT(*) FROM CUST
				WHERE CITY = 'SAN JOSE');

/*Find salespeople no. who have multiple customers.*/

SELECT SNUM FROM CUST
GROUP BY SNUM
HAVING COUNT(*) > 1;

/*Find salespeople number, name and city who have multiple customers.*/

SELECT SNUM, SNAME, CITY FROM SALESPEOPLE
WHERE SNUM IN (SELECT SNUM FROM CUST
					GROUP BY SNUM
						HAVING COUNT(*) > 1);

/*Find salespeople who serve only one customer.*/

SELECT SNUM FROM CUST 
GROUP BY SNUM
HAVING COUNT(*) = 1;

/*Extract rows of all salespeople with more than one current order.*/

SELECT SNUM, COUNT(SNUM) FROM ORDERS
GROUP BY SNUM 
HAVING COUNT(SNUM) > 1;

/*Find all salespeople who have customers with a rating of 300. (use EXISTS)*/

SELECT * FROM SALESPEOPLE A
WHERE EXISTS (SELECT B.SNUM FROM CUST B
					WHERE B.RATING = 300 AND A.SNUM = B.SNUM);
					
/*Find all salespeople who have customers with a rating of 300. (use Join).*/

SELECT A.SNUM FROM SALESPEOPLE A, CUST B
WHERE B.RATING = 300 AND A.SNUM = B.SNUM;

/*Select all salespeople with customers located in their cities who are not
assigned to them. (use EXISTS).*/

SELECT A.SNUM, A.SNAME FROM SALESPEOPLE A
WHERE EXISTS ( SELECT B.CNUM FROM CUST B
					WHERE A.CITY = B.CITY AND A.SNUM != B.SNUM);

/*Extract from customers table every customer assigned the a salesperson who
currently has at least one other customer ( besides the customer being selected)
with orders in order table.*/

Select a.cnum, max(c.cname)
from orders a, cust c
where a.cnum = c.cnum
group by a.cnum,a.snum
having count(*) < ( select count(*)
                           from orders b
                           where a.snum = b.snum)
						   order by a.cnum;

/*Find salespeople with customers located in their cities ( using both ANY and IN).*/

SELECT A.SNAME FROM SALESPEOPLE A
WHERE SNUM IN (SELECT SNUM FROM CUST B
					WHERE A.CITY = B.CITY AND A.SNUM = B.SNUM);
SELECT A.SNAME FROM SALESPEOPLE A
WHERE SNUM = ANY(SELECT SNUM FROM CUST B
					WHERE A.CITY = B.CITY AND A.SNUM = B.SNUM);

/*Find all salespeople for whom there are customers that follow them in alphabetical order.
(Using ANY and EXISTS)*/

SELECT A.SNAME FROM SALESPEOPLE A
WHERE SNAME < ANY (SELECT B.CNAME FROM CUST B
						  WHERE A.SNUM = B.SNUM);

SELECT A.SNAME FROM SALESPEOPLE A
WHERE EXISTS (SELECT B.CNAME FROM CUST B
					 WHERE A.SNUM = B.SNUM AND A.SNAME < B.CNAME);

/*Select customers who have a greater rating than any customer in rome.*/

SELECT A.CNAME FROM CUST A
WHERE CITY = 'ROME' AND RATING > (SELECT MAX(RATING) FROM CUST
										 WHERE CITY != 'ROME');

/*Select all orders that had amounts that were greater that atleast one
of the orders from Oct 6th.*/

SELECT ONUM, AMT FROM ORDERS 
WHERE ODATE != '06-10-1994' AND AMT > (SELECT MIN(AMT) FROM ORDERS
											  WHERE ODATE = '06-10-1994');

/*Find all orders with amounts smaller than any amount for a customer in San Jose. 
(Both using ANY and without ANY)*/

SELECT ONUM, AMT FROM ORDERS
WHERE AMT < ANY (SELECT AMT FROM ORDERS, CUST
						WHERE CITY = 'SAN JOSE' AND ORDERS.CNUM = CUST.CNUM);

SELECT ONUM, AMT FROM ORDERS
WHERE AMT < (SELECT MAX(AMT) FROM ORDERS, CUST
					WHERE CITY = 'SAN JOSE' AND ORDERS.CNUM = CUST.CNUM);

/*Select those customers whose ratings are higher than every customer in Paris.
( Using both ALL and NOT EXISTS).*/

SELECT * FROM CUST 
WHERE RATING > ANY (SELECT RATING FROM CUST
					WHERE CITY = 'PARIS');

SELECT * FROM CUST A
WHERE NOT EXISTS (SELECT B.RATING FROM CUST B
					WHERE B.CITY != 'PARIS' AND B.RATING > A.RATING);

/*Select all customers whose ratings are equal to or greater than ANY of the Seeres.*/

Select cname, sname
from cust, salespeople
where rating >= any ( select rating
                      from cust
                      where snum = (select snum
                      from salespeople
                      where sname = 'Serres')
					  and sname != 'Serres'
				      and salespeople.snum(+) = cust.snum);

/*Find all salespeople who have no customers located in their city. ( Both using ANY and ALL)*/

SELECT A.SNAME FROM SALESPEOPLE A
WHERE SNUM IN (SELECT SNUM FROM CUST B
				WHERE A.CITY != B.CITY AND A.SNUM = B.SNUM);

SELECT A.SNAME FROM SALESPEOPLE A
WHERE SNUM = ANY(SELECT SNUM FROM CUST B
				 WHERE A.CITY != B.CITY AND A.SNUM = B.SNUM);

/*Find all orders for amounts greater than any for the customers in London.*/

SELECT ONUM, AMT FROM ORDERS
WHERE AMT > ANY(SELECT AMT FROM ORDERS, CUST
				WHERE CITY='LONDON' AND ORDERS.CNUM = CUST.CNUM);

/*Find all salespeople and customers located in london.*/

SELECT SNAME, CNAME FROM CUST, SALESPEOPLE
WHERE CUST.CITY = 'LONDON' AND
SALESPEOPLE.CITY = 'LONDON' AND
CUST.SNUM = SALESPEOPLE.SNUM;

/*For every salesperson, dates on which highest and lowest orders were brought.*/

Select a.amt, a.odate, b.amt, b.odate
from orders a, orders b
where (a.amt, b.amt) in (select max(amt), min(amt)
    from orders
                                              group by snum);

/*List all of the salespeople and indicate those who don't have customers in their
cities as well as those who do have.*/

SELECT SNUM, CITY, 'CUSTOMER PRESENT' FROM SALESPEOPLE A
WHERE EXISTS (SELECT SNUM FROM CUST
			  WHERE A.SNUM = CUST.SNUM AND A.CITY = CUST.CITY)
UNION
SELECT SNUM, CITY, 'CUSTOMER NOT PRESENT' FROM SALESPEOPLE A
WHERE EXISTS( SELECT SNUM FROM CUST C
			  WHERE A.SNUM = C.SNUM AND
			  A.CITY != C.CITY AND
			  C.SNUM NOT IN (SELECT SNUM FROM CUST WHERE A.SNUM = CUST.SNUM AND
							 A.CITY = CUST.CITY));

/*Append strings to the selected fields, indicating weather or not a given salesperson
was matched to a customer in his city.*/

SELECT A.CNAME, DECODE(A.CITY, B.CITY, 'MATCHED', 'NOT MATCHED')
FROM CUST A, SALESPEOPLE B
WHERE A.SNUM = B.SNUM;

/*Create a union of two queries that shows the names, cities and ratings of all customers.
Those with a rating of 200 or greater will also have the words 'High Rating', while the 
others will have the words 'Low Rating'.*/

SELECT CNAME, CITY, RATING, 'HIGHER RATING' FROM CUST
WHERE RATING >= 200
UNION
SELECT CNAME, CITY, RATING, 'LOWER RATING' FROM CUST
WHERE RATING < 200;

/*Write command that produces the name and number of each salesperson and each customer with
more than one current order. Put the result in alphabetical order.*/

Select 'Customer Number ' || cnum "Code ",count(*)
from orders
group by cnum
having count(*) > 1
UNION
select 'Salesperson Number '||snum,count(*)
from orders
group by snum
having count(*) > 1;

/*Form a union of three queries. Have the first select the snums of all salespeople in
San Jose, then second the cnums of all customers in San Jose and the third the onums of
all orders on Oct. 3. Retain duplicates between the last two queries, but eliminates and 
redundancies between either of them and the first.*/

Select 'Customer Number ', cnum "Code "
from cust
where city = 'San Jose'
UNION
select 'Salesperson Number ',snum
from salespeople
where city = 'San Jose'
UNION ALL
select 'Order Number ', onum
from Orders
where odate = '03-OCT-94';

/*Produce all the salesperson in London who had at least one customer there.*/

Select snum, sname
from salespeople
where snum in ( select snum
   from cust
   where cust.snum = salespeople.snum and
         cust.city = 'London')
         and city = 'London';

/*Produce all the salesperson in London who did not have customers there.*/

Select snum, sname
from salespeople
where snum in ( select snum
				from cust
                where cust.snum = salespeople.snum and
                cust.city = 'London')
                and city = 'London';

/*We want to see salespeople matched to their customers without excluding those
salesperson who were not currently assigned to any customers. (User OUTER join and UNION)*/

Select sname, cname
from cust, salespeople
where cust.snum(+) = salespeople.snum;

Select sname, cname
from cust, salespeople
where cust.snum = salespeople.snum
UNION
select distinct sname, 'No Customer'
from cust, salespeople
where 0 = (select count(*) from cust
where cust.snum = salespeople.snum);













