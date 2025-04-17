-- Author: Mohammad Raafay Shehzad (mrs6578)
-- Library Checkout System DDL Script


-- DROP TABLES AND SEQUENCES
-- Drops all tables and sequences to remove existing data
-- Author: Mohammad Raafay Shehzad (mrs6578)
DROP TABLE Patron_Phone;
DROP TABLE Patron_Title_Holds;
DROP TABLE Checkouts;
DROP TABLE Title_Loc_Linking;
DROP TABLE Title_Author_Linking;
DROP TABLE Patron;
DROP TABLE Title;
DROP TABLE Author;
DROP TABLE Location;

DROP SEQUENCE patron_seq;
DROP SEQUENCE phone_seq;
DROP SEQUENCE title_seq;
DROP SEQUENCE author_seq;
DROP SEQUENCE title_copy_seq;


-- CREATE SEQUENCES AND TABLES
-- Creates all the required tables and sequences for the library checkout system
-- Author: Mohammad Raafay Shehzad (mrs6578)
CREATE SEQUENCE patron_seq START WITH 1 INCREMENT BY 1 ORDER;
CREATE SEQUENCE phone_seq START WITH 1 INCREMENT BY 1 ORDER;
CREATE SEQUENCE title_seq START WITH 1 INCREMENT BY 1 ORDER;
CREATE SEQUENCE author_seq START WITH 1 INCREMENT BY 1 ORDER;
CREATE SEQUENCE title_copy_seq START WITH 100001 INCREMENT BY 1 ORDER;

CREATE TABLE Patron (
    Patron_ID NUMBER PRIMARY KEY,
    First_Name VARCHAR2(50) NOT NULL,
    Last_Name VARCHAR2(50) NOT NULL,
    Email VARCHAR2(100) UNIQUE NOT NULL,
    Address_Line_1 VARCHAR2(100) NOT NULL,
    Address_Line_2 VARCHAR2(100),
    City VARCHAR2(50) NOT NULL,
    State CHAR(2) NOT NULL,
    Zip CHAR(5) NOT NULL,
    Accrued_Fees NUMBER DEFAULT 0,
    Primary_Branch NUMBER NOT NULL
);
CREATE TABLE Patron_Phone (
    Phone_ID NUMBER PRIMARY KEY,
    Patron_ID NUMBER REFERENCES Patron(Patron_ID),
    Phone_Type VARCHAR2(20) NOT NULL,
    Phone CHAR(12) NOT NULL
);
CREATE TABLE Title (
    Title_ID NUMBER PRIMARY KEY,
    Title VARCHAR2(255) NOT NULL,
    Publisher VARCHAR2(100) NOT NULL,
    Publish_Date DATE NOT NULL,
    Number_of_pages NUMBER,
    Format CHAR(1) NOT NULL,
    Genre VARCHAR2(3) NOT NULL,
    ISBN VARCHAR2(20) UNIQUE NOT NULL
);
CREATE TABLE Patron_Title_Holds (
    Hold_ID NUMBER PRIMARY KEY,
    Patron_ID NUMBER REFERENCES Patron(Patron_ID),
    Title_ID NUMBER REFERENCES Title(Title_ID),
    Date_Held DATE NOT NULL
);
CREATE TABLE Location (
    Branch_ID NUMBER PRIMARY KEY,
    Branch_Name VARCHAR2(100) UNIQUE NOT NULL,
    Address VARCHAR2(100) NOT NULL,
    City VARCHAR2(50) NOT NULL,
    State CHAR(2) NOT NULL,
    Zip CHAR(5) NOT NULL,
    Phone CHAR(12) NOT NULL
);
CREATE TABLE Title_Loc_Linking (
    Title_Copy_ID NUMBER PRIMARY KEY,
    Title_ID NUMBER REFERENCES Title(Title_ID),
    Last_Location NUMBER REFERENCES Location(Branch_ID),
    Status CHAR(1) CHECK (Status IN ('T', 'P', 'A', 'O'))
);
CREATE TABLE Checkouts (
    Checkout_ID NUMBER PRIMARY KEY,
    Patron_ID NUMBER REFERENCES Patron(Patron_ID),
    Title_Copy_ID NUMBER REFERENCES Title_Loc_Linking(Title_Copy_ID),
    Date_Out DATE DEFAULT SYSDATE,
    Due_Back_Date DATE NOT NULL,
    Date_In DATE,
    Times_Renewed NUMBER DEFAULT 0 CHECK (Times_Renewed <= 2),
    Late_Flag CHAR(1) DEFAULT 'N' CHECK (Late_Flag IN ('Y', 'N'))
);
CREATE TABLE Author (
    Author_ID NUMBER PRIMARY KEY,
    First_Name VARCHAR2(50) NOT NULL,
    Middle_Name VARCHAR2(50),
    Last_Name VARCHAR2(50) NOT NULL,
    Bio_Notes VARCHAR2(255)
);
CREATE TABLE Title_Author_Linking (
    Author_ID NUMBER REFERENCES Author(Author_ID),
    Title_ID NUMBER REFERENCES Title(Title_ID),
    PRIMARY KEY (Author_ID, Title_ID)
);


-- INSERT DATA
-- Inserts test data into the created tables
-- Author: Mohammad Raafay Shehzad (mrs6578)

-- Inserts Locations
INSERT INTO Location VALUES (1, 'Central Library', '123 Main St', 'Houston', 'TX', '77001', '713-123-4567');
INSERT INTO Location VALUES (2, 'North Branch', '456 Elm St', 'Houston', 'TX', '77002', '713-987-6543');
INSERT INTO Location VALUES (3, 'South Branch', '789 Pine St', 'Houston', 'TX', '77003', '713-654-3210');
INSERT INTO Location VALUES (4, 'East Branch', '321 Oak St', 'Houston', 'TX', '77004', '713-321-6549');
INSERT INTO Location VALUES (5, 'West Branch', '654 Birch St', 'Houston', 'TX', '77005', '713-789-1230');
INSERT INTO Location VALUES (6, 'Downtown Library', '987 Cedar St', 'Houston', 'TX', '77006', '713-951-7894');
COMMIT;
-- Insert Patrons
INSERT INTO Patron VALUES (patron_seq.NEXTVAL, 'Mohammad', 'Shehzad', 'mrs6578@utexas.edu', '17310 Legend Run Ct', NULL, 'Tomball', 'TX', '77375', 0, 1);
INSERT INTO Patron VALUES (patron_seq.NEXTVAL, 'Jane', 'Smith', 'js456@utexas.edu', '567 Pine St', NULL, 'Houston', 'TX', '77004', 0, 2);
COMMIT;
-- Insert Patrons Phones
INSERT INTO Patron_Phone VALUES (phone_seq.NEXTVAL, 1, 'Mobile', '713-555-1234');
INSERT INTO Patron_Phone VALUES (phone_seq.NEXTVAL, 1, 'Home', '713-555-5678');
INSERT INTO Patron_Phone VALUES (phone_seq.NEXTVAL, 2, 'Mobile', '713-555-8765');
COMMIT;
-- Insert Titles
INSERT INTO Title VALUES (title_seq.NEXTVAL, 'The Mysterious Affair', 'Penguin', DATE '2020-06-15', 300, 'H', 'MYS', '1234567890123');
INSERT INTO Title VALUES (title_seq.NEXTVAL, 'The Wonders of Science', 'Harper', DATE '2019-03-22', 250, 'P', 'SCI', '9876543210987');
INSERT INTO Title VALUES (title_seq.NEXTVAL, 'Fictional Realities', 'Random House', DATE '2021-11-10', 400, 'H', 'FIC', '1122334455667');
INSERT INTO Title VALUES (title_seq.NEXTVAL, 'Biography of a Legend', 'Oxford', DATE '2018-07-30', 275, 'P', 'BIO', '6655443322119');
COMMIT;
-- Insert Authors
INSERT INTO Author VALUES (author_seq.NEXTVAL, 'Agatha', NULL, 'Christie', 'Famous mystery writer');
INSERT INTO Author VALUES (author_seq.NEXTVAL, 'Carl', 'Sagan', 'Smith', 'Renowned scientist and author');
INSERT INTO Author VALUES (author_seq.NEXTVAL, 'Jane', NULL, 'Doe', 'Award-winning fiction writer');
INSERT INTO Author VALUES (author_seq.NEXTVAL, 'John', 'A.', 'Legend', 'Historian and biographer');
INSERT INTO Author VALUES (author_seq.NEXTVAL, 'Co', NULL, 'Author', 'Co-author of Fictional Realities');
COMMIT;
-- Link Authors to Titles
INSERT INTO Title_Author_Linking VALUES (1, 1);
INSERT INTO Title_Author_Linking VALUES (2, 2);
INSERT INTO Title_Author_Linking VALUES (3, 3);
INSERT INTO Title_Author_Linking VALUES (4, 4);
INSERT INTO Title_Author_Linking VALUES (5, 3);
COMMIT;
-- Insert Title Copies
INSERT INTO Title_Loc_Linking VALUES (title_copy_seq.NEXTVAL, 1, 1, 'A');
INSERT INTO Title_Loc_Linking VALUES (title_copy_seq.NEXTVAL, 1, 2, 'A');
INSERT INTO Title_Loc_Linking VALUES (title_copy_seq.NEXTVAL, 2, 3, 'A');
INSERT INTO Title_Loc_Linking VALUES (title_copy_seq.NEXTVAL, 2, 4, 'A');
INSERT INTO Title_Loc_Linking VALUES (title_copy_seq.NEXTVAL, 3, 5, 'A');
INSERT INTO Title_Loc_Linking VALUES (title_copy_seq.NEXTVAL, 3, 6, 'A');
INSERT INTO Title_Loc_Linking VALUES (title_copy_seq.NEXTVAL, 4, 1, 'A');
INSERT INTO Title_Loc_Linking VALUES (title_copy_seq.NEXTVAL, 4, 2, 'A');
COMMIT;
-- Insert Holds
INSERT INTO Patron_Title_Holds VALUES (1, 1, 1, SYSDATE);
INSERT INTO Patron_Title_Holds VALUES (2, 1, 2, SYSDATE);
INSERT INTO Patron_Title_Holds VALUES (3, 2, 3, SYSDATE);
COMMIT;
-- Insert Checkouts
INSERT INTO Checkouts VALUES (1, 1, 100001, SYSDATE, SYSDATE + 14, NULL, 0, 'N');
INSERT INTO Checkouts VALUES (2, 1, 100002, SYSDATE, SYSDATE + 14, NULL, 0, 'N');
INSERT INTO Checkouts VALUES (3, 2, 100003, SYSDATE, SYSDATE + 14, NULL, 0, 'N');
COMMIT;


-- CREATE INDEXES
-- Adds indexes to improve query performance on frequently searched columns
-- Author: Mohammad Raafay Shehzad (mrs6578)
CREATE INDEX idx_patron_email ON Patron(Email);
CREATE INDEX idx_title_isbn ON Title(ISBN);
CREATE INDEX idx_checkout_patron ON Checkouts(Patron_ID);
CREATE INDEX idx_checkout_title_copy ON Checkouts(Title_Copy_ID);
COMMIT;