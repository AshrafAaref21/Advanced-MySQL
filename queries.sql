SELECT 
    first_name, COUNT(first_name) AS no_of_name
FROM
    employees
WHERE
    hire_date > '1985-1-1'
GROUP BY first_name
HAVING no_of_name > 200
ORDER BY first_name
LIMIT 10;



SELECT 
    *
FROM
    employees;




SELECT

    IFNULL(dept_no, 'N/A') as dept_no,

    IFNULL(dept_name,

            'Department name not provided') AS dept_name,

    COALESCE(dept_no, dept_name) AS dept_info

FROM

    departments

ORDER BY dept_no ASC;



SELECT 
    e.gender, AVG(s.salary)
FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
GROUP BY e.gender;





SELECT 
    *
FROM
    (SELECT 
        e.emp_no,
            e.first_name,
            e.last_name,
            NULL AS dept_no,
            NULL AS from_date
    FROM
        employees e
    WHERE
        last_name = 'Denis' UNION SELECT 
        NULL AS emp_no,
            NULL AS first_name,
            NULL AS last_name,
            dm.dept_no,
            dm.from_date
    FROM
        dept_manager dm) AS a
ORDER BY  a.emp_no ;




SELECT 
    s.emp_no, sb.first_name, sb.last_name, s.salary
FROM
    (SELECT 
        e.emp_no, e.first_name, e.last_name
    FROM
        dept_manager dm
    JOIN employees e ON dm.emp_no = e.emp_no) AS sb
        JOIN
    salaries s ON s.emp_no = sb.emp_no;



SELECT 
    *
FROM
    employees e
WHERE
    e.emp_no IN (SELECT 
            dm.emp_no
        FROM
            dept_manager dm)
        AND e.hire_date BETWEEN '1990-1-1' AND '1995-1-1';


SELECT 
    *
FROM
    dept_manager
WHERE
    emp_no IN (SELECT 
            emp_no
        FROM
            employees
        WHERE
            hire_date BETWEEN '1990-01-01' AND '1995-01-01');
            
            
            
SELECT 
    *
FROM
    employees e
WHERE
    EXISTS( SELECT 
            *
        FROM
            titles t
        WHERE
            t.emp_no = e.emp_no
                AND title = 'Assistant Engineer');
                
                
                
                
                

                
SELECT 
    A.*
FROM
    (SELECT 
        e.emp_no AS employee_ID,
            MIN(d.dept_no) AS dept_code,
            (SELECT 
                    emp_no
                FROM
                    dept_manager
                WHERE
                    emp_no = 110022) AS manager_ID
    FROM
        employees e
    JOIN dept_emp d ON e.emp_no = d.emp_no
    WHERE
        e.emp_no <= 10020
    GROUP BY e.emp_no) AS A 
UNION SELECT 
    B.*
FROM
    (SELECT 
        e.emp_no AS employee_ID,
            MIN(d.dept_no) AS dept_code,
            (SELECT 
                    emp_no
                FROM
                    dept_manager
                WHERE
                    emp_no = 110039) AS manager_ID
    FROM
        employees e
    JOIN dept_emp d ON e.emp_no = d.emp_no
    WHERE
        e.emp_no > 10020
    GROUP BY e.emp_no
    LIMIT 20) AS B;
    
    
    
DROP TABLE IF EXISTS emp_manager;

CREATE TABLE emp_manager (

   emp_no INT(11) NOT NULL,

   dept_no CHAR(4) NULL,

   manager_no INT(11) NOT NULL

);

INSERT INTO emp_manager
SELECT 
    u.*
FROM
    (SELECT 
        a.*
    FROM
        (SELECT 
        e.emp_no AS employee_ID,
            MIN(de.dept_no) AS department_code,
            (SELECT 
                    emp_no
                FROM
                    dept_manager
                WHERE
                    emp_no = 110022) AS manager_ID
    FROM
        employees e
    JOIN dept_emp de ON e.emp_no = de.emp_no
    WHERE
        e.emp_no <= 10020
    GROUP BY e.emp_no
    ORDER BY e.emp_no) AS a UNION SELECT 
        b.*
    FROM
        (SELECT 
        e.emp_no AS employee_ID,
            MIN(de.dept_no) AS department_code,
            (SELECT 
                    emp_no
                FROM
                    dept_manager
                WHERE
                    emp_no = 110039) AS manager_ID
    FROM
        employees e
    JOIN dept_emp de ON e.emp_no = de.emp_no
    WHERE
        e.emp_no > 10020
    GROUP BY e.emp_no
    ORDER BY e.emp_no
    LIMIT 20) AS b UNION SELECT 
        c.*
    FROM
        (SELECT 
        e.emp_no AS employee_ID,
            MIN(de.dept_no) AS department_code,
            (SELECT 
                    emp_no
                FROM
                    dept_manager
                WHERE
                    emp_no = 110039) AS manager_ID
    FROM
        employees e
    JOIN dept_emp de ON e.emp_no = de.emp_no
    WHERE
        e.emp_no = 110022
    GROUP BY e.emp_no) AS c UNION SELECT 
        d.*
    FROM
        (SELECT 
        e.emp_no AS employee_ID,
            MIN(de.dept_no) AS department_code,
            (SELECT 
                    emp_no
                FROM
                    dept_manager
                WHERE
                    emp_no = 110022) AS manager_ID
    FROM
        employees e
    JOIN dept_emp de ON e.emp_no = de.emp_no
    WHERE
        e.emp_no = 110039
    GROUP BY e.emp_no) AS d) as u;
    
    
SELECT 
    *
FROM
    emp_manager
WHERE
    emp_no IN (SELECT DISTINCT
            manager_no
        FROM
            emp_manager)
;

SELECT 
    e1.*
FROM
    emp_manager e1
        JOIN
    emp_manager e2 ON e1.emp_no = e2.manager_no;
    

SELECT 
AVG(s.salary) as sa
FROM
    dept_manager d
        JOIN
    salaries s ON s.emp_no = d.emp_no
;


-- VIEW QUERY

CREATE OR REPLACE VIEW v_manager_avg_salary AS

    SELECT

        ROUND(AVG(salary), 2)

    FROM

        salaries s

            JOIN

        dept_manager m ON s.emp_no = m.emp_no;
        
select * from v_manager_avg_salary;


--  PROCEDURE QUERIES

DROP procedure IF EXists select_employees;
DELIMITER $$
CREATE PROCEDURE select_employees()
BEGIN
		SELECT * FROM employees
        LIMIT 1000;
END $$
DELIMITER ;

CALL select_employees();



DROP PROCEDURE IF EXISTS avg_gender_salary;
DELIMITER $$
CREATE PROCEDURE avg_gender_salary(
							IN p_sex enum('M','F'),
                            OUT p_avg_gender_salary DECIMAL(10,2)
)
BEGIN
	SELECT 
		AVG(s.salary)
	INTO p_avg_gender_salary FROM
		employees e
			JOIN
		salaries s ON e.emp_no = s.emp_no
	GROUP BY e.gender
	HAVING e.gender = p_sex;
END $$
DELIMITER ;

SET @v_avg_gender_salary = 0;
CALL avg_gender_salary('F',@v_avg_gender_salary);
SELECT @v_avg_gender_salary;


DROP PROCEDURE select_employees;


-- FUNCTIONS QUERIES

DELIMITER $$
CREATE FUNCTION f_last_contract(f_name varchar(255), l_name varchar(255))  RETURNS DECIMAL(10,2)
DETERMINISTIC NO SQL READS SQL DATA
BEGIN 
DECLARE v_salary DECIMAL(10,2);
SELECT 
    s.salary INTO v_salary
FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
WHERE
    first_name = f_name
        AND last_name = l_name
ORDER BY first_name , last_name , from_date DESC
LIMIT 1;
RETURN v_salary;
END $$
DELIMITER ;

SELECT F_LAST_CONTRACT('Aruna', 'Journel');



DELIMITER $$
CREATE FUNCTION emp_info(p_first_name varchar(255), p_last_name varchar(255)) RETURNS decimal(10,2)
DETERMINISTIC NO SQL READS SQL DATA
BEGIN
	DECLARE v_max_from_date date;
    DECLARE v_salary decimal(10,2);

SELECT 
    MAX(from_date)
INTO v_max_from_date FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
WHERE
    e.first_name = p_first_name
        AND e.last_name = p_last_name;
SELECT 
    s.salary
INTO v_salary FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
WHERE
    e.first_name = p_first_name
        AND e.last_name = p_last_name
        AND s.from_date = v_max_from_date;

       

                RETURN v_salary;
END$$
DELIMITER ;


SELECT EMP_INFO('Aruna', 'Journel');
SELECT F_LAST_CONTRACT('Aruna', 'Journel');

-- TRIGGERS QUERIES

COMMIT;

DELIMITER $$
CREATE TRIGGER before_insert_salaries
BEFORE INSERT ON salaries
FOR EACH ROW 
BEGIN
	IF NEW.salary < 0 THEN
    SET NEW.salary = 0;
    END IF;
END $$
DELIMITER ;

INSERT INTO salaries VALUES('10001', -92000, '2010-06-22', '9999-01-01');


DELIMITER $$
CREATE TRIGGER before_update_salaries
BEFORE UPDATE ON salaries
FOR EACH ROW
BEGIN
	IF NEW.salary < 0 then
    SET NEW.salary = OLD.salary;
    END IF;
END $$
DELIMITER ;


SELECT * FROM salaries WHERE emp_no = 10001;
UPDATE salaries 
SET salary = 98789
WHERE emp_no = 10001
AND from_date = '2010-06-22';

UPDATE salaries 
SET salary = -98011
WHERE emp_no = 10001 
AND from_date = '2010-06-22';


DELIMITER $$
CREATE TRIGGER trig_ins_dept_mang
AFTER INSERT ON dept_manager
FOR EACH ROW
BEGIN
		DECLARE v_curr_salary int;
		SELECT 
    MAX(salary)
INTO v_curr_salary FROM
    salaries
WHERE
    emp_no = NEW.emp_no;

		IF v_curr_salary IS NOT NULL THEN
		UPDATE salaries
		SET to_date = SYSDATE()
		WHERE emp_no = NEW.emp_no
		AND to_date = NEW.to_date;
		INSERT INTO salaries VALUES (NEW.emp_no, v_curr_salary + 20000, NEW.from_date, NEW.to_date);
		END IF;
END $$
DELIMITER ;


SELECT 
    *
FROM
    salaries
WHERE
    emp_no = 111534;
    
INSERT INTO dept_manager VALUES (111534, 'd009', date_format(sysdate(),'%Y-%m-%d'), '9999-01-01');


SELECT 
    *
FROM
    salaries
WHERE
    emp_no = 111534;
    
    
select * from employees;


DELIMITER $$
CREATE TRIGGER hire_date_checker
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
	IF NEW.hire_date > date_format(sysdate(), '%Y-%m-%d') THEN
    SET NEW.hire_date = date_format(sysdate(), '%Y-%m-%d');
    END IF;
END $$
DELIMITER ;

INSERT employees VALUES ('999904', '1970-01-31', 'John', 'Johnson', 'M', '2025-01-01');  

SELECT  
    *  
FROM  
    employees
ORDER BY emp_no DESC;	


-- CREATE INDEX FOR FASTER QUERY BUT NEEDS MORE RAM
CREATE INDEX i_hire ON employees(hire_date);

-- THE CASE STATEMENT QUERIES
SELECT 
    emp_no,
    first_name,
    last_name,
    CASE gender
        WHEN 'M' THEN 'Male'
        ELSE 'Female'
    END AS Gender
FROM
    employees;
    
    
SELECT 
    e.emp_no,
    e.first_name,
    e.last_name,
    CASE 
		WHEN d.emp_no IS NULL THEN 'Employee'
		ELSE 'Manager'
	END AS IS_Manager
FROM
    employees e
        LEFT JOIN
    dept_manager d ON e.emp_no = d.emp_no
-- HAVING IS_Manager = 'Manager'
;


SELECT 
    d.emp_no,
    e.first_name,
    e.last_name,
    MAX(s.salary) - MIN(s.salary) AS salary_diff,
    CASE
		WHEN MAX(s.salary) - MIN(s.salary) > 30000 THEN 'SALARY IS INCREASED MORE THAN 30k...AWSOME!!!'
        WHEN MAX(s.salary) - MIN(s.salary) BETWEEN 20000 AND 30000 THEN 'SALARY IS BETWEEN 20k AND 30k...COOL!!!'
        ELSE 'SALARY IS INCREASED LESS THAN 20K....NOT BAD!!!'
	END AS salary_increase
FROM
    dept_manager d
        JOIN
    salaries s ON d.emp_no = s.emp_no
        JOIN
    employees e ON s.emp_no = e.emp_no
    
GROUP BY d.emp_no
;


SELECT

    e.emp_no,

    e.first_name,

    e.last_name,

    CASE

        WHEN MAX(de.to_date) > SYSDATE() THEN 'Is still employed'

        ELSE 'Not an employee anymore'

    END AS current_employee

FROM

    employees e

        JOIN

    dept_emp de ON de.emp_no = e.emp_no

GROUP BY de.emp_no

LIMIT 100;



-- ROW NUMBER WINDOW FUNCTION QUERY

SELECT
	emp_no,
    salary,
    ROW_NUMBER() OVER (PARTITION BY emp_no ORDER BY salary) AS row_num
FROM salaries
;


SELECT
    ROW_NUMBER() OVER (PARTITION BY first_name ORDER BY emp_no) AS '',
    emp_no,
    first_name,
    last_name
FROM employees
;

-- RANK WINDWO FUNCTION QUERIES

SELECT
	emp_no,
	salary,
	RANK() OVER (PARTITION BY emp_no ORDER BY salary DESC) AS rank_num
FROM
	salaries
WHERE emp_no = 10560
;


SELECT
	emp_no,
	salary,
	DENSE_RANK() OVER w AS rank_num
FROM
	salaries
WHERE emp_no = 10560
WINDOW w AS (PARTITION BY emp_no ORDER BY salary DESC)
;


SELECT
	e.*,
    dp.dept_name,
    s.salary,
    RANK() OVER (PARTITION BY dp.dept_name ORDER BY salary) AS rank_num
FROM
	employees e
		JOIN
	dept_manager d ON e.emp_no = d.emp_no
		JOIN 
	salaries s ON s.emp_no = d.emp_no
		JOIN
	departments dp ON dp.dept_no = d.dept_no
;


SELECT
    e.emp_no,
    RANK() OVER w as employee_salary_ranking,
    s.salary
FROM
	employees e
		JOIN
    salaries s ON s.emp_no = e.emp_no
WHERE e.emp_no BETWEEN 10500 AND 10600
WINDOW w as (PARTITION BY e.emp_no ORDER BY s.salary DESC);

-- LAG LEAD WINDOW FUNCTIONS

SELECT
	emp_no,
    salary,
    LAG(salary) OVER w AS previous_salary,
    LEAD(salary) OVER w AS next_salary,
    salary - LAG(salary) OVER w AS diff_salary_current_previous,
	LEAD(salary) OVER w - salary AS diff_salary_next_current
FROM
	salaries
#WHERE salary > 80000 AND emp_no BETWEEN 10500 AND 10600
WINDOW w AS (PARTITION BY emp_no ORDER BY salary)
LIMIT 121;




-- AGGEREGATE WINDOW FUNCTION QUERY


SELECT

    de2.emp_no,
    d.dept_name,
    s2.salary,
    AVG(s2.salary) OVER w AS average_salary_per_department

FROM

    (SELECT

    de.emp_no, de.dept_no, de.from_date, de.to_date

FROM

    dept_emp de

        JOIN

(SELECT

emp_no, MAX(from_date) AS from_date

FROM

dept_emp

GROUP BY emp_no) de1 ON de1.emp_no = de.emp_no

WHERE

    de.to_date < '2002-01-01'

AND de.from_date > '2000-01-01'

AND de.from_date = de1.from_date) de2

JOIN

    (SELECT

    s1.emp_no, s.salary, s.from_date, s.to_date

FROM

    salaries s

    JOIN

    (SELECT

emp_no, MAX(from_date) AS from_date

FROM

salaries

    GROUP BY emp_no) s1 ON s.emp_no = s1.emp_no

WHERE

    s.to_date < '2002-01-01'

AND s.from_date > '2000-01-01'

AND s.from_date = s1.from_date) s2 ON s2.emp_no = de2.emp_no

JOIN

    departments d ON d.dept_no = de2.dept_no

GROUP BY de2.emp_no, d.dept_name

WINDOW w AS (PARTITION BY de2.dept_no)

ORDER BY de2.emp_no, salary;