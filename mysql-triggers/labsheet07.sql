CREATE database pr07;
USE pr07;

-- 1 ----

CREATE TABLE Student (
    Student_id INT PRIMARY KEY,
    Name VARCHAR(100),
    Address VARCHAR(255),
    Marks INT
);

INSERT INTO Student (Student_id, Name, Address, Marks) VALUES
(1, 'Billie', 'NY', 220),
(2, 'Eilish', 'London', 190),
(3, 'Ariana', 'Miami', 180);

DELIMITER //
CREATE TRIGGER  trg_ad_m
BEFORE INSERT 
	ON student for each row
    BEGIN
		SET NEW.Marks = NEW.Marks + 100;
	END //
DELIMITER ;

CREATE TABLE Student_marks (
    Student_id INT PRIMARY KEY,
    m1 INT,
    m2 INT,
    m3 INT,
    Total INT,
    Average DECIMAL(6,2)
);

-- b --
DELIMITER //

CREATE TRIGGER trg_calc_total_avg_before_insert
BEFORE INSERT 
	ON Student_marks FOR EACH ROW
    BEGIN
     SET NEW.Total = NEW.m1 + NEW.m1 + NEW.m2 + NEW.m3;
     SET NEW.Average = Average/3;
END //


    



-- 2 --- 

CREATE TABLE Student_Trigger (
    Student_RollNO INT NOT NULL PRIMARY KEY,
    Student_FirstName VARCHAR(100),
    Student_EnglishMarks INT,
    Student_PhysicsMarks INT,
    Student_ChemistryMarks INT,
    Student_MathsMarks INT,
    Student_TotalMarks INT,
    Student_Percentage DECIMAL(5,2)
);

DESCRIBE Student_Trigger;

DELIMITER //

CREATE TRIGGER trg_student_marks_before_insert
BEFORE INSERT ON Student_Trigger
FOR EACH ROW
BEGIN
    SET NEW.Student_TotalMarks =
        NEW.Student_EnglishMarks +
        NEW.Student_PhysicsMarks +
        NEW.Student_ChemistryMarks +
        NEW.Student_MathsMarks;

    SET NEW.Student_Percentage = (NEW.Student_TotalMarks / 400.0) * 100;
END //

DELIMITER ;



-- 3 --- 

CREATE TABLE tbl_product (
    pro_id INT PRIMARY KEY,
    pro_price DECIMAL(10,2),
    pro_sprice DECIMAL(10,2),
    pro_qunatity INT,
    reorder_qty INT
);

CREATE TABLE tbl_proreorder (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pro_id INT,
    quantity INT,
    FOREIGN KEY (pro_id) REFERENCES tbl_product(pro_id)
);


DELIMITER //

CREATE TRIGGER trg_reorder_after_update
AFTER UPDATE ON tbl_product
FOR EACH ROW
BEGIN
    IF NEW.pro_qunatity = NEW.reorder_qty THEN
        INSERT INTO tbl_proreorder (pro_id, quantity)
        VALUES (NEW.pro_id, NEW.pro_qunatity);
    END IF;
END //

DELIMITER ;


-- 4 ---

CREATE TABLE Department (
    Depid INT PRIMARY KEY,
    Depname VARCHAR(100)
);

CREATE TABLE Employee (
    Empid INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    Age INT,
    Address VARCHAR(255),
    Depid INT
);


DELIMITER //

CREATE TRIGGER trg_delete_employees_after_dept_delete
AFTER DELETE ON Department
FOR EACH ROW
BEGIN
    DELETE FROM Employee
    WHERE Depid = OLD.Depid;
END //

DELIMITER ;



-- 5 ---

CREATE TABLE Locations (
    LocationID INT,
    LocName VARCHAR(100)
);

CREATE TABLE LocationHist (
    LocationID INT,
    ModifiedDate DATETIME
);


DELIMITER //

CREATE TRIGGER trg_locations_after_update
AFTER UPDATE ON Locations
FOR EACH ROW
BEGIN
    INSERT INTO LocationHist (LocationID, ModifiedDate)
    VALUES (NEW.LocationID, NOW());
END //

DELIMITER ;


-- 6 --

CREATE TABLE book_det (
    bid INT PRIMARY KEY,
    btitle VARCHAR(100),
    copies INT
);

CREATE TABLE book_issue (
    issue_id INT AUTO_INCREMENT PRIMARY KEY,
    bid INT,
    sid INT,
    btitle VARCHAR(100),
    FOREIGN KEY (bid) REFERENCES book_det(bid)
);

INSERT INTO book_det (bid, btitle, copies) VALUES
(1, 'Java', 10),
(2, 'C++', 5),
(3, 'MySql', 10),
(4, 'Oracle DBMS', 5);


DELIMITER //

CREATE TRIGGER trg_decrement_copies_after_issue
AFTER INSERT ON book_issue
FOR EACH ROW
BEGIN
    UPDATE book_det
    SET copies = copies - 1
    WHERE bid = NEW.bid;
END //

DELIMITER ;


-- 7 ---

CREATE TABLE salesman (
    salesman_id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(100),
    commission DECIMAL(4,2)
);

INSERT INTO salesman (salesman_id, name, city, commission) VALUES
(5001, 'James Hoog', 'New York', 0.15),
(5002, 'Nail Knite', 'Paris', 0.13),
(5005, 'Pit Alex', 'London', 0.11),
(5006, 'Mc Lyon', 'Paris', 0.14),
(5007, 'Paul Adam', 'Rome', 0.13),
(5003, 'Lauson Hen', 'San Jose', 0.12);

CREATE VIEW ny_salesmen AS
SELECT *
FROM salesman
WHERE city = 'New York';
	