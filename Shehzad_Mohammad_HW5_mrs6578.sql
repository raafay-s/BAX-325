-- HW5 DataType & Functions
-- Name: Mohammad Raafay Shehzad
-- UTEID: mrs6578

-- Question 1
SELECT 
    SYSDATE,
    TRIM(TO_CHAR(SYSDATE, 'YEAR')) AS YEAR_IN_CAPS,
    TRIM(TO_CHAR(SYSDATE, 'DAY MONTH')) AS DAY_MONTH_IN_CAPS,
    ROUND(TO_NUMBER(TO_CHAR(SYSDATE, 'HH24'))) AS HOUR_ONLY,
    TRUNC(TO_DATE('12/31/' || TO_CHAR(SYSDATE, 'YYYY'), 'MM/DD/YYYY') - SYSDATE) AS DAYS_UNTIL_YEAR_END,
    LOWER(TRIM(TO_CHAR(SYSDATE, 'DY MON YYYY'))) AS ABBREV_DAY_MONTH_YEAR,
    TO_CHAR(102000.88, '$999,999.99') AS IDEAL_SALARY
FROM 
    DUAL;

-- Question 2
SELECT
    p.first_name || ' ' || p.last_name AS patron,
    'Checkout ' || c.checkout_id || ' due back on ' || TO_CHAR(c.due_back_date, 'DD-MON-YY') AS checkout_due_back,
    NVL2(c.date_in, 'Returned', 'Not returned yet') AS return_status,
    'Accrued fee total is: ' || 
        CASE 
            WHEN p.accrued_fees = 0 THEN '$.00'
            ELSE '$' || TO_CHAR(p.accrued_fees, '9990.99')
        END AS fees
FROM 
    checkouts c
JOIN 
    patron p ON c.patron_id = p.patron_id
ORDER BY 
    return_status,
    c.due_back_date;

-- Question 3
SELECT 
    patron.primary_branch AS PRIMARY_BRANCH,
    LOWER(SUBSTR(patron.first_name, 1, 1)) || '.' || UPPER(patron.last_name) AS INACTIVE_PATRON
FROM 
    patron
LEFT JOIN 
    checkouts ON patron.patron_id = checkouts.patron_id
WHERE 
    checkouts.checkout_id IS NULL
ORDER BY 
    patron.primary_branch, patron.last_name;

-- Question 4
SELECT 
    title AS book_title,
    LENGTH(title) AS length_of_title,
    publish_date,
    FLOOR((SYSDATE - publish_date) / 365.25) AS age_of_book
FROM 
    title
WHERE 
    FLOOR((SYSDATE - publish_date) / 365.25) >= 5
ORDER BY 
    age_of_book ASC;

-- Question 5
SELECT
    branch_id,
    SUBSTR(branch_name, 1, INSTR(branch_name, ' ') - 1) AS district,
    SUBSTR(address, 1, INSTR(address, ' ') - 1) AS street_num,
    SUBSTR(address, INSTR(address, ' ') + 1) AS street_name
FROM location;

-- Question 6
SELECT
    p.first_name,
    p.last_name,
    '*******' || SUBSTR(p.email, INSTR(p.email, '@')) AS redacted_email,
    ph.phone_type,
    '***-***-' || SUBSTR(ph.PHONE, -4) AS redacted_phone
FROM patron p
JOIN PATRON_PHONE ph ON p.patron_id = ph.patron_id;

-- Question 7
SELECT
    CASE
        WHEN number_of_pages > 700 THEN 'College'
        WHEN number_of_pages BETWEEN 250 AND 700 THEN 'High-School'
        ELSE 'Middle-School'
    END AS reading_level,
    title,
    publisher,
    number_of_pages,
    genre
FROM 
    title
WHERE 
    format IN ('B', 'E')
ORDER BY 
    reading_level,
    title;

--Question 8
SELECT 
    DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT c.checkout_id) DESC) AS popularity_rank,
    t.title,
    COUNT(DISTINCT c.checkout_id) AS number_of_checkouts
FROM 
    title t
LEFT JOIN 
    checkouts c ON t.title_id = c.title_id
GROUP BY 
    t.title
ORDER BY 
    number_of_checkouts DESC,
    t.title ASC;

--Question 9a
SELECT 
    ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT c.checkout_id) DESC, t.title ASC) AS row_number,
    t.title,
    COUNT(DISTINCT c.checkout_id) AS number_of_checkouts
FROM 
    title t
LEFT JOIN 
    checkouts c ON t.title_id = c.title_id
GROUP BY 
    t.title
ORDER BY 
    row_number;
    
-- Questioon 9b
SELECT *
FROM (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT c.checkout_id) DESC, t.title ASC) AS row_number,
        t.title,
        COUNT(DISTINCT c.checkout_id) AS number_of_checkouts
    FROM 
        title t
    LEFT JOIN 
        checkouts c ON t.title_id = c.title_id
    GROUP BY 
        t.title
) sub
WHERE 
    row_number = 58;

--Question 10
SELECT 
    l.primary_branch,
    p.patron_id,
    TO_CHAR(SUM(p.accrued_fees), '$999,999.00') AS total_fee
FROM 
    patron p
JOIN 
    location l ON p.primary_branch = l.branch_id
GROUP BY 
    l.primary_branch, p.patron_id
ORDER BY 
    total_fee DESC;