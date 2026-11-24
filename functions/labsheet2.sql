

-- 1 ----
CREATE DATABASE pr02;
USE pr02;


-- 2 ----
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
 
 
 
 -- 3 method 1 ----
 
CREATE OR REPLACE VIEW vw_customer_names AS
SELECT
	customer_id,
    concat_ws('',first_name,last_name) AS full_name
FROM customers;

-- Output (first 10 rows matching your sample)
SELECT customer_id,full_name 
FROM vw_customer_names
LIMIT 10;

-- 3 Methos 2 Using an Stored Procedure --
 
 
 
 
 
 
 
 
 
 
 
    
