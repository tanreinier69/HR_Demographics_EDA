--Create dimension tables for position, manager and department

CREATE TABLE Manager(
	manager_id VARCHAR(50) NOT NULL PRIMARY KEY,
	Manager VARCHAR(250)
);

CREATE TABLE Department (
	department_id VARCHAR(50) NOT NULL PRIMARY KEY,
	Department VARCHAR(250)
);

CREATE TABLE Position (
	position_id VARCHAR(50) NOT NULL PRIMARY KEY,
	Position VARCHAR(250)
);

--Create table for Fact Table

CREATE TABLE HRData (
	EmployeeName VARCHAR(256),
	EmployeeID VARCHAR(50) NOT NULL PRIMARY KEY,
	Position_ID VARCHAR(50) REFERENCES Position(position_id),
	Department_ID VARCHAR(50) REFERENCES Department(department_id),
	Manager_ID VARCHAR(50) REFERENCES Manager(manager_id),
	DateofHire date NOT NULL,
	Salary numeric,
	Sex CHAR(1),
	DateofBirth date NOT NULL,
	MaritalDesc VARCHAR(50),
	CitizenDesc VARCHAR(50),
	RaceDesc VARCHAR(50),
	State VARCHAR(3),
	Zip VARCHAR(10),
	DateofTermination DATE,
	TermReason VARCHAR(250),
	EmploymentStatus VARCHAR(50),
	RecruitmentSource VARCHAR(50),
	PerformanceScore VARCHAR(50),
	EngagementSurvey NUMERIC,
	EmpSatisfaction NUMERIC,
	LastPerformanceReview_Date DATE,
	Absences NUMERIC
);


--Insert cleaned data

COPY Position
FROM 'D:\Onedrive Folder\OneDrive - Alpha Riot\Projects\Portfolio\HR Dataset\Position.csv'
WITH (FORMAT csv, HEADER)

COPY Manager
FROM 'D:\Onedrive Folder\OneDrive - Alpha Riot\Projects\Portfolio\HR Dataset\Manager.csv'
WITH (FORMAT csv, HEADER)

COPY Department
FROM 'D:\Onedrive Folder\OneDrive - Alpha Riot\Projects\Portfolio\HR Dataset\Department.csv'
WITH (FORMAT csv, HEADER)

COPY HRData
FROM 'D:\Onedrive Folder\OneDrive - Alpha Riot\Projects\Portfolio\HR Dataset\HRData.csv'
WITH (FORMAT csv, HEADER);

--Begin EDA thru the following questions:

--1. Who is the first hired employee
--based on the findings, Jack Torrence is the first hired employee of the company.

SELECT employeename, dateofhire
FROM hrdata
ORDER BY dateofhire ASC
LIMIT 5;

--2. who is the employee with the longest tenure (using reference date 2018-07-09 as present date)
-- Jack Torrence is the longest employed having 12 years and 6 months in service

SELECT employeename, 
		EXTRACT(YEAR FROM AGE('2018-07-09'::DATE, dateofhire)) AS tenure_year,
		EXTRACT(MONTH FROM AGE('2018-07-09'::DATE, dateofhire)) AS tenure_months
FROM hrdata
WHERE employmentstatus = 'Active'
ORDER BY tenure_year DESC
LIMIT 5;


--3. Top 10 employees with the most absences
--It appears there are 14 employees with the same rate of absences. 20 being the highest.

SELECT employeename, absences
FROM hrdata
ORDER BY absences DESC;


--4. Average employee satisfaction of Active employees.
-- Average score is 3.89

SELECT AVG(empsatisfaction)
FROM hrdata
WHERE employmentstatus = 'Active';

-- Curious about the average employee sastisfaction of Voluntary Terminated employees.
-- Average score is 3.89 as well.

SELECT AVG(empsatisfaction)
FROM hrdata
WHERE employmentstatus = 'Voluntarily Terminated';

--not much outliers between those who left and those are still active.

--5. What is the shortest tenure of an active employee
-- Randy Dee appears to be the employee with the shortest tenure

SELECT employeename, 
		EXTRACT(YEAR FROM AGE('2018-07-09'::DATE, dateofhire)) AS tenure_year,
		EXTRACT(MONTH FROM AGE('2018-07-09'::DATE, dateofhire)) AS tenure_months
FROM hrdata
WHERE employmentstatus = 'Active'
ORDER BY tenure_year ASC
LIMIT 5;


--6. What is the percentage of difference of active male and females in the workplace
-- it appears females are the more dominant active employees. Females are 116, males are 91

SELECT
    sex,
    COUNT(*) AS active_count,
    (COUNT(*)::numeric / SUM(COUNT(*)) OVER ()) * 100 AS percentage
FROM hrdata
WHERE employmentstatus = 'Active'
GROUP BY sex;

--7. What is the average salary band of each department?

SELECT department.department, AVG(hrdata.salary) AS Average_Salary
FROM hrdata
INNER JOIN department ON department.department_id = hrdata.department_id
GROUP BY department.department

--8. Aggregated Performance Scores of Tenured and Resigned Employees.

SELECT performancescore, COUNT(performancescore)
FROM hrdata
WHERE employmentstatus = 'Active'
GROUP BY performancescore;

--9. Top Recruitment source of possible applicants.
--Indeed was the top source for all employees.

SELECT recruitmentsource, COUNT(recruitmentsource) AS source_count
FROM hrdata
GROUP BY recruitmentsource
ORDER BY source_count DESC;

--10. What is the total number of employees, including active and inactive. Find their difference

SELECT COUNT(employeeid) AS total_employee_count
FROM hrdata;
--311 employees in total

SELECT COUNT(employeeid) AS total_active_employee
FROM hrdata
WHERE employmentstatus = 'Active';
--207 Active employees

SELECT COUNT(employeeid) AS total_inactive_employee
FROM hrdata
WHERE employmentstatus LIKE '%Terminated%';
--103 inactive employees

