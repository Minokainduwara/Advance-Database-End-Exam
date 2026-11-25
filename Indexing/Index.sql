-- 1 ----
CREATE DATABASE pr04;
USE pr04;


-- 2 ----
CREATE TABLE Employee (
    EmployeeID INT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100),
    HireDate DATE,
    DepartmentID INT
);

-- 3 ---
INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, HireDate, DepartmentID) VALUES
(1, 'Kamal', 'Perera', 'kamal.perera@example.lk', '2021-05-12', 1),
(2, 'Nimal', 'Fernando', 'nimal.fernando@example.lk', '2020-08-23', 2),
(3, 'Sunil', 'Silva', 'sunil.silva@example.lk', '2019-11-05', 1),
(4, 'Chathura', 'Kumarasinghe', 'chathura.kumarasinghe@example.lk', '2022-02-14', 3),
(5, 'Dilshan', 'Jayawardena', 'dilshan.jayawardena@example.lk', '2021-07-29', 3),
(6, 'Aruna', 'Weerasinghe', 'aruna.weerasinghe@example.lk', '2023-01-11', 2),
(7, 'Malkanthi', 'Rathnayake', 'malkanthi.rathnayake@example.lk', '2020-09-18', 5),
(8, 'Ruwan', 'De Silva', 'ruwan.desilva@example.lk', '2018-06-30', 4),
(9, 'Saman', 'Senanayake', 'saman.senanayake@example.lk', '2021-04-10', 6),
(10, 'Indika', 'Karunaratne', 'indika.karunaratne@example.lk', '2019-12-25', 4);


-- 4 ----
ALTER TABLE Employee
ADD PRIMARY KEY(EmployeeID);

DESC Employee;




-- 5 ----
CREATE TABLE department (
    DepartmentID INT AUTO_INCREMENT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL,
    Location VARCHAR(50)
);


-- 6 -----
INSERT INTO department (DepartmentID, DepartmentName, Location) VALUES
(1, 'Web Development', 'LOC001'),
(2, 'Mobile Development', 'LOC002'),
(3, 'Cloud Engineering', 'LOC003'),
(4, 'Digital Marketing', 'LOC004'),
(5, 'Business Inteligence', 'LOC005'),
(6, 'Employee Training', 'LOC006');

-- 7 ---
ALTER TABLE Employee
ADD constraint fk_dep
foreign key(DepartmentID) references department(DepartmentID);

-- 8 ---
ALTER TABLE Employee
DROP primary key;


-- 9 ---
ALTER TABLE Employee
DROP FOREIGN KEY fk_dep;

ALTER TABLE Employee
ADD primary key(DepartmentID);


-- 10 ---
CREATE TABLE project (
    ProjectID INT AUTO_INCREMENT PRIMARY KEY,
    ProjectName VARCHAR(100) NOT NULL,
    StartDate DATE,
    EndDate DATE
);



-- 11 ---
INSERT INTO project (ProjectID, ProjectName, StartDate, EndDate) VALUES
(1, 'Website design', '2024-01-10', '2024-03-15'),
(2, 'Mobile App Development', '2024-02-01', '2024-06-30'),
(3, 'Cloud Migration', '2024-03-01', '2024-10-30'),
(4, 'Data Analytics Initiative', '2024-04-15', '2024-09-30'),
(5, 'Digital Marketing Campaign', '2024-05-01', '2024-07-30'),
(6, 'Employee Training Program', '2024-06-01', '2024-08-01');

-- 12 ---
CREATE TABLE EmloyeeProjects (
    EmployeeID INT,
    DepartmentID INT,
    ProjectID INT,
    PRIMARY KEY (EmployeeID, ProjectID),
    CONSTRAINT fk_ep_department FOREIGN KEY (DepartmentID) REFERENCES department(DepartmentID),
    CONSTRAINT fk_ep_project FOREIGN KEY (ProjectID) REFERENCES project(ProjectID)
);

-- 13 Non Clustered Index--
CREATE INDEX idx_employee_firstname
ON Employee (FirstName);

-- 14 Unique Index--
CREATE UNIQUE INDEX idx_email
ON Employee(email);

-- 15 Composite Unique Index--
CREATE UNIQUE INDEX com_un_idx_dep
ON department(DepartmentName, Location);


-- 16 --
ALTER TABLE Employee
ADD COLUMN ContactNumber VARCHAR(15),
ADD COLUMN City VARCHAR(50),
ADD COLUMN District VARCHAR(50),
ADD COLUMN Province VARCHAR(50);


-- 17 --

SET SQL_SAFE_UPDATES = 0;

UPDATE Employee SET ContactNumber = '0771234567', City = 'Colombo',     District = 'Colombo',     Province = 'Western'      WHERE EmployeeID = 1;
UPDATE Employee SET ContactNumber = '0752233445', City = 'Galle',       District = 'Galle',       Province = 'Southern'     WHERE EmployeeID = 2;
UPDATE Employee SET ContactNumber = '0719876543', City = 'Kandy',       District = 'Kandy',       Province = 'Central'      WHERE EmployeeID = 3;
UPDATE Employee SET ContactNumber = '0777654321', City = 'Negombo',     District = 'Gampaha',     Province = 'Western'      WHERE EmployeeID = 4;
UPDATE Employee SET ContactNumber = '0729988776', City = 'Jaffna',      District = 'Jaffna',      Province = 'Northern'     WHERE EmployeeID = 5;
UPDATE Employee SET ContactNumber = '0765544332', City = 'Matara',      District = 'Matara',      Province = 'Southern'     WHERE EmployeeID = 6;
UPDATE Employee SET ContactNumber = '0789988776', City = 'Badulla',     District = 'Badulla',     Province = 'Uva'          WHERE EmployeeID = 7;
UPDATE Employee SET ContactNumber = '0741122334', City = 'Trincomalee', District = 'Trincomalee', Province = 'Eastern'      WHERE EmployeeID = 8;
UPDATE Employee SET ContactNumber = '0704455667', City = 'Kurunegala',  District = 'Kurunegala',  Province = 'North Western' WHERE EmployeeID = 9;
UPDATE Employee SET ContactNumber = '0713344556', City = 'Ratnapura',   District = 'Ratnapura',   Province = 'Sabaragamuwa' WHERE EmployeeID = 10;


-- 18. Retrieve Employee details by Department and City
CREATE INDEX idx_employee_dept_city
ON Employee (DepartmentID, City);

-- 19. Find Employees working on Projects with a specific EndDate
CREATE INDEX idx_project_enddate
ON project (EndDate);

-- 20. Search Employees based on Province and Project
CREATE INDEX idx_employee_province_id
ON Employee (Province, EmployeeID);

CREATE INDEX idx_employeeprojects_project_emp
ON EmloyeeProjects (ProjectID, EmployeeID);




