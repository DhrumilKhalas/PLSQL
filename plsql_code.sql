-- (1) Write a PL/SQL anonymous block to load and display the following details about customers: first name, last name, email, country name, and credit limit.

-- (i) Anonymous Block:

DECLARE

   -- Define variables to hold customer details
   v_first_name VARCHAR2(20); -- Matches CUST_FIRST_NAME
   v_last_name VARCHAR2(20); -- Matches CUST_LAST_NAME
   v_email VARCHAR2(30); -- Matches CUST_EMAIL
   v_country_name VARCHAR2(40); -- Matches COUNTRY_NAME
   v_credit_limit NUMBER(9, 2); -- Matches CREDIT_LIMIT (precision 9, scale 2)

   -- Cursor to retrieve customer details with a join
   CURSOR customer_cursor IS
        SELECT 
            cu.CUST_FIRST_NAME,
            cu.CUST_LAST_NAME,
            cu.CUST_EMAIL,
            co.COUNTRY_NAME,
            cu.CREDIT_LIMIT
        FROM OEHR_CUSTOMERS cu
        LEFT JOIN OEHR_COUNTRIES co ON cu.COUNTRY_ID = co.COUNTRY_ID; -- Join with country table

BEGIN

   -- Open the cursor and fetch each record
   OPEN customer_cursor;

   LOOP
      FETCH customer_cursor INTO v_first_name, v_last_name, v_email, v_country_name, v_credit_limit;
      
      -- Exit the loop if no more rows are fetched
      EXIT WHEN customer_cursor%NOTFOUND;

      -- Display customer details
      DBMS_OUTPUT.PUT_LINE('First Name: ' || v_first_name);
      DBMS_OUTPUT.PUT_LINE('Last Name: ' || v_last_name);
      DBMS_OUTPUT.PUT_LINE('Email: ' || v_email);
      DBMS_OUTPUT.PUT_LINE('Country: ' || v_country_name);
      DBMS_OUTPUT.PUT_LINE('Credit Limit: ' || v_credit_limit);
      DBMS_OUTPUT.PUT_LINE('---------------------------------');
   END LOOP;

   -- Close the cursor
   CLOSE customer_cursor;

EXCEPTION
   -- Handle any exceptions that occur
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);

END;


-- (2) Write a PL/SQL program to determine the lowest of three numbers using a nested IF statement. The numbers should be assigned in the DECLARE section.

-- (i) Anonymous Block:

DECLARE

    -- Declare three numbers
    v_num1 NUMBER := 23; -- Variable for first number
    v_num2 NUMBER := 45; -- Variable for second number
    v_num3 NUMBER := 12; -- Variable for third number
    v_result NUMBER; -- Variable to store the lowest number

BEGIN

    -- Use Nested-If to determine the lowest number
    IF(v_num1 < v_num2) THEN
        IF(v_num1 < v_num3) THEN
            v_result := v_num1;
        ELSE
            v_result := v_num3;
        END IF;
    ELSE
        IF(v_num2 < v_num3) THEN
            v_result := v_num2;
        ELSE
            v_result := v_num3;
        END IF;
    END IF;

    -- Display the lowest number
    DBMS_OUTPUT.PUT_LINE('The lowest number is ' || v_result);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);

END;


-- (3) Write a PL/SQL procedure Insert_promo to insert a new row into the oehr_promotions table. The procedure should take promo_id and promo_name as parameters. It should not allow duplicate values for promo_name. 
-- To achieve this:
--      - Check for the non-existence of the new promotion before adding it.
--      - Include exception handling.
--      - Notify the user about the status of the insertion (success or failure). 
-- Write an anonymous block to execute the procedure.

-- (i) Stored Procedure:

CREATE OR REPLACE PROCEDURE Insert_promo (
    p_promo_id IN NUMBER,
    p_promo_name IN VARCHAR2
)

IS
    v_count NUMBER; -- Variable to store the count of duplicate names

BEGIN

    -- Check if promo_name already exists
    SELECT COUNT(*)
    INTO v_count
    FROM OEHR_PROMOTIONS
    WHERE PROMO_NAME = p_promo_name;

    -- If promo_name already exists, raise an exception
    IF (v_count != 0) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Duplicate Promo Name not allowed: ' || p_promo_name);
    ELSE
        -- Insert a new row in the OEHR_PROMOTIONS table
        INSERT INTO OEHR_PROMOTIONS (PROMO_ID, PROMO_NAME)
        VALUES (p_promo_id, p_promo_name);

        -- Notify success
        DBMS_OUTPUT.PUT_LINE('New row added successfully in the OEHR_PROMOTIONS table with Promo ID: ' || p_promo_id || ' and Promo Name: ' || p_promo_name);
    END IF;

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Insertion Failed: ' || SQLERRM);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);

END;

-- (ii) Anonymous Block:

DECLARE
    v_promo_id NUMBER(6, 0) := 3;
    v_promo_name VARCHAR(20) := 'black friday sale';

BEGIN
    Insert_promo(v_promo_id, v_promo_name);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Something went wrong: ' || SQLERRM);

END;


-- (4) Write a PL/SQL function to increase the salary of a given employee. 
-- The program should search using the employee's ID and determine the new salary based on the job ID:
--      - AD_PRES: Increase salary by 10%.
--      - AD_VP: Increase salary by 8%.
--      - IT_Prog: Increase salary by 15%.
--      - Any other job class: No increase. 
-- Your program should store the result in a variable. Include exception handling. Run the program by hardcoding the search for employee ID 110.

-- (i) Function:

CREATE OR REPLACE FUNCTION Increase_Salary(
    p_emp_id IN NUMBER
) RETURN NUMBER

IS
    v_current_salary NUMBER(22, 8);
    v_new_salary NUMBER(22, 8);
    v_job_id VARCHAR2(10);

BEGIN

    -- Retrieve the current salary and job ID for the given employee ID
    SELECT SALARY, JOB_ID
    INTO v_current_salary, v_job_id
    FROM OEHR_EMPLOYEES
    WHERE EMPLOYEE_ID = p_emp_id;

    -- Determine the new salary based on the job ID
    IF(v_job_id = 'AD_PRES') THEN
        v_new_salary := v_current_salary * 1.10; -- Increase by 10%
    ELSIF(v_job_id = 'AD_VP') THEN
        v_new_salary := v_current_salary * 1.08; -- Increase by 8%
    ELSIF(v_job_id = 'IT_PROG') THEN
        v_new_salary := v_current_salary * 1.15; -- Increase by 15%
    ELSE
        v_new_salary := v_current_salary; -- No increase
    END IF;

    -- Update the employee's salary in the database
    -- UPDATE OEHR_EMPLOYEES
    -- SET SALARY = v_new_salary
    -- WHERE EMPLOYEES_ID = p_emp_id;

    -- Return the new salary
    RETURN v_new_salary;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Employee ID ' || p_emp_id || ' not found.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'An error occurred: ' || SQLERRM);

END;

-- (ii) Anonymous Block:

DECLARE

   v_emp_id NUMBER(6, 0) := 110; -- Hardcoded employee ID
   v_updated_salary NUMBER(22, 8); -- Variable to store the updated salary

BEGIN

    -- Call the function and store the result
    v_updated_salary := Increase_Salary(v_emp_id);

    -- Display the updated salary
    DBMS_OUTPUT.PUT_LINE('The new salary for Employee ID ' || v_emp_id || ' is: ' || v_updated_salary);

END;


-- (5) Create a record type named order_obj_t that contains all of the attributes of the OEHR_ORDERS table, plus the customer’s first and last name, credit limit for this customer, and the salesperson’s first and last name (if any). 
-- Write an anonymous block that creates a variable using the order_obj_t type for a specific order ID. Include both the code for the type and the block. Run the block with order IDs 2458, 2355, and 1456. Include the generated output.

-- (i) Anonymous Block:

DECLARE

    TYPE order_obj_t IS RECORD (
        ORDER_ID NUMBER(12, 0),
        ORDER_DATE TIMESTAMP(6) WITH TIME ZONE,
        ORDER_MODE VARCHAR2(8),
        CUSTOMER_ID NUMBER(6, 0),
        ORDER_STATUS NUMBER(2, 0),
        ORDER_TOTAL NUMBER(8, 2),
        SALES_REP_ID NUMBER(6, 0),
        PROMOTION_ID NUMBER(6, 0),
        CUST_FIRST_NAME VARCHAR2(20),
        CUST_LAST_NAME VARCHAR2(20),
        CREDIT_LIMIT NUMBER(9, 2),
        SALES_FIRST_NAME VARCHAR2(20),
        SALES_LAST_NAME VARCHAR2(25)
    );

    v_order_obj_t order_obj_t;
    v_count NUMBER;
    -- Change the value of order ID to 2458, 2355, or 1456.
    v_order_id NUMBER(12, 0) := 2458; 

BEGIN

    -- Check if data exists for the given ORDER_ID
    SELECT COUNT(*) 
    INTO v_count
    FROM OEHR_ORDERS O
    WHERE O.ORDER_ID = v_order_id;

    -- If no data found, print the message
    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No data found for the Order ID: ' || v_order_id);
    ELSE
        -- Fetch and display order details for given order_id numbers
        FOR REC IN (
            SELECT O.ORDER_ID,
                O.ORDER_DATE,
                O.ORDER_MODE,
                O.CUSTOMER_ID,
                O.ORDER_STATUS,
                O.ORDER_TOTAL,
                O.SALES_REP_ID,
                O.PROMOTION_ID,
                CUST.CUST_FIRST_NAME,
                CUST.CUST_LAST_NAME,
                CUST.CREDIT_LIMIT,
                EMP.FIRST_NAME AS SALES_FIRST_NAME,
                EMP.LAST_NAME AS SALES_LAST_NAME
            FROM OEHR_ORDERS O
            JOIN OEHR_CUSTOMERS CUST ON O.CUSTOMER_ID = CUST.CUSTOMER_ID
            LEFT JOIN OEHR_EMPLOYEES EMP ON O.SALES_REP_ID = EMP.EMPLOYEE_ID
            WHERE O.ORDER_ID = v_order_id
        ) LOOP   
        
            -- Assign the values to the order_obj_t record
            v_order_obj_t.ORDER_ID := REC.ORDER_ID;
            v_order_obj_t.ORDER_DATE := REC.ORDER_DATE;
            v_order_obj_t.ORDER_MODE := REC.ORDER_MODE;
            v_order_obj_t.CUSTOMER_ID := REC.CUSTOMER_ID;
            v_order_obj_t.ORDER_STATUS := REC.ORDER_STATUS;
            v_order_obj_t.ORDER_TOTAL := REC.ORDER_TOTAL;
            v_order_obj_t.SALES_REP_ID := REC.SALES_REP_ID;
            v_order_obj_t.PROMOTION_ID := REC.PROMOTION_ID;
            v_order_obj_t.CUST_FIRST_NAME := REC.CUST_FIRST_NAME;
            v_order_obj_t.CUST_LAST_NAME := REC.CUST_LAST_NAME;
            v_order_obj_t.CREDIT_LIMIT := REC.CREDIT_LIMIT;
            v_order_obj_t.SALES_FIRST_NAME := REC.SALES_FIRST_NAME;
            v_order_obj_t.SALES_LAST_NAME := REC.SALES_LAST_NAME;
        
            -- Printing the output of the details of the orders
            DBMS_OUTPUT.PUT_LINE('ORDER#: ' || v_order_obj_t.ORDER_ID);
            DBMS_OUTPUT.PUT_LINE('ORDER DATE: ' || TO_CHAR(v_order_obj_t.ORDER_DATE, 'FMMonth DD, YYYY'));
            DBMS_OUTPUT.PUT_LINE('CUSTOMER: ' || v_order_obj_t.CUST_FIRST_NAME || ' ' || v_order_obj_t.CUST_LAST_NAME); 
            DBMS_OUTPUT.PUT_LINE('CREDIT LIMIT: $' || v_order_obj_t.CREDIT_LIMIT);
            DBMS_OUTPUT.PUT_LINE('ORDER STATUS: ' || v_order_obj_t.ORDER_STATUS);
            DBMS_OUTPUT.PUT_LINE('ORDER TOTAL: $' || v_order_obj_t.ORDER_TOTAL); 
            DBMS_OUTPUT.PUT_LINE('SALES PERSON: ' || NVL(v_order_obj_t.SALES_FIRST_NAME || ' ', '') || NVL(v_order_obj_t.SALES_LAST_NAME, 'N/A'));
            DBMS_OUTPUT.PUT_LINE('PROMOTION ID: ' || NVL(TO_CHAR(v_order_obj_t.PROMOTION_ID), 'N/A'));
        END LOOP;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'An unexpected error occurred: ' || SQLERRM);

END;


-- (6) Write a PL/SQL program to:
-- (a) Define a record type rt_employee that includes selected columns from the OEHR_EMPLOYEES table. Ensure that the datatype definitions match and include only the following fields: JOB_ID, SALARY, MANAGER_ID, and DEPARTMENT_ID.
-- (b) Define two records, r_employee1 and r_employee2, as type rt_employee.
-- (c) Fill r_employee1 with data from the OEHR_EMPLOYEES table for employee 101 using a cursor.
-- (d) Fill r_employee2 with data from the OEHR_EMPLOYEES table for employee 102 using a cursor.
-- (e) Compare r_employee1 to r_employee2 and display a message indicating whether they are equivalent or distinct.
-- (f) Create a procedure print_Employee that displays the JOB_ID, SALARY, MANAGER_ID, and DEPARTMENT_ID of a variable of type rt_employee. Call the procedure for both r_employee1 and r_employee2.

-- (i) Anonymous Block:

DECLARE

    -- Define a record type rt_employee
    TYPE rt_employee IS RECORD (
        JOB_ID OEHR_EMPLOYEES.JOB_ID%TYPE,
        SALARY OEHR_EMPLOYEES.SALARY%TYPE,
        MANAGER_ID OEHR_EMPLOYEES.MANAGER_ID%TYPE,
        DEPARTMENT_ID OEHR_EMPLOYEES.DEPARTMENT_ID%TYPE
    );

    -- Define two records of type rt_employee
    r_employee1 rt_employee;
    r_employee2 rt_employee;

    -- Cursor to fetch employee details
    CURSOR c_employee1 IS
        SELECT JOB_ID, SALARY, MANAGER_ID, DEPARTMENT_ID
        FROM OEHR_EMPLOYEES
        WHERE EMPLOYEE_ID = 101;

    CURSOR c_employee2 IS
        SELECT JOB_ID, SALARY, MANAGER_ID, DEPARTMENT_ID
        FROM OEHR_EMPLOYEES
        WHERE EMPLOYEE_ID = 102;

    -- Procedure to print employee details
    PROCEDURE print_Employee(emp_record IN rt_employee) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('JOB_ID: ' || emp_record.JOB_ID);
        DBMS_OUTPUT.PUT_LINE('SALARY: $' || emp_record.SALARY);
        DBMS_OUTPUT.PUT_LINE('MANAGER_ID: ' || emp_record.MANAGER_ID);
        DBMS_OUTPUT.PUT_LINE('DEPARTMENT_ID: ' || emp_record.DEPARTMENT_ID);
        DBMS_OUTPUT.PUT_LINE('-------------------------------');
    END print_Employee;

BEGIN

    -- Fetch data for employee 101 into r_employee1
    OPEN c_employee1;
    FETCH c_employee1 INTO r_employee1.JOB_ID, r_employee1.SALARY, r_employee1.MANAGER_ID, r_employee1.DEPARTMENT_ID;
    CLOSE c_employee1;

    -- Fetch data for employee 102 into r_employee2
    OPEN c_employee2;
    FETCH c_employee2 INTO r_employee2.JOB_ID, r_employee2.SALARY, r_employee2.MANAGER_ID, r_employee2.DEPARTMENT_ID;
    CLOSE c_employee2;

    -- Compare r_employee1 and r_employee2
    IF r_employee1.JOB_ID = r_employee2.JOB_ID AND r_employee1.SALARY = r_employee2.SALARY AND
       r_employee1.MANAGER_ID = r_employee2.MANAGER_ID AND r_employee1.DEPARTMENT_ID = r_employee2.DEPARTMENT_ID THEN
        DBMS_OUTPUT.PUT_LINE('The two employees are equivalent.');
        DBMS_OUTPUT.PUT_LINE('-------------------------------');
    ELSE
        DBMS_OUTPUT.PUT_LINE('The two employees are distinct.');
        DBMS_OUTPUT.PUT_LINE('');
    END IF;

    -- Call the print_Employee procedure for both records
    DBMS_OUTPUT.PUT_LINE('Details of Employee with ID 101:');
    print_Employee(r_employee1);
    DBMS_OUTPUT.PUT_LINE('Details of Employee with ID 102:');
    print_Employee(r_employee2);

END;


-- (7) Write a PL/SQL function to determine the number of employees in a given department. 
-- The program should search using the department's ID and return the count of employees in that department. 
-- Store the result in a variable. Run the program with the department ID set to 60.

-- (i) Function:

CREATE OR REPLACE FUNCTION get_employee_count(dept_id IN NUMBER)
RETURN NUMBER

IS
    -- Variable to store the employee count
    emp_count NUMBER; 

BEGIN

    -- Query to count employees in the given department
    SELECT COUNT(*)
    INTO emp_count
    FROM OEHR_EMPLOYEES
    WHERE DEPARTMENT_ID = dept_id;

    -- Return the employee count
    RETURN emp_count; 

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Raise a custom error if no employees are found in the specified department
        RAISE_APPLICATION_ERROR(-20001, 'No data found for department ID: ' || dept_id || '.'); 
    WHEN OTHERS THEN
        -- Raise a custom error for any other unexpected errors
        RAISE_APPLICATION_ERROR(-20002, 'An unexpected error occurred: ' || SQLERRM); 

END;

-- (ii) Anonymous Block:

DECLARE

    -- Hardcoded department ID
    department_id NUMBER := 60; 
    -- Variable to hold the result
    employee_count NUMBER; 

BEGIN

    -- Call the function and store the result
    employee_count := get_employee_count(department_id);

    -- Output the result
    DBMS_OUTPUT.PUT_LINE('Number of employees in department with department ID ' || department_id || ' is ' || employee_count || '.');

END;


-- (8) Modify the program written in the above question to determine the status of a department.
-- If the department has 30 or more employees, display a message saying 'Crowded department.'
-- If the department has fewer than 30 employees, display 'Normal department.'
-- If the department has only one employee, display 'New department.'
-- Run the program three times, hardcoding searches for department IDs 30, 40, and 50.

-- (i) Function:

CREATE OR REPLACE FUNCTION get_employee_count(dept_id IN NUMBER)
RETURN NUMBER

IS
    -- Variable to store the employee count
    emp_count NUMBER; 

BEGIN

    -- Query to count employees in the given department
    SELECT COUNT(*)
    INTO emp_count
    FROM OEHR_EMPLOYEES
    WHERE DEPARTMENT_ID = dept_id;

    -- Return the employee count
    RETURN emp_count; 

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Raise a custom error if no employees are found in the specified department
        RAISE_APPLICATION_ERROR(-20001, 'No data found for department ID: ' || dept_id || '.'); 
    WHEN OTHERS THEN
        -- Raise a custom error for any other unexpected errors
        RAISE_APPLICATION_ERROR(-20002, 'An unexpected error occurred: ' || SQLERRM); 

END;

-- (ii) Anonymous Block:

DECLARE

    -- Variable to hold the department ID
    department_id NUMBER; 
    -- Variable to hold the number of employees
    employee_count NUMBER; 

BEGIN

    -- Test case: Change the value of department_id to 30, 40, or 50 for testing different departments
    department_id := 30;
    employee_count := get_employee_count(department_id);

    -- Determine and display the department status
    IF employee_count >= 30 THEN
        DBMS_OUTPUT.PUT_LINE('crowded department');
    ELSIF employee_count = 1 THEN
        DBMS_OUTPUT.PUT_LINE('New department');
    ELSE
        DBMS_OUTPUT.PUT_LINE('normal department');
    END IF;

END;


-- (9) Write a program in PL/SQL to create a single explicit cursor.
-- You are required to display the following:
--      - PRODUCT_ID, PRODUCT_NAME, and LIST_PRICE from the table OEHR_PRODUCT_INFORMATION
--      - QUANTITY_ON_HAND from the table OEHR_INVENTORIES
--      - WAREHOUSE_NAME from the table OEHR_WAREHOUSES
-- Filter the result set to include only records where WAREHOUSE_ID is 5.

-- (i) Anonymous Block:

DECLARE

    -- Declare a cursor to retrieve the required data
    CURSOR product_cursor IS
        SELECT 
            p.PRODUCT_ID,
            p.PRODUCT_NAME,
            p.LIST_PRICE,
            i.QUANTITY_ON_HAND,
            w.WAREHOUSE_NAME
        FROM 
            OEHR_PRODUCT_INFORMATION p
        JOIN 
            OEHR_INVENTORIES i
        ON 
            p.PRODUCT_ID = i.PRODUCT_ID
        JOIN 
            OEHR_WAREHOUSES w
        ON 
            i.WAREHOUSE_ID = w.WAREHOUSE_ID
        WHERE 
            w.WAREHOUSE_ID = 5;

    -- Variables to hold cursor output
    v_product_id OEHR_PRODUCT_INFORMATION.PRODUCT_ID%TYPE;
    v_product_name OEHR_PRODUCT_INFORMATION.PRODUCT_NAME%TYPE;
    v_list_price OEHR_PRODUCT_INFORMATION.LIST_PRICE%TYPE;
    v_quantity_on_hand OEHR_INVENTORIES.QUANTITY_ON_HAND%TYPE;
    v_warehouse_name OEHR_WAREHOUSES.WAREHOUSE_NAME%TYPE;

BEGIN

    -- Open the cursor and fetch the data
    OPEN product_cursor;
    LOOP
        FETCH product_cursor INTO v_product_id, v_product_name, v_list_price, v_quantity_on_hand, v_warehouse_name;
        EXIT WHEN product_cursor%NOTFOUND;

        -- Display the data
        DBMS_OUTPUT.PUT_LINE('Product ID: ' || v_product_id);
        DBMS_OUTPUT.PUT_LINE('Product Name: ' || NVL(v_product_name, 'N/A'));
        DBMS_OUTPUT.PUT_LINE('List Price: ' || NVL(TRIM(TO_CHAR(v_list_price, '999999.99')), 'N/A'));
        DBMS_OUTPUT.PUT_LINE('Quantity On Hand: ' || v_quantity_on_hand);
        DBMS_OUTPUT.PUT_LINE('Warehouse Name: ' || NVL(v_warehouse_name, 'N/A'));
        DBMS_OUTPUT.PUT_LINE('--------------------------------------');
    END LOOP;
    CLOSE product_cursor;

END;


-- (10) Write an anonymous block that uses an order ID value and displays DBMS output in the following format: 'The order 2354 includes #1 of product #2 at $#3 each.'
-- (Where #1 is the quantity, #2 is the product name, and #3 is the unit price.)
-- Create a variable to hold the order ID value in the DECLARE section of your anonymous block and hardcode the value 2354 for the variable.
-- Use the following tables: OEHR_ORDER_ITEMS and OEHR_PRODUCT_INFORMATION.

-- (i) Anonymous Block:

DECLARE

    -- Variable to hold the order ID
    v_order_id OEHR_ORDER_ITEMS.ORDER_ID%TYPE := 2354;
    
    -- Cursor to retrieve order item details
    CURSOR order_details_cur IS
        SELECT oi.QUANTITY, 
               pi.PRODUCT_NAME, 
               oi.UNIT_PRICE
          FROM OEHR_ORDER_ITEMS oi
          JOIN OEHR_PRODUCT_INFORMATION pi 
            ON oi.PRODUCT_ID = pi.PRODUCT_ID
         WHERE oi.ORDER_ID = v_order_id;

    -- Variables to store fetched values
    v_quantity OEHR_ORDER_ITEMS.QUANTITY%TYPE;
    v_product_name OEHR_PRODUCT_INFORMATION.PRODUCT_NAME%TYPE;
    v_unit_price OEHR_ORDER_ITEMS.UNIT_PRICE%TYPE;

BEGIN

    -- Open the cursor and fetch rows
    FOR rec IN order_details_cur LOOP
        -- Fetch values into variables
        v_quantity := rec.QUANTITY;
        v_product_name := rec.PRODUCT_NAME;
        v_unit_price := rec.UNIT_PRICE;
        
        -- Display the output
        DBMS_OUTPUT.PUT_LINE('The order ' || v_order_id || 
                             ' include ' || v_quantity || 
                             ' of the product ' || v_product_name || 
                             ' at $' || TRIM(TO_CHAR(v_unit_price, '999999.99')) || ' each.'); 
    END LOOP;

END;


-- (11)
-- (a) Write a PL/SQL function to find the highest total order and return this value as the result of the function.
-- (b) Write an anonymous block that calls the function created in (a) and prints the result to the DBMS output in the following format: 'The highest order total is: #' (where # is the value returned from the function).
-- Use the following table: OEHR_ORDERS.

-- (i) Function:

CREATE OR REPLACE FUNCTION get_highest_order_total
RETURN NUMBER

IS
    -- Variable to store the highest order total
    v_highest_total OEHR_ORDERS.ORDER_TOTAL%TYPE; 

BEGIN

    -- Query to find the highest order total
    SELECT MAX(ORDER_TOTAL)
    INTO v_highest_total
    FROM OEHR_ORDERS;

    -- Return the highest order total
    RETURN v_highest_total; 

EXCEPTION
    WHEN OTHERS THEN
        -- Raise a custom error for any unexpected errors
        RAISE_APPLICATION_ERROR(-20001, 'An unexpected error occurred: ' || SQLERRM);

END;

-- (ii) Anonymous Block:

DECLARE

    -- Variable to hold the result from the function
    v_highest_order NUMBER; 

BEGIN

    -- Call the function to get the highest order total
    v_highest_order := get_highest_order_total;

    -- Display the result
    DBMS_OUTPUT.PUT_LINE('The highest order total is: ' || v_highest_order);

END;


-- (12) Write a PL/SQL procedure named Remove_History to delete a row from the table OEHR_JOB_HISTORY.
--      - The row should be identified by the customer_id passed as an input parameter.
--      - Include an exception handler in your procedure to handle cases where no matching customer is found.
--      - Display a message to the user upon successful deletion.
-- Write an anonymous block that calls the procedure for the customer_id 200.

-- (i) Procedure:

CREATE OR REPLACE PROCEDURE Remove_History (
    -- Input parameter for customer ID
    customer_id IN OEHR_JOB_HISTORY.EMPLOYEE_ID%TYPE  
)

IS

BEGIN

    -- Attempt to delete the row
    DELETE FROM OEHR_JOB_HISTORY
    WHERE EMPLOYEE_ID = customer_id;

    -- Check if any row was deleted
    IF SQL%ROWCOUNT > 0 THEN
        DBMS_OUTPUT.PUT_LINE('History for customer ID ' || customer_id || ' deleted successfully.');
    ELSE
        -- Raise an exception if no rows were deleted
        RAISE_APPLICATION_ERROR(-20001, 'No job history found for customer ID ' || customer_id);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- Raise a custom error for any other unexpected errors
        RAISE_APPLICATION_ERROR(-20002, 'An unexpected error occurred: ' || SQLERRM);

END;

-- (ii) Anonymous Block:

DECLARE

    -- Customer ID to be passed to the procedure
    customer_id OEHR_JOB_HISTORY.EMPLOYEE_ID%TYPE := 200; 

BEGIN

    -- Call the Remove_History procedure to delete the job history for the given customer_id
    Remove_History(customer_id);

END;


-- (13)
-- (a) Define a PL/SQL record named order_rec to hold the following columns from the table OEHR_ORDERS: ORDER_ID, ORDER_DATE, ORDER_MODE, CUSTOMER_ID, and PROMOTION_ID.
--      - Use a cursor to fetch all data into a variable of type order_rec and display the results.
-- (b) Modify your code in (a) to include the following conditions:
--      - Only orders with no promotions are considered.
--      - The order mode is 'Online'.
--      - The order total is less than 1000.
--      - Sort the results by the most recent order first.

-- (i) Anonymous Block:

DECLARE

    -- Define the record to hold the columns
    TYPE order_rec IS RECORD (
        ORDER_ID       OEHR_ORDERS.ORDER_ID%TYPE,
        ORDER_DATE     OEHR_ORDERS.ORDER_DATE%TYPE,
        ORDER_MODE     OEHR_ORDERS.ORDER_MODE%TYPE,
        CUSTOMER_ID    OEHR_ORDERS.CUSTOMER_ID%TYPE,
        PROMOTION_ID   OEHR_ORDERS.PROMOTION_ID%TYPE
    );

    -- Define a variable of the record type
    v_order order_rec;

    -- Cursor to fetch all data from the OEHR_ORDERS table
    CURSOR order_cursor IS
        SELECT ORDER_ID, ORDER_DATE, ORDER_MODE, CUSTOMER_ID, PROMOTION_ID
        FROM OEHR_ORDERS;

BEGIN

    -- Open the cursor and fetch each row
    FOR v_order IN order_cursor LOOP
        -- Display the values from the record
        DBMS_OUTPUT.PUT_LINE('ORDER_ID: ' || v_order.ORDER_ID);
        DBMS_OUTPUT.PUT_LINE('ORDER_DATE: ' || TO_CHAR(v_order.ORDER_DATE, 'YYYY-MM-DD HH24:MI:SS'));
        DBMS_OUTPUT.PUT_LINE('ORDER_MODE: ' || v_order.ORDER_MODE);
        DBMS_OUTPUT.PUT_LINE('CUSTOMER_ID: ' || v_order.CUSTOMER_ID);
        DBMS_OUTPUT.PUT_LINE('PROMOTION_ID: ' || NVL(TO_CHAR(v_order.PROMOTION_ID), 'N/A'));
        DBMS_OUTPUT.PUT_LINE('----------------------------');
    END LOOP;

END;

-- (ii) Anonymous Block:

DECLARE

    -- Define the record to hold the columns
    TYPE order_rec IS RECORD (
        ORDER_ID       OEHR_ORDERS.ORDER_ID%TYPE,
        ORDER_DATE     OEHR_ORDERS.ORDER_DATE%TYPE,
        ORDER_MODE     OEHR_ORDERS.ORDER_MODE%TYPE,
        CUSTOMER_ID    OEHR_ORDERS.CUSTOMER_ID%TYPE,
        PROMOTION_ID   OEHR_ORDERS.PROMOTION_ID%TYPE
    );

    -- Define a variable of the record type
    v_order order_rec;

    -- Cursor to fetch filtered and sorted data from OEHR_ORDERS table
    CURSOR order_cursor IS
        SELECT ORDER_ID, ORDER_DATE, ORDER_MODE, CUSTOMER_ID, PROMOTION_ID
        FROM OEHR_ORDERS
        WHERE PROMOTION_ID IS NULL -- Only orders with no promotions
        AND ORDER_MODE = 'online' -- Order mode must be online
        AND ORDER_TOTAL < 1000 -- Order total less than 1000
        ORDER BY ORDER_DATE DESC; -- Sort by most recent order first

BEGIN

    -- Open the cursor and fetch each row
    FOR v_order IN order_cursor LOOP
        -- Display the values from the record
        DBMS_OUTPUT.PUT_LINE('ORDER_ID: ' || v_order.ORDER_ID);
        DBMS_OUTPUT.PUT_LINE('ORDER_DATE: ' || TO_CHAR(v_order.ORDER_DATE, 'YYYY-MM-DD HH24:MI:SS'));
        DBMS_OUTPUT.PUT_LINE('ORDER_MODE: ' || v_order.ORDER_MODE);
        DBMS_OUTPUT.PUT_LINE('CUSTOMER_ID: ' || v_order.CUSTOMER_ID);
        DBMS_OUTPUT.PUT_LINE('PROMOTION_ID: ' || NVL(TO_CHAR(v_order.PROMOTION_ID), 'N/A'));
        DBMS_OUTPUT.PUT_LINE('----------------------------');
    END LOOP;

END;


-- (14)
-- (a) Define a PL/SQL trigger that fires for every row before an insert on the table OEHR_ORDERS. The trigger should:
--      - Execute only for orders with an ORDER_MODE of 'Online'.
--      - Display the new value inserted for the column ORDER_DATE.
-- (b) Write an INSERT statement to test the trigger with the following values:
--      - ORDER_ID: 1
--      - ORDER_DATE: The system date
--      - ORDER_MODE: 'Online'
--      - CUSTOMER_ID: 101

-- (i) Trigger:

CREATE OR REPLACE TRIGGER trg_before_insert_oehr_orders
BEFORE INSERT ON OEHR_ORDERS
FOR EACH ROW
BEGIN

    -- Check if the order mode is 'online'
    IF :NEW.ORDER_MODE = 'online' THEN
        -- Display the new order date
        DBMS_OUTPUT.PUT_LINE('New Order Date: ' || TO_CHAR(:NEW.ORDER_DATE, 'YYYY-MM-DD HH24:MI:SS'));
    END IF;

END;

-- (ii) SQL Statement:

INSERT INTO OEHR_ORDERS (ORDER_ID, ORDER_DATE, ORDER_MODE, CUSTOMER_ID)
VALUES (1, SYSDATE, 'online', 101);


-- (15) Write an anonymous block in PL/SQL that uses a VARRAY to store elements of a custom record type.
-- The record must contain the first name, last name and summary of orders for each customer.

-- Sample output: 

-- Array has 99 elements

-- First Name: John
-- Last Name: Doe 
-- Orders total: $48.00 
-- -----------------
-- First Name: Jane 
-- Last Name: Doe 
-- Orders total: $220.00
-- -----------------

-- (i) Anonymous Block:

DECLARE

    -- Define the record to hold customer details (first name, last name, and total orders)
    TYPE r_customer_detail IS RECORD (
        first_name    OEHR_CUSTOMERS.CUST_FIRST_NAME%TYPE,
        last_name     OEHR_CUSTOMERS.CUST_LAST_NAME%TYPE,
        total_orders  OEHR_ORDERS.ORDER_TOTAL%TYPE
    );

    -- Define the VARRAY type (up to 150 elements)
    TYPE t_customer_varray IS VARRAY(150) OF r_customer_detail;

    -- Declare the VARRAY variable
    v_customers t_customer_varray := t_customer_varray();

    -- Cursor to fetch customer and order details
    CURSOR c_customers IS
        SELECT 
            c.CUST_FIRST_NAME, 
            c.CUST_LAST_NAME, 
            NVL(SUM(o.ORDER_TOTAL), 0) AS TOTAL_ORDERS
        FROM 
            OEHR_CUSTOMERS c
        JOIN 
            OEHR_ORDERS o 
        ON 
            c.CUSTOMER_ID = o.CUSTOMER_ID
        GROUP BY 
            c.CUST_FIRST_NAME, c.CUST_LAST_NAME;

BEGIN

    -- Fetch and process each customer
    FOR my_data IN c_customers LOOP
        -- Extend the VARRAY to accommodate the new record
        v_customers.EXTEND;

        -- Add the new customer data to the last element in the VARRAY
        v_customers(v_customers.LAST).first_name := my_data.CUST_FIRST_NAME;
        v_customers(v_customers.LAST).last_name := my_data.CUST_LAST_NAME;
        v_customers(v_customers.LAST).total_orders := my_data.TOTAL_ORDERS;
    END LOOP;

    -- Output the number of elements in the VARRAY
    DBMS_OUTPUT.put_line('Array has ' || v_customers.COUNT || ' elements');
    DBMS_OUTPUT.put_line('');

    -- Display each customer's details from the VARRAY
    FOR i IN v_customers.FIRST..v_customers.LAST LOOP
        DBMS_OUTPUT.put_line('First Name: ' || v_customers(i).first_name);
        DBMS_OUTPUT.put_line('Last Name: ' || v_customers(i).last_name);
        DBMS_OUTPUT.put_line('Orders total: $' || TO_CHAR(v_customers(i).total_orders, 'FM999999.99'));
        DBMS_OUTPUT.put_line('-----------------');
    END LOOP;

END;


