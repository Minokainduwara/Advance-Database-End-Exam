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