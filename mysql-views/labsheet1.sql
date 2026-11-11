CREATE database pr01;
use pr01;

CREATE TABLE academic_staff (
    l_id CHAR(3) PRIMARY KEY,
    l_d_id CHAR(3),
    l_name VARCHAR(30),
    l_desig VARCHAR(20),
    l_salary DECIMAL(9,2),
    l_allowance DECIMAL(9,2)
);

INSERT INTO academic_staff
(l_id, l_d_id, l_name, l_desig, l_salary, l_allowance)
VALUES
('l01', 'd01', 'Kasun', 'Lecturer', 35000, 15000),
('l02', 'd02', 'Mahesh', 'Senior Lecturer', 45000, 18000),
('l03', 'd03', 'Udaya', 'Professor', 62000, 28000),
('l04', 'd01', 'Nadun', 'Senior Lecturer', 45000, 20000);


SELECT * FROM academic_staff;

CREATE TABLE department (
    d_id CHAR(3) PRIMARY KEY,
    d_name VARCHAR(5),
    d_head CHAR(3),
    FOREIGN KEY (d_head) REFERENCES academic_staff(l_id)
);

INSERT INTO department (d_id, d_name, d_head)
VALUES
('d01', 'ICT', 'l04'),
('d02', 'ENT', 'l02'),
('d03', 'BT', 'l03'),
('d04', 'PQT', 'l01');

SELECT * FROM department;

CREATE TABLE project (
    pr_id CHAR(4) PRIMARY KEY,
    pr_d_id CHAR(3),
    pr_name VARCHAR(20),
    pr_supervisor CHAR(3),
    pr_budget DECIMAL(9,2),

    FOREIGN KEY (pr_d_id) REFERENCES department(d_id),
    FOREIGN KEY (pr_supervisor) REFERENCES academic_staff(l_id)
);

INSERT INTO project
(pr_id, pr_d_id, pr_name, pr_supervisor, pr_budget)
VALUES
('pr01', 'd01', 'Eagle Eye', 'l01', 300000),
('pr02', 'd02', 'Hill Climber', 'l02', 250000),
('pr03', 'd03', 'Glowing Fish', 'l03', 400000);


CREATE TABLE work (
    w_pr_id CHAR(4),
    w_l_id CHAR(3),

    FOREIGN KEY (w_pr_id) REFERENCES project(pr_id),
    FOREIGN KEY (w_l_id) REFERENCES academic_staff(l_id),

    PRIMARY KEY (w_pr_id, w_l_id)
);

INSERT INTO work (w_pr_id, w_l_id)
VALUES
('pr01', 'l01'),
('pr02', 'l01'),
('pr01', 'l02'),
('pr01', 'l04'),
('pr02', 'l03'),
('pr01', 'l03'),
('pr03', 'l03');


-- 03 ----
ALTER TABLE academic_staff
ADD CONSTRAINT fk_department
foreign key(l_d_id)
REFERENCES department(d_id);

-- 04 ----
SELECT * FROM academic_staff;

-- 05 ----
SET SQL_SAFE_UPDATES = 0;

UPDATE department
SET d_name = "BST"
WHERE d_name = "BT";

SET SQL_SAFE_UPDATES = 0;