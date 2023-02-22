/**

sometimes we will need to get information from different tables even if it's not in the same database.

The syntax is 

SELECT columns
FROM table1 t1
JOIN table2 t2
    ON t1.col = t2.col;

also if the table that i am joining with has a composite key, i can join them.
SELECT columns
FROM table1 t1
JOIN table2 t2
    ON t1.col = t2.col
    AND t1.col2 = t2.col2;

-- we have also outer joins where LEFT and RIGHT 

RIGHT JOIN is like the Inner join 

but for LEFT JOIN it will return the data that exists in the left table.


-------- Cross Join 
Every table in the t1 table will be combined with every record 
in the t2 table. 
and that's why we don't have a condition here.


*/


