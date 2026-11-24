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


SHOW tables;

-- 7 --
SELECT * FROM department;
SET SQL_SAFE_UPDATES = 0;
DELETE FROM department 
where d_name = 'PQT';

-- 8 ---
SELECT l_name,l_salary from academic_staff
WHERE l_desig = 'Senior Lecturer' ;

-- 9 --
SELECT
    pr_id,
    pr_name,
    pr_budget,
    pr_budget * 0.70 AS university_grant
FROM project;

-- 10 ---
SELECT l_name,l_allowance
FROM academic_staff
WHERE l_allowance = (SELECT MIN(l_allowance) FROM academic_staff);


-- 11 ---
DESC academic_staff;
DESC project;

SELECT DISTINCT
	a.l_name,
    a.l_desig,
    a.l_id,
    p.pr_supervisor
FROM academic_staff a
JOIN project p 
	ON a.l_id = p.pr_supervisor;
    
    
-- 12 ---
SELECT COUNT(w.w_l_id) AS 'Researchers Count'
FROM work w
JOIN project p ON
	w.w_pr_id = p.pr_id
WHERE p.pr_name = 'Eagle Eye';


-- 13 --
SELECT a.l_name
FROM academic_staff a
JOIN work w 
	ON a.l_id = w.w_l_id
GROUP BY a.l_id, a.l_name
HAVING COUNT(w.w_pr_id) > 1;


-- 14 ---
CREATE VIEW all_projects AS
SELECT
    p.pr_id,
    p.pr_name,
    p.pr_budget,
    d.d_name
FROM project p
JOIN department d 
	ON p.pr_d_id = d.d_id;
    
SELECT * FROM all_projects;


-- 15 --
DELIMITER //

CREATE procedure academic_members_for_project(
	IN project_id CHAR(4)
)
BEGIN
	SELECT
		a.l_id,
        a.l_name,
        a.l_desig,
        a.l_salary,
        a.l_allowance,
        d.d_name
	FROM work w
    JOIN academic_staff a
		ON w.w_l_id = a.l_id
	JOIN department d
        ON a.l_d_id = d.d_id
	WHERE w.w_pr_id = project_id;
END //

DELIMITER ;

CALL academic_members_for_project('pr01');