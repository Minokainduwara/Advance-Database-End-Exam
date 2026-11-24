

-- 4 ----
CREATE DATABASE pr02;
USE pr02;


-- 5 ----
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL,
    phone       VARCHAR(25) NULL,
    email       VARCHAR(100) NULL,
    street      VARCHAR(100) NULL,
    city        VARCHAR(50) NULL,
    state       VARCHAR(20) NULL,
    zip_code    VARCHAR(15) NULL
);

INSERT INTO customers (customer_id, first_name, last_name, phone, email, street, city, state, zip_code)
VALUES
    (1,  'Miriam',     'Baker',    NULL,             'miriam.baker@hotmail.com',   '90 Studebaker St.',       'Uniondale',      'NY', '11553'),
    (2,  'Jeanie',     'Kirkland', NULL,             'jeanie.kirkland@aol.com',    '7643 Old Theatre St.',    'Santa Clara',    'CA', '95050'),
    (3,  'Marquerite', 'Dawson',   NULL,             'marquerite.dawson@gmail.com','37 Hamilton Court',       'Garland',        'TX', '75043'),
    (4,  'Babara',     'Ochoa',    NULL,             'babara.ochoa@aol.com',       '872 Smith Store St',      'Scarsdale',      'NY', '10583'),
    (5,  'Nova',       'Hess',     NULL,             'nova.hess@msn.com',          '773 South Lafayette St.', 'Duarte',         'CA', '91010'),
    (6,  'Carley',     'Reynolds', NULL,             'carley.reynolds@gmail.com',  '2 Snake Hill Drive',      'South El Monte', 'CA', '91733'),
    (7,  'Carissa',    'Foreman',  NULL,             'carissa.foreman@msn.com',    '69C N. Ridge Rd.',        'Maspeth',        'NY', '11378'),
    (8,  'Genoveva',   'Tyler',    '(212) 152-6381', 'genoveva.tyler@gmail.com',   '8121 Windfall Ave.',      'New York',       'NY', '10002'),
    (9,  'Deane',      'Sears',    NULL,             'deane.sears@hotmail.com',    '3 Bradford Court',        'Pittsford',      'NY', '14534'),
    (10, 'Karey',      'Steele',   NULL,             'karey.steele@gmail.com',     '8879 Kent Lane',          'Farmingdale',    'NY', '11735'),
    (11, 'Lena',       'Mills',    NULL,             'lena.mills@yahoo.com',       '42 Homestead St',         'Woodhaven',      'NY', '11421');
 
 
 
 -- 6 method 1 ----
 
CREATE OR REPLACE VIEW vw_customer_names AS
SELECT
	customer_id,
    concat_ws(' ',first_name,last_name) AS full_name
FROM customers;

-- Output (first 10 rows matching your sample)
SELECT customer_id,full_name 
FROM vw_customer_names
LIMIT 10;




-- 6 Method 2 Using an Stored Procedure --
DELIMITER //
CREATE procedure get_customer_fname()
BEGIN 
	SELECT
    	customer_id,
		concat_ws(' ',first_name,last_name) AS full_name
        FROM customers
        limit 10;
END //

DELIMITER ;

CALL get_customer_fname();


-- 6 method 3 using scalar function take one customer name and give the full name---
DELIMITER //

CREATE FUNCTION fn_GetCustomerFullName(p_customer_Id INT)
RETURNS VARCHAR(105)
deterministic
reads sql data
BEGIN
	DECLARE v_full_name varchar(105);
    
    SELECT concat_ws(' ',first_name,last_name) INTO v_full_name
    from customers
    where customer_id = p_customer_Id;
    RETURN v_full_name;
END //

DELIMITER ;

-- Use it alongside customer_id
SELECT
    customer_id,
    fn_GetCustomerFullName(customer_id) AS Name
FROM customers
LIMIT 10;
    
    
-- 7 ----
CREATE TABLE Employee (
    ID      INT PRIMARY KEY,
    NAME    VARCHAR(50) NOT NULL,
    AGE     INT NOT NULL,
    ADDRESS VARCHAR(100) NOT NULL,
    SALARY  DECIMAL(10, 2) NOT NULL
);

INSERT INTO Employee (ID, NAME, AGE, ADDRESS, SALARY)
VALUES
    (1, 'Ramesh',   32, 'Ahmedabad', 2000.00),
    (2, 'Khilan',   25, 'Delhi',     1500.00),
    (3, 'kaushik',  23, 'Kota',      2000.00),
    (4, 'Chaitali', 25, 'Mumbai',    6500.00),
    (5, 'Hardik',   27, 'Bhopal',    8500.00),
    (6, 'Komal',    22, 'MP',        4500.00);


-- 8 ---
DELIMITER //
CREATE FUNCTION get_emp_avg()
RETURNS DECIMAL(10,2)
deterministic
reads sql data
BEGIN
	DECLARE avg_salary DECIMAL(10,2);
    
    SELECT avg(SALARY)
    INTO avg_salary
    from Employee;
    
    RETURN avg_salary;
END //

DELIMITER ;

-- Test --
SELECT get_emp_avg() AS AverageSalary;


    
 
 
 
 
 
 
 
 
 
    
