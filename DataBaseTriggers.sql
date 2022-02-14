/*1.- Your boss has tasked you with creating a trigger to log anytime someone updates the customers table. There is already a procedure to insert into the customers_log table called log_customers_change(). This function will create a record in customers_log and we want it to fire anytime an UPDATE statement modifies first_name or last_name. Give the trigger an appropriate name. Are there other situations you might suggest creating triggers for as well?*/

SELECT * FROM customers;

CREATE TRIGGER logUpdate
  BEFORE UPDATE ON customers
  FOR EACH ROW
  EXECUTE PROCEDURE log_customers_change();

/*2.- Can you confirm your trigger is working as expected? Remember, it should only create a log for changes to first_name and/or last_name. We know what the state of the customers and customers_log tables are from our previous check so we can go directly to testing your trigger.*/

UPDATE customers
SET first_name = 'Hattori'
WHERE last_name = 'Lewis';

SELECT *
FROM customers;
 
SELECT *
FROM customers_log;

/*3.- You should also check when you expect it to NOT create a record in customers_log as well as when you would expect it to. Since we confirmed the state of the two tables at the end of our first task, we don’t need to check the starting state again, we can jump right to the modification. Confirm no log is created when modifying a column not covered by the trigger function.*/

UPDATE customers
SET years_old = 10
WHERE last_name = 'Lewis';

SELECT *
FROM customers_log;

/*4.- You suggested to your boss that INSERT statements should also be included (you had also suggested DELETE and TRUNCATE be covered as well, but legal thought this wasn’t needed for some reason). They agreed, but thought that tracking every row for inserts wasn’t necessary — a single record of who did the bulk insert would be enough. Create the trigger to call the log_customers_change procedure once for every statement on INSERT to the customers table. Call it customer_insert.

If you are interested in how the function works, see the hint.*/

CREATE TRIGGER customerInsert
    AFTER INSERT ON customers
    FOR EACH STATEMENT
    EXECUTE PROCEDURE log_customers_change();

/*5.- Add three names to the customers table in one statement. Is your trigger working as expected and only inserting one row per insert statement, not per record? What would the log look like if you had your trigger fire on every row?

To complete these steps you’ll need to do the following:

Use INSERT INTO customers to add three records to the customers table. For example, one record could look like ('Jeffrey','Cook','Jeffrey.Cook@example.com','202-555-0398','Jersey city','New Jersey',66)
SELECT * for the customers table and ORDER BY customer_id
SELECT * for the customers_log table.*/
INSERT INTO customers (first_name, last_name, years_old)
VALUES 
  ('Hattori', 'Hamzo', 24),
  ('Critical', 'Haisenberg', 31),
  ('Mr', 'A', 24);

SELECT *
FROM customers;

select * 
FROM customers_log;

/*6.- Your boss has changed their mind again, and now has decided that the conditionals for when a change occurs should be on the trigger and not on the function it calls.

In this example, we’ll be using the function override_with_min_age(). The trigger should detect when age is updated to be below 13 and call this function. This function will assume this was a mistake and override the change and set the age to be 13. Name your trigger something appropriately, we called ours customer_min_age. What will happen with the customers and customers_log tables?*/

CREATE TRIGGER customer_minAge
    BEFORE UPDATE ON customers
    FOR EACH ROW
    WHEN (NEW.years_old < 13)
    EXECUTE PROCEDURE override_with_min_age();

/*7.- Let’s test this trigger — two more changes to the customers table have come in. Modify one record to set their age under 13 and another over 13, then check the results in the customers and customers_log table. Note, setting it to exactly 13 would still work, it would just be harder to confirm your trigger was working as expected. What do you expect to happen and why?*/

UPDATE customers
SET years_old = 10
WHERE last_name = 'Hamzo';
 
UPDATE customers
SET years_old = 24
WHERE last_name = 'Haisenberg';
 
SELECT *
FROM customers;
 
SELECT *
FROM customers_log;

/*8.- What would happen if you had an update on more columns at once, say modifications to the first_name and years_old in the same query? Try this now then run your check on customers (with the order we have been using) and customers_log*/

UPDATE customers
SET years_old = 6,
    first_name = 'Edward'
WHERE last_name = 'Lewis';
 
SELECT *
FROM customers;
 
SELECT *
FROM customers_log;

/*9.- Though your trigger setting the years_old to never be under 13 is working, a better way to do the same thing would be with a constraint on the column itself. For now, let’s remove the trigger we created to set the minimum age. Ours was called customer_min_age.*/

DROP TRIGGER 
IF EXISTS customer_minAge ON customers;

/*10.- Take a look at the triggers on the system to ensure your removal worked correctly.*/

SELECT * FROM information_schema.triggers;