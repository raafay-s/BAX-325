-- HW3 SQL Queries
-- Name: Mohammad Raafay Shehzad
-- UTEID: mrs6578

-- Problem 1: Update late flag for overdue books
UPDATE Checkouts
SET late_flag = 'Y'
WHERE due_back_date < SYSDATE;

-- Problem 2: Select patron_id, phone_type, and phone from patron_phone table
SELECT patron_id, phone_type, phone
FROM Patron_Phone
ORDER BY patron_id ASC, phone_type ASC;

-- Problem 3: Combine first and last name, sort by alias in descending order
SELECT first_name || ' ' || last_name AS patron_full_name
FROM Patron
WHERE first_name LIKE 'J%' OR first_name LIKE 'M%' OR first_name LIKE 'O%'
ORDER BY patron_full_name DESC;

-- Problem 4: Checkouts between December 15, 2024, and January 15, 2025
SELECT patron_id, title_copy_id, date_out, due_back_date, date_in
FROM Checkouts
WHERE date_out BETWEEN TO_DATE('2024-12-15', 'YYYY-MM-DD') AND TO_DATE('2025-01-15', 'YYYY-MM-DD')
ORDER BY date_in ASC, date_out ASC;

-- Problem 5: Same as problem 4, but using comparison operators
SELECT patron_id, title_copy_id, date_out, due_back_date, date_in
FROM Checkouts
WHERE date_out >= TO_DATE('2024-12-15', 'YYYY-MM-DD') AND date_out <= TO_DATE('2025-01-15', 'YYYY-MM-DD')
ORDER BY date_in ASC, date_out ASC;

-- Problem 6: Join Checkouts and Patron tables, calculate renewals left
SELECT p.first_name, c.checkout_id, c.title_copy_id, (2 - c.times_renewed) AS renewals_left
FROM Checkouts c
JOIN Patron p ON c.patron_id = p.patron_id
WHERE ROWNUM <= 5
ORDER BY renewals_left ASC;

-- Problem 7: Calculate Book_Level and filter books greater than level 6
SELECT title, genre, ROUND(number_of_pages / 100, 2) AS Book_Level
FROM Title
WHERE ROUND(number_of_pages / 100, 2) > 6
ORDER BY Book_Level ASC;
-- Answer to the questions:
-- (1) Can you use the alias 'Book_Level' in the WHERE clause? No, because the WHERE clause is processed before the SELECT clause, so the alias is not recognized yet.
-- (2) Why? SQL processes the WHERE clause before the SELECT clause, so the alias is not available for filtering.
-- (3) Can you use the alias in the ORDER BY clause? Yes, because the ORDER BY clause is processed after the SELECT clause, so the alias is available.

-- Problem 8: Join Author and Title, filter non-null middle names
SELECT a.first_name, a.middle_name, a.last_name, t.title, t.publish_date
FROM Author a
JOIN Title_Author_Linking tal ON a.author_id = tal.author_id
JOIN Title t ON tal.title_id = t.title_id
WHERE a.middle_name IS NOT NULL
ORDER BY 3, 4, 5;

-- Problem 9: Display system date with formatted output and calculations
SELECT SYSDATE AS today_unformatted, TO_CHAR(SYSDATE, 'DD/MM/YYYY') AS "British Date",
5 AS Days_Late, 0.25 AS Late_fee, (5 * 0.25) AS Total_late_fees, (5 - (5 * 0.25)) AS Late_fees_until_lock
FROM DUAL;

-- Problem 10: Books in both East and North Branch
SELECT l.branch_name, tll.publisher, tll.title_id, tll.title
FROM Location l
JOIN Title_Loc_Linking tll ON l.branch_id = tll.last_location
WHERE l.branch_name IN ('East', 'North')
ORDER BY l.branch_name, tll.publisher, tll.title;

-- Problem 11: Distinct list of genres from the Title table
SELECT DISTINCT genre
FROM Title
ORDER BY genre ASC;

-- Problem 12: Titles containing the word 'Bird' (case-insensitive)
SELECT title
FROM Title
WHERE LOWER(title) LIKE '%bird%';

-- Problem 13: Join Patron and Patron_Phone tables
SELECT p.first_name || ' ' || p.last_name AS Full_Name, pp.phone_type, pp.phone
FROM Patron p
JOIN Patron_Phone pp ON p.patron_id = pp.patron_id
ORDER BY p.last_name ASC, pp.phone_type DESC;

-- Problem 14: Patrons from Northeast Central with fees
SELECT p.first_name, p.last_name, p.email, p.accrued_fees
FROM Patron p
JOIN Location l ON p.primary_branch = l.branch_id
WHERE l.branch_name = 'Northeast Central' AND p.accrued_fees > 0
ORDER BY p.accrued_fees DESC;

-- Problem 15: Books by author in 'Book' format and 'FIC' genre
SELECT t.title AS FICTION_TITLE, t.number_of_pages, a.first_name || ' ' || a.last_name AS author_name
FROM Title t
JOIN Title_Author_Linking tal ON t.title_id = tal.title_id
JOIN Author a ON tal.author_id = a.author_id
WHERE t.format = 'B' AND t.genre = 'FIC'
ORDER BY author_name, t.title ASC;

-- Problem 16: Titles without holds using outer join
SELECT t.title, t.format, t.genre, t.isbn
FROM Title t
LEFT JOIN Patron_Title_Holds pth ON t.title_id = pth.title_id
WHERE pth.hold_id IS NULL
ORDER BY t.genre, t.title ASC;

-- Problem 17: Sci-Fi titles and associated holds
SELECT t.title, p.first_name, p.last_name, pth.hold_id
FROM Title t
LEFT JOIN Patron_Title_Holds pth ON t.title_id = pth.title_id
LEFT JOIN Patron p ON pth.patron_id = p.patron_id
WHERE t.genre = 'SCI'
ORDER BY t.title ASC;

-- Problem 18: Titles with Reading_Level
SELECT t.title, t.publisher, t.number_of_pages, t.genre, 'College' AS Reading_Level
FROM Title t
WHERE t.format IN ('B', 'E') AND t.number_of_pages > 700
UNION ALL

SELECT t.title, t.publisher, t.number_of_pages, t.genre, 'High School' AS Reading_Level
FROM Title t
WHERE t.format IN ('B', 'E') AND t.number_of_pages BETWEEN 251 AND 700
UNION ALL

SELECT t.title, t.publisher, t.number_of_pages, t.genre, 'Middle School' AS Reading_Level
FROM Title t
WHERE t.format IN ('B', 'E') AND t.number_of_pages <= 250

ORDER BY Reading_Level, t.title;