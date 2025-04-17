-- HW4 Summary/Subquery
-- Name: Mohammad Raafay Shehzad
-- UTEID: mrs6578

-- 1. Patron summary stats (count, distinct zips, min, avg, max fees)
---------------------------------------------------
SELECT
    COUNT(DISTINCT patron_id) AS Patron_Count,
    COUNT(DISTINCT zip) AS Distinct_Zipcodes,
    MIN(accrued_fees) AS Lowest_Fees,
    ROUND(AVG(accrued_fees), 2) AS Average_Fees,
    MAX(accrued_fees) AS Highest_Fees
FROM patron;

-- 2. Patron count per branch
---------------------------------------------------
SELECT 
    l.branch_name,
    COUNT(p.patron_id) AS Patron_Count
FROM location l
LEFT JOIN patron p ON l.branch_id = p.primary_branch
GROUP BY l.branch_name
ORDER BY l.branch_name

-- 3. Avg accrued fees by zip (non-late checkouts only)
---------------------------------------------------
SELECT 
    p.zip AS Zip,
    ROUND(AVG(p.accrued_fees), 2) AS Average_Accrued_Fees
FROM patron p
JOIN checkouts c ON p.patron_id = c.patron_id
WHERE c.late_flag != 'Y'
GROUP BY p.zip
ORDER BY Average_Accrued_Fees DESC;

-- 4. Branches with avg overdue days ≥ 10 (not yet returned)
---------------------------------------------------
SELECT 
    l.branch_name AS Branch_Name,
    ROUND(AVG(SYSDATE - c.due_back_date)) AS Avg_Days_Overdue
FROM Checkouts c
JOIN Location l ON c.branch_id = l.branch_id
WHERE c.date_in IS NULL
  AND (SYSDATE - c.due_back_date) > 0
GROUP BY l.branch_name
HAVING ROUND(AVG(SYSDATE - c.due_back_date)) >= 10;

-- 5. Titles with more than 1 author
---------------------------------------------------
SELECT 
    t.title,
    t.genre,
    COUNT(ta.author_id) AS Author_Count
FROM title t
JOIN title_author_linking ta ON t.title_id = ta.title_id
GROUP BY t.title, t.genre
HAVING COUNT(ta.author_id) > 1
ORDER BY t.genre DESC, t.title ASC;

-- 6. Titles with ≥ 2 PhD authors
---------------------------------------------------
SELECT 
    t.title,
    t.genre,
    COUNT(*) AS Author_Count
FROM Title t
JOIN Title_Author_Linking tal ON t.title_id = tal.title_id
JOIN Author a ON tal.author_id = a.author_id
WHERE a.last_name LIKE '%PhD%'
GROUP BY t.title, t.genre
HAVING COUNT(*) >= 2
ORDER BY t.genre DESC, t.title ASC;

-- 7A. Average accrued fees by city with ROLLUP
--------------------------------------------------------------
SELECT 
    city,
    ROUND(AVG(accrued_fees), 2) AS Avg_Fees
FROM Patron
GROUP BY ROLLUP(city);

-- Insight:
-- Cities with higher averages may indicate problem areas with compliance or reminders.

-- 7B. Average accrued fees by city and zip with ROLLUP (non-zero fees only)
--------------------------------------------------------------
SELECT 
    city,
    zip,
    ROUND(AVG(accrued_fees), 2) AS Avg_Fees
FROM Patron
WHERE accrued_fees > 0
GROUP BY ROLLUP(city, zip);

-- Insight:
-- The two most problematic zip codes based on highest average fees are:
-- 73940 (West Guillory) with $7.25 and 73946 (Guillory) with $2.32

-- 8. Branches with too few or too many copies of titles
--------------------------------------------------------------
SELECT 
    l.branch_id,
    l.branch_name,
    COUNT(tc.copy_id) AS Count_of_Title_Copies
FROM Location l
JOIN Title_Copies tc ON l.branch_id = tc.branch_id
GROUP BY l.branch_id, l.branch_name
HAVING COUNT(tc.copy_id) NOT BETWEEN 40 AND 50;

-- 9. Subquery with IN instead of JOIN
--------------------------------------------------------------
SELECT 
    title,
    format,
    genre,
    isbn
FROM Title
WHERE title_id IN (
    SELECT title_id FROM Patron_Title_Holds
)
ORDER BY genre, title;

-- 10. Titles with more than average pages
--------------------------------------------------------------
SELECT 
    title,
    publisher,
    number_of_pages,
    genre
FROM Title
WHERE number_of_pages > (
    SELECT AVG(number_of_pages) FROM Title
)
ORDER BY genre ASC, number_of_pages DESC;

-- 11. Patrons without phone numbers
--------------------------------------------------------------
SELECT 
    first_name,
    last_name,
    email
FROM Patron
WHERE patron_id NOT IN (
    SELECT patron_id FROM Patron_Phone
)
ORDER BY last_name;

-- 12. Titles from publishers with more than 3 books (inline join)
--------------------------------------------------------------
SELECT 
    t.title,
    t.publisher,
    t.genre,
    t.isbn
FROM Title t
JOIN (
    SELECT publisher, COUNT(*) AS count_titles
    FROM Title
    GROUP BY publisher
    HAVING COUNT(*) > 3
) popular_publishers ON t.publisher = popular_publishers.publisher
ORDER BY t.publisher;

-- 13. Patrons with current checkouts and accrued fees
--------------------------------------------------------------
SELECT 
    patron_id,
    email,
    accrued_fees,
    primary_branch
FROM Patron
WHERE patron_id IN (
    SELECT DISTINCT patron_id
    FROM Checkouts
    WHERE date_in IS NULL
)
AND accrued_fees > 0
ORDER BY primary_branch, email;