CREATE DATABASE IF NOT EXISTS pr03;
USE pr03;

-- 1 --
CREATE TABLE Department (
    DID INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255)
);

CREATE TABLE Role (
    RID INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255)
);

CREATE TABLE Login (
    UID VARCHAR(10) PRIMARY KEY,
    Username VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(100) NOT NULL
);

CREATE TABLE Employee (
    EID VARCHAR(10) PRIMARY KEY,
    E_fname VARCHAR(50) NOT NULL,
    E_lname VARCHAR(50) NOT NULL,
    E_phone VARCHAR(20),
    E_email VARCHAR(100),
    Age INT,
    DID INT,
    RID INT,
    UID VARCHAR(10) UNIQUE,
    FOREIGN KEY (DID) REFERENCES Department(DID),
    FOREIGN KEY (RID) REFERENCES Role(RID),
    FOREIGN KEY (UID) REFERENCES Login(UID)
);


-- 2 ---

INSERT INTO Department (name, description) VALUES
('Science', 'Science dep'),
('IT', 'IT dep'),
('Maths', 'Maths dep'),
('ET', 'ET dep'),
('BST', 'BST dep');

INSERT INTO Role (name, description) VALUES
('QA Engineer', 'Role 1'),
('SE Engineer', 'Role 2'),
('Project Manager', 'Role 3'),
('Business Analyst', 'Role 4'),
('Technical Consultant', 'Role 5');

INSERT INTO Login (UID, Username, Password) VALUES
('001', 'sarath', 's12'),
('002', 'kamal', 'k12'),
('003', 'amali', 'a12'),
('004', 'shani', 's21'),
('005', 'nimesha', 'n12');

INSERT INTO Employee (EID, E_fname, E_lname, E_phone, E_email, Age, DID, RID, UID) VALUES
('E001', 'Sarath', 'Weerasinghe', '0715267893', 'abcsarath@gmail.com', 22, 1, 1, '001'),
('E002', 'Kamal', 'Nadhun', '0778945613', 'abckamal@gmail.com', 58, 2, 2, '002'),
('E003', 'Amali', 'Sadamini', '0725468134', 'abcamali@gmail.com', 45, 3, 3, '003'),
('E004', 'Shani', 'Arosha', '0707775552', 'abcshani@gmail.com', 25, 4, 4, '004'),
('E005', 'Nimesha', 'Sewwandi', '0768882225', 'abcnimesha@gmail.com', 30, 5, 5, '005');



-- 3. Get all details of all employees
DELIMITER //

CREATE PROCEDURE sp_GetAllEmployees()
BEGIN
    SELECT * FROM Employee;
END //

DELIMITER ;

CALL sp_GetAllEmployees();

-- 4 ---
DELIMITER //
CREATE procedure sp_GetAllEmployeesByID(IN p_EID VARCHAR(10))
BEGIN
	SELECT * FROM Employee e
    WHERE e.EID = p_EID;
END //
DELIMITER ;


CALL sp_GetAllEmployeesByID('E001');




-- 5. Get all details of all departments
DELIMITER //
CREATE PROCEDURE sp_GetAllDepartments()
BEGIN
    SELECT * FROM Department;
END //

-- 6. Get all details of all roles
CREATE PROCEDURE sp_GetAllRoles()
BEGIN
    SELECT * FROM Role;
END //

-- 7. Get all details of all login records
CREATE PROCEDURE sp_GetAllLogins()
BEGIN
    SELECT * FROM Login;
END //

DELIMITER ;


-- 8. Display all employee records whose ages are greater than 30
DELIMITER //
CREATE PROCEDURE sp_GetEmployeesAgeAbove30()
BEGIN
    SELECT * FROM Employee WHERE Age > 30;
END //


-- 9 ---
DELIMITER //
CREATE PROCEDURE get_lName(
	IN p_EID VARCHAR(10),
    OUT l_Name VARCHAR(100)
)
BEGIN
	SELECT E_lname INTO l_Name
    FROM Employee
    WHERE EID = p_EID;
END //

DELIMITER ;

CALL get_lName('E002', @l_Name);
SELECT @l_Name;

-- 10. Stored procedure usp_GetFirstName accepting employee ID and returning first name
DELIMITER //

CREATE PROCEDURE usp_GetFirstName(
    IN p_EID VARCHAR(10),
    OUT p_FirstName VARCHAR(50)
)
BEGIN
    SELECT E_fname INTO p_FirstName
    FROM Employee
    WHERE EID = p_EID;
END //


-- 11. Get department name of an employee by employee ID
CREATE PROCEDURE sp_GetDepartmentNameByEmpId(
    IN p_EID VARCHAR(10),
    OUT p_DeptName VARCHAR(100)
)
BEGIN
    SELECT d.name INTO p_DeptName
    FROM Employee e
    JOIN Department d ON e.DID = d.DID
    WHERE e.EID = p_EID;
END //


-- 12. Get role name of an employee by employee ID
DELIMITER //
CREATE PROCEDURE sp_GetRoleNameByEmpId(
    IN p_EID VARCHAR(10),
    OUT p_RoleName VARCHAR(100)
)
BEGIN
    SELECT r.name INTO p_RoleName
    FROM Employee e
    JOIN Role r ON e.RID = r.RID
    WHERE e.EID = p_EID;
END //

-- 13. Given a department ID, count employees in that department
CREATE PROCEDURE sp_CountEmployeesByDeptId(
    IN p_DID INT,
    OUT p_EmpCount INT
)
BEGIN
    SELECT COUNT(*) INTO p_EmpCount
    FROM Employee
    WHERE DID = p_DID;
END //

-- 14. Get login details of a specific employee by employee ID
CREATE PROCEDURE sp_GetLoginByEmpId(IN p_EID VARCHAR(10))
BEGIN
    SELECT l.UID, l.Username, l.Password
    FROM Employee e
    JOIN Login l ON e.UID = l.UID
    WHERE e.EID = p_EID;
END //

DELIMITER ;


CALL sp_GetRoleNameByEmpId('E002', @role); SELECT @role;
CALL sp_CountEmployeesByDeptId(2, @cnt); SELECT @cnt;
CALL sp_GetLoginByEmpId('E003');

-- 15 ----
CREATE TABLE studentMarks (
    stud_id INT AUTO_INCREMENT PRIMARY KEY,
    total_marks INT NOT NULL,
    grade VARCHAR(5) NOT NULL
);

INSERT INTO studentMarks (total_marks, grade) VALUES
(450, 'A'), (480, 'A+'), (490, 'A++'), (440, 'B+'), (400, 'C+'), (380, 'C'),
(250, 'D'), (200, 'E'), (100, 'F'), (150, 'F'), (220, 'E');


DELIMITER //

-- 16. Get all data from studentMarks
CREATE PROCEDURE sp_GetAllStudentMarks()
BEGIN
    SELECT * FROM studentMarks;
END //

-- 17. Fetch student details by given student ID
CREATE PROCEDURE sp_GetStudentById(IN p_stud_id INT)
BEGIN
    SELECT * FROM studentMarks WHERE stud_id = p_stud_id;
END //

-- 18. Calculate average marks and return as an OUT parameter
CREATE PROCEDURE sp_GetAverageMarks(OUT p_avg_marks DECIMAL(10,2))
BEGIN
    SELECT AVG(total_marks) INTO p_avg_marks
    FROM studentMarks;
END //



-- 19. Count of students with marks below the average marks
CREATE PROCEDURE sp_CountBelowAverage(OUT p_below_avg_count INT)
BEGIN
    DECLARE v_avg DECIMAL(10,2);
    SELECT AVG(total_marks) INTO v_avg FROM studentMarks;

    SELECT COUNT(*) INTO p_below_avg_count
    FROM studentMarks
    WHERE total_marks < v_avg;
END //

-- 20. Function that takes an initial counter value and increments it by a given number
CREATE FUNCTION fn_IncrementCounter(p_initial INT, p_increment INT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN p_initial + p_increment;
END //

-- 21. Procedure spGetIsAboveAverage returning 1 (above avg) or 0 (not above avg)
CREATE PROCEDURE spGetIsAboveAverage(
    IN p_stud_id INT,
    OUT p_is_above INT
)
BEGIN
    DECLARE v_avg DECIMAL(10,2);
    DECLARE v_marks INT;

    SELECT AVG(total_marks) INTO v_avg FROM studentMarks;
    SELECT total_marks INTO v_marks FROM studentMarks WHERE stud_id = p_stud_id;

    IF v_marks > v_avg THEN
        SET p_is_above = 1;
    ELSE
        SET p_is_above = 0;
    END IF;
END //



-- 22. Procedure spGetStudentResult calling spGetIsAboveAverage -> PASS or FAIL
CREATE PROCEDURE spGetStudentResult(
    IN p_stud_id INT,
    OUT p_result VARCHAR(10)
)
BEGIN
    DECLARE v_above INT;

    CALL spGetIsAboveAverage(p_stud_id, v_above);

    IF v_above = 1 THEN
        SET p_result = 'PASS';
    ELSE
        SET p_result = 'FAIL';
    END IF;
END //

-- 23. Procedure returning class based on studentId marks
CREATE PROCEDURE sp_GetStudentClass(
    IN p_stud_id INT,
    OUT p_class VARCHAR(20)
)
BEGIN
    DECLARE v_marks INT;

    SELECT total_marks INTO v_marks
    FROM studentMarks
    WHERE stud_id = p_stud_id;

    IF v_marks >= 400 THEN
        SET p_class = 'First Class';
    ELSEIF v_marks >= 300 AND v_marks < 400 THEN
        SET p_class = 'Second Class';
    ELSE
        SET p_class = 'Failed';
    END IF;
END //

DELIMITER ;


CALL sp_GetAverageMarks(@avg); SELECT @avg;
CALL sp_CountBelowAverage(@below); SELECT @below;
SELECT fn_IncrementCounter(10, 5) AS incremented_value;
CALL spGetIsAboveAverage(1, @is_above); SELECT @is_above;
CALL spGetStudentResult(1, @res); SELECT @res;
CALL sp_GetStudentClass(6, @cls); SELECT @cls;


DELIMITER //

-- 24. EXIT handler on duplicate primary key (stud_id)
CREATE PROCEDURE spInsertStudentDataExit(
    IN p_studentId INT,
    IN p_total_marks INT,
    IN p_grade VARCHAR(5),
    OUT rowCount INT
)
BEGIN
    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        SELECT COUNT(*) INTO rowCount FROM studentMarks;
        SELECT CONCAT('Error: Duplicate student ID ', p_studentId, ' cannot be inserted.') AS ErrorMessage;
    END;

    INSERT INTO studentMarks (stud_id, total_marks, grade)
    VALUES (p_studentId, p_total_marks, p_grade);

    SELECT COUNT(*) INTO rowCount FROM studentMarks;
END //

-- 25. CONTINUE handler on duplicate primary key (stud_id)
CREATE PROCEDURE spInsertStudentDataContinue(
    IN p_studentId INT,
    IN p_total_marks INT,
    IN p_grade VARCHAR(5),
    OUT rowCount INT
)
BEGIN
    DECLARE CONTINUE HANDLER FOR 1062
    BEGIN
        SELECT CONCAT('Warning: Duplicate student ID ', p_studentId, ' skipped.') AS WarningMessage;
    END;

    INSERT INTO studentMarks (stud_id, total_marks, grade)
    VALUES (p_studentId, p_total_marks, p_grade);

    SELECT COUNT(*) INTO rowCount FROM studentMarks;
END //

DELIMITER ;
