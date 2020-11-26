DROP DATABASE IF EXISTS ChildDaycare;

CREATE DATABASE ChildDaycare;

USE ChildDaycare;


DROP TABLE IF EXISTS DAYCARE;
CREATE TABLE DAYCARE (
     DAYCARENAME VARCHAR(100) NOT NULL
   , DAYCAREADDRESS VARCHAR(100) NOT NULL
   , TOTALNUMOFCARETAKERS INT
   , PRIMARY KEY (DAYCARENAME, DAYCAREADDRESS)
);

DROP TABLE IF EXISTS ROOM;
CREATE TABLE ROOM (
	DAYCARENAME VARCHAR(100) NOT NULL,
	DAYCAREADDRESS VARCHAR(100) NOT NULL,
	ROOMID INT NOT NULL,
	SIZE INT NOT NULL,
	SEATSAVAILABLE INT NOT NULL,
	PRIMARY KEY (DAYCARENAME, DAYCAREADDRESS, ROOMID),
	INDEX(DAYCARENAME, DAYCAREADDRESS),
	FOREIGN KEY (DAYCARENAME, DAYCAREADDRESS) REFERENCES DAYCARE (DAYCARENAME, DAYCAREADDRESS) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS PERSON (
     SIN VARCHAR(8) NOT NULL
   , FIRSTNAME VARCHAR(30)
   , LASTNAME VARCHAR(30)
   , GENDER VARCHAR(30)
   , ADDRUNITNUM INT
   , ADDRSTREET VARCHAR(50)
   , ADDRCITY VARCHAR(20)
   , ADDRPOSTALCODE VARCHAR(20)
   , STARTDAY VARCHAR(10)
   , STARTMONTH VARCHAR(9)
   , STARTYEAR INT
   , PRIMARY KEY (SIN)
);

DROP TABLE IF EXISTS PERSON_PHONE;
CREATE TABLE PERSON_PHONE (
	SIN VARCHAR(8) NOT NULL,
	PHONENUM VARCHAR(20) NOT NULL,
	PRIMARY KEY (SIN, PHONENUM),
	INDEX (SIN),
	FOREIGN KEY (SIN) REFERENCES PERSON (SIN) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS EMPLOYEE;
CREATE TABLE EMPLOYEE (
	DAYCARENAME VARCHAR(100) NOT NULL,
	DAYCAREADDRESS VARCHAR(100) NOT NULL,
	SIN VARCHAR(8) NOT NULL,
	EMPLOYEEID INT NOT NULL,
	WORKHOURS DECIMAL(4,2),
	PRIMARY KEY (DAYCARENAME, DAYCAREADDRESS, SIN, EMPLOYEEID),
	INDEX(DAYCARENAME, DAYCAREADDRESS),
	INDEX(SIN),
	INDEX(EMPLOYEEID),
	FOREIGN KEY (DAYCARENAME, DAYCAREADDRESS) REFERENCES DAYCARE (DAYCARENAME, DAYCAREADDRESS) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (SIN) REFERENCES PERSON (SIN) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS ADMIN;
CREATE TABLE ADMIN (
	SIN VARCHAR(8) NOT NULL,
	EMPLOYEEID INT NOT NULL,
	PRIMARY KEY (SIN, EMPLOYEEID),
	INDEX(SIN),
	INDEX(EMPLOYEEID),
	FOREIGN KEY (SIN) REFERENCES PERSON (SIN) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (EMPLOYEEID) REFERENCES EMPLOYEE (EMPLOYEEID) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS CARETAKER;
CREATE TABLE CARETAKER (
	SIN VARCHAR(8) NOT NULL,
	EMPLOYEEID INT NOT NULL,
	AVAILABILITY BOOLEAN,
	PRIMARY KEY (SIN, EMPLOYEEID),
	INDEX(SIN), INDEX(EMPLOYEEID),
	FOREIGN KEY (SIN) REFERENCES PERSON (SIN) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (EMPLOYEEID) REFERENCES EMPLOYEE (EMPLOYEEID) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS CARETAKER_SPECIALIZATION;
CREATE TABLE CARETAKER_SPECIALIZATION (
	CARETAKERSIN VARCHAR(8) NOT NULL,
	SPECIALIZATIONTYPE VARCHAR(100) NOT NULL,
	PRIMARY KEY (CARETAKERSIN, SPECIALIZATIONTYPE),
	INDEX(CARETAKERSIN),
	FOREIGN KEY (CARETAKERSIN) REFERENCES CARETAKER (SIN) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS BILL;
CREATE TABLE BILL (
	BILLID INT NOT NULL,
	CREATEDBYID INT NOT NULL,
	PAYMENTMETHOD VARCHAR(30),
	AMOUNTPENDING DECIMAL(6,2) NOT NULL,
	PRIMARY KEY (BILLID, CREATEDBYID),
	INDEX (CREATEDBYID),
	FOREIGN KEY (CREATEDBYID) REFERENCES ADMIN (EMPLOYEEID) ON UPDATE CASCADE ON DELETE RESTRICT
);

DROP TABLE IF EXISTS PARENT_GUARDIAN;
CREATE TABLE PARENT_GUARDIAN (
	SIN VARCHAR(8) NOT NULL,
	CARETAKEREMPLOYEEID INT,
	BILLID INT,
	PRIMARY KEY (SIN, CARETAKEREMPLOYEEID, BILLID),
	INDEX (SIN), INDEX (CARETAKEREMPLOYEEID), INDEX (BILLID),
	FOREIGN KEY (SIN) REFERENCES PERSON (SIN) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (CARETAKEREMPLOYEEID) REFERENCES CARETAKER (EMPLOYEEID) ON UPDATE CASCADE ON DELETE RESTRICT,
	FOREIGN KEY (BILLID) REFERENCES BILL (BILLID) ON UPDATE CASCADE ON DELETE RESTRICT
);

DROP TABLE IF  EXISTS CHILD;
CREATE TABLE CHILD (
	SIN VARCHAR(8) NOT NULL,
	CARETAKEREMPLOYEEID INT NOT NULL,
	PARENTSIN VARCHAR(8) NOT NULL,
	DATEOFBIRTH DATE NOT NULL,
	PRIMARY KEY (SIN, CARETAKEREMPLOYEEID, PARENTSIN),
	INDEX (SIN), INDEX (CARETAKEREMPLOYEEID), INDEX (PARENTSIN),
	FOREIGN KEY (SIN) REFERENCES PERSON (SIN) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (CARETAKEREMPLOYEEID) REFERENCES CARETAKER (EMPLOYEEID) ON UPDATE CASCADE ON DELETE RESTRICT,
	FOREIGN KEY (PARENTSIN) REFERENCES PARENT_GUARDIAN (SIN) ON UPDATE CASCADE ON DELETE RESTRICT
);

DROP TABLE IF EXISTS CONDITIONS;
CREATE TABLE CONDITIONS (
	CHILDSIN VARCHAR(8) NOT NULL,
	CONDITIONNAME VARCHAR(100) NOT NULL,
	CONDITIONTREATMENT VARCHAR(100) NOT NULL,
	PRIMARY KEY (CHILDSIN, CONDITIONNAME, CONDITIONTREATMENT),
	INDEX (CHILDSIN),
	CONSTRAINT FOREIGN KEY (CHILDSIN) REFERENCES CHILD (SIN) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS WAITLIST;
CREATE TABLE WAITLIST (
	CHILDNAME VARCHAR(30) NOT NULL,
	FAMILYNAME VARCHAR(30) NOT NULL,
	SUBMITTEDBYID INT NOT NULL,
	PRIMARY KEY (CHILDNAME, FAMILYNAME, SUBMITTEDBYID),
	INDEX (SUBMITTEDBYID),
	FOREIGN KEY (SUBMITTEDBYID) REFERENCES ADMIN (EMPLOYEEID) ON UPDATE CASCADE ON DELETE RESTRICT
);

DROP TABLE IF EXISTS DAILY_REPORT;
CREATE TABLE DAILY_REPORT (
	CHILDSIN VARCHAR(8) NOT NULL,
	REPORTID INT NOT NULL,	
	CARETAKEREMPLOYEEID INT NOT NULL,	
	REPORTDATE DATE NOT NULL,
	STARTTIME DATETIME,
	ENDTIME DATETIME,
	REPORTCOMMENT VARCHAR(100),
	INDEX (CHILDSIN), INDEX (CARETAKEREMPLOYEEID), INDEX (REPORTID),
	PRIMARY KEY (CHILDSIN, REPORTDATE, REPORTID, CARETAKEREMPLOYEEID),
	FOREIGN KEY (CHILDSIN) REFERENCES CHILD (SIN) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (CARETAKEREMPLOYEEID) REFERENCES CARETAKER (EMPLOYEEID) ON UPDATE CASCADE ON DELETE RESTRICT
);

DROP TABLE IF EXISTS INCIDENTS;
CREATE TABLE INCIDENTS (
	REPORTID INT NOT NULL,
	ACTIONREQUIRED VARCHAR(100),
	INDEX (REPORTID),
	PRIMARY KEY (REPORTID),
	FOREIGN KEY (REPORTID) REFERENCES DAILY_REPORT (REPORTID) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS ACTIVITIES;
CREATE TABLE ACTIVITIES (
	REPORTID INT NOT NULL,
	LESSONSLEARNED VARCHAR(100),
	INDEX (REPORTID),
	PRIMARY KEY (REPORTID),
	FOREIGN KEY (REPORTID) REFERENCES DAILY_REPORT (REPORTID) ON UPDATE CASCADE ON DELETE CASCADE
);




INSERT INTO PERSON VALUES 
('12345678', 'Erin', 'Employee', 'Female', 123, 'Calgary Drive', 'Calgary', 'T2X 2E3', '09','07',2003),
('11122233', 'Joe', 'Fresh', 'Male',456, 'Also Clagary Dr', 'Calgary','T2X 2E3','12','10',2008), 
('11111111', 'First', 'Child', 'Female', 10, 'Home address','Calgary', 'T2X 2E3','19','07',2011), 
('11111112', 'Child', 'Parent', 'Male', 30, 'Home address','Calgary', 'T2X 2E3','09','07',2003), 
('99988877', 'Admin', 'Lady', 'Female', 107, 'The Daycare St', 'Calgary', 'T5R 0R4','29','10',2008), 
('55566777', 'A Child', 'Person', 'Male', 10, 'Also Clagary Dr', 'Calgary', 'T5R 0R4', '12','10',2008), 
('44433222', 'Dr', 'Employee', 'Male', 1000, 'The Mansion','Calgary', 'T5R 0R4', '10','10',2010);

INSERT INTO DAYCARE VALUES ('Daycare One', 'Daycare Street NW', 5), ('Daycare Two', 'Other Daycare Street', 30);

INSERT INTO ROOM VALUES ('Daycare One', 'Daycare Street NW', 1, 5, 4), ('Daycare Two', 'Other Daycare Street', 1, 10, 8), ('Daycare One', 'Daycare Street NW', 2, 3, 1);

INSERT INTO PERSON_PHONE VALUES ('12345678', '4035551234'), ('12345678', '4035551223'), ('11122233', '4035556543'), ('11111112', '1123456789'), ('99988877','1233334444'), ('44433222', '4039999911');

INSERT INTO EMPLOYEE VALUES ('Daycare One', 'Daycare Street NW', '12345678', 5555, '8.0'), ('Daycare One', 'Daycare Street NW', '44433222', 5550, '12.0'), ('Daycare One', 'Daycare Street NW', '99988877', 1234, '10.0');

INSERT INTO CARETAKER VALUES ('12345678', 5555, TRUE), ('44433222', 5550, TRUE);

INSERT INTO ADMIN VALUES ('99988877', 1234);

INSERT INTO BILL VALUES (12345, 1234, 'MasterCard', 0.00), (43434, 1234, NULL, 30.00);

INSERT INTO WAITLIST VALUES ('Possible New Child', 'Theior Family', 1234), ('Evil Child', 'Nice Family', 1234);

INSERT INTO CARETAKER_SPECIALIZATION VALUES ('12345678', 'Eating Disorders'), ('12345678', 'Healthy Eating'), ('44433222', 'Trauma'), ('44433222', 'OCD');

INSERT INTO PARENT_GUARDIAN VALUES ('11122233', 5555, 12345), ('11111112', 5550, 43434);

INSERT INTO CHILD VALUES ('11111111', 5555, '11122233', STR_TO_DATE('12,10,2005', '%d, %m, %Y')), ('55566777', 5550, '11111112', STR_TO_DATE('06,06,2007','%d, %m, %Y'));

INSERT INTO CONDITIONS VALUES ('11111111', 'Celiac Disease', 'Gluten Free Diet'), ('11111111', 'Asthma', 'Inhaler'), ('55566777', 'Asthma', 'Inhaler'), ('55566777', 'OCD', 'Monitor Actions');

INSERT INTO DAILY_REPORT VALUES ('11111111', 1, 5555, STR_TO_DATE('01,01,2020','%d, %m, %Y'),   '2020-01-01 10:10:10', '2020-01-01 10:15:10', 'Good job child'), ('55566777', 2, 5550, STR_TO_DATE('01,01,2020','%d, %m, %Y'),  '2020-01-01 10:05:10', '2020-01-01 10:20:10', 'Bad child');

INSERT INTO INCIDENTS VALUES (2, 'Needs to be talked to about behaviour');

INSERT INTO ACTIVITIES VALUES (1, 'Learned about space');