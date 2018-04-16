----CS1555/2055 - DATABASE MANAGEMENT SYSTEMS (Spring 2018)
----DEPT. OF COMPUTER SCIENCE, UNIVERSITY OF PITTSBURGH
----ASSIGNMENT #8: Integrity Constraint, Transaction and Indexing
----Release: Apr. 3, 2018
--Siming Zheng
--siz11

-- Clean up
drop table report cascade constraints;
drop table coverage cascade constraints;
drop table intersection cascade constraints;
drop table road cascade constraints;
drop table sensor cascade constraints;
drop table worker cascade constraints;
drop table forest cascade constraints;
drop table state cascade constraints;

-- Create tables
--(1)
create table FOREST (
    Forest_No   varchar2(10),
    Name	varchar2(30),
    Area	float,
    Acid_Level	float,
    MBR_XMin	float,
    MBR_XMax	float,
    MBR_YMin	float,
    MBR_YMax	float,
    Constraint forest_PK primary key (Forest_No) deferrable,
    Constraint forest_UQ_name UNIQUE(name) initially immediate deferrable,
    Constraint forest_UQ_MBR UNIQUE(MBR_XMin, MBR_XMax, MBR_YMin, MBR_YMax) initially immediate deferrable
);

create table STATE (
	Name		varchar2(30),
	Abbreviation	varchar2(2),
	Area		float,
	Population	int,
    Constraint State_PK primary key (Abbreviation) deferrable,
    Constraint state_UQ_Name UNIQUE (Name) initially immediate deferrable
);

create table COVERAGE (
    Forest_No	varchar2(10),
    State	varchar2(2),
    Percentage	float,
    Area	float,
    Constraint coverage_PK primary key (Forest_No, State) deferrable,
    Constraint coverage_FK1 foreign key (Forest_No) references FOREST( Forest_No ) initially deferred deferrable,
    Constraint coverage_FK2 foreign key ( State ) references State( Abbreviation ) initially deferred deferrable
);

create table ROAD (
    Road_No		varchar2(10),
    Name		varchar2(30),
    Length		float,
    Constraint road_PK primary key (Road_No) deferrable
);

create table INTERSECTION (
    Forest_No	varchar2(10),
    Road_No	varchar2(10),
    Constraint intersection_PK  primary key (Forest_No, Road_No) deferrable,
    Constraint intersection_FK1 foreign key (Forest_No) references FOREST(Forest_No) initially deferred deferrable,
    Constraint intersection_FK2 foreign key (Road_No) references ROAD(Road_No) initially deferred deferrable
);

create table WORKER (
    SSN			varchar2(9),
    Name		varchar2(30),
    Age			int,
    Rank		int,
    Constraint worker_PK primary key (SSN) deferrable
);

create table SENSOR (
    Sensor_Id	int,
    X		float,
    Y		float,
    Last_Charged date,
    Energy int not null,
    Maintainer varchar2(9) default null,
    Constraint sensor_PK primary key (Sensor_Id) deferrable,
    Constraint sensor_FK foreign key (Maintainer) references WORKER(SSN) initially deferred deferrable,
    Constraint sensor_UQ_coordinate UNIQUE(X,Y) initially immediate deferrable
);

create table REPORT (
    Sensor_Id	int,
    Temperature	float,
    Report_Time	date,
    Constraint report_PK primary key (Sensor_Id, Report_Time) deferrable,
    Constraint report_FK foreign key (Sensor_Id) references SENSOR(Sensor_Id) initially deferred deferrable
);
--(2)
--(a)
alter table sensor add constraint ck_energy check (energy >= 0 and energy <= 10);
--(b)
alter table forest add constraint ck_acid_level check (acid_level >= 0 and acid_level <= 1);
--(c)
alter table forest add constraint ck_mbr check (mbr_xmin < mbr_xmax and mbr_ymin < mbr_ymax);
--(d)
alter table coverage add constraint ck_perc check (percentage >= 0 and percentage <= 1);
-- Populate tables
set transaction read write;

INSERT INTO FOREST VALUES( '1', 'Allegheny National Forest', 40000.0, 0.3, 134.0, 550.0, 233.0, 598.0);
INSERT INTO FOREST VALUES( '2', 'Pennsylvania Forest', 10000.0, 0.75, 21.0, 100.0, 35.0, 78.0);
INSERT INTO FOREST VALUES( '3', 'Stone Valley', 15000.0, 0.4, 22.0, 78.0, 12.0, 20.0);
INSERT INTO FOREST VALUES( '4', 'Garrett State Forest', 19000.0, 0.8, 112.0, 138.0, 172.0, 190.0);
INSERT INTO FOREST VALUES( '5', 'Potomac State Forest', 9000.0, 0.9, 75.0, 190.0, 119.0, 127.0);

INSERT INTO STATE VALUES( 'Pennsylvania', 'PA', 50000.0, 1400000 );
INSERT INTO STATE VALUES( 'Ohio', 'OH', 45000.0, 1200000 );
INSERT INTO STATE VALUES( 'Virginia', 'VA', 35000.0, 1000000 );
INSERT INTO STATE VALUES( 'New York', 'NY', 55000.0, 1100000 );
INSERT INTO STATE VALUES( 'Maryland', 'MD', 59000.0, 1700000 );
INSERT INTO STATE VALUES( 'New Jersey', 'NJ', 39000.0, 1900000 );

INSERT INTO COVERAGE VALUES( 1, 'PA', 0.4, 16000.0 );
INSERT INTO COVERAGE VALUES( 1, 'OH', 0.6, 24000.0);
INSERT INTO COVERAGE VALUES( 2, 'PA', 1, 10000.0 );
INSERT INTO COVERAGE VALUES( 3, 'PA', 0.3, 4500.0);
INSERT INTO COVERAGE VALUES( 3, 'VA', 0.6, 9000.0 );
INSERT INTO COVERAGE VALUES( 3, 'OH', 0.1, 1500.0 );
INSERT INTO COVERAGE VALUES( 4, 'MD', 1, 19000.0);
INSERT INTO COVERAGE VALUES( 5, 'MD', 1, 9000.0);

INSERT INTO ROAD VALUES( 1, 'FORBES', 500.0 );
INSERT INTO ROAD VALUES( 2, 'BIGELOW', 300.0 );
INSERT INTO ROAD VALUES( 3, 'BAYARD', 100.0 );

INSERT INTO INTERSECTION VALUES ( '1', '1' );
INSERT INTO INTERSECTION VALUES ( '1', '2' );
INSERT INTO INTERSECTION VALUES ( '2', '1' );
INSERT INTO INTERSECTION VALUES ( '2', '2' );
INSERT INTO INTERSECTION VALUES ( '3', '3' );
INSERT INTO INTERSECTION VALUES ( '4', '2' );
INSERT INTO INTERSECTION VALUES ( '4', '3' );
INSERT INTO INTERSECTION VALUES ( '5', '1' );
INSERT INTO INTERSECTION VALUES ( '5', '3' );

INSERT INTO WORKER VALUES( '123456789', 'John', 22, 3 );
INSERT INTO WORKER VALUES( '121212121', 'Jason', 30, 5 );
INSERT INTO WORKER VALUES( '222222222', 'Mike', 25, 4 );
INSERT INTO WORKER VALUES( '777777777', 'Mary', 27, 7 );

INSERT INTO SENSOR (Sensor_Id, X, Y, Last_Charged, Energy, Maintainer) VALUES( 1, 150.0, 300.0, to_date('01-JAN-2017 10:00:00', 'DD-MON-YYYY HH24:MI:SS'), 2, '123456789' );
INSERT INTO SENSOR (Sensor_Id, X, Y, Last_Charged, Energy, Maintainer) VALUES( 2, 200.0, 400.0, to_date('01-JAN-2017 10:00:00', 'DD-MON-YYYY HH24:MI:SS'), 3, '123456789' );
INSERT INTO SENSOR (Sensor_Id, X, Y, Last_Charged, Energy, Maintainer) VALUES( 3, 50.0, 50.0, to_date('01-JAN-2017 10:00:00', 'DD-MON-YYYY HH24:MI:SS'), 3, '121212121' );
INSERT INTO SENSOR (Sensor_Id, X, Y, Last_Charged, Energy, Maintainer) VALUES( 4, 50.0, 15.0, to_date('01-JAN-2017 10:00:00', 'DD-MON-YYYY HH24:MI:SS'), 3, null);
INSERT INTO SENSOR (Sensor_Id, X, Y, Last_Charged, Energy, Maintainer) VALUES( 5, 60.0, 60.0, to_date('01-JAN-2017 10:00:00', 'DD-MON-YYYY HH24:MI:SS'), 4, '121212121' );
INSERT INTO SENSOR (Sensor_Id, X, Y, Last_Charged, Energy, Maintainer) VALUES( 6, 50.0, 60.0, to_date('01-JAN-2018 10:00:00', 'DD-MON-YYYY HH24:MI:SS'), 3, null);
INSERT INTO SENSOR (Sensor_Id, X, Y, Last_Charged, Energy, Maintainer) VALUES( 7, 150.0, 310.0, to_date('01-MAR-2017 10:00:00', 'DD-MON-YYYY HH24:MI:SS'), 3, '222222222' );
INSERT INTO SENSOR (Sensor_Id, X, Y, Last_Charged, Energy, Maintainer) VALUES( 8, 60.0, 50.0, to_date('01-MAR-2018 10:00:00', 'DD-MON-YYYY HH24:MI:SS'), 4, '121212121' );
INSERT INTO SENSOR (Sensor_Id, X, Y, Last_Charged, Energy, Maintainer) VALUES( 9, 115.0, 173.0, to_date('10-MAR-2017 10:00:00', 'DD-MON-YYYY HH24:MI:SS'), 3, '777777777' );
INSERT INTO SENSOR (Sensor_Id, X, Y, Last_Charged, Energy, Maintainer) VALUES( 10, 80.0, 120.0, to_date('01-MAR-2018 10:00:00', 'DD-MON-YYYY HH24:MI:SS'), 3, '222222222' );

INSERT INTO REPORT VALUES( 1, 55, to_date('10-JAN-2017 09:00:00', 'DD-MON-YYYY HH24:MI:SS') );
INSERT INTO REPORT VALUES( 1, 57, to_date('10-JAN-2017 14:00:00', 'DD-MON-YYYY HH24:MI:SS') );
INSERT INTO REPORT VALUES( 1, 40, to_date('10-JAN-2017 20:00:00', 'DD-MON-YYYY HH24:MI:SS') );
INSERT INTO REPORT VALUES( 2, 58, to_date('10-JAN-2017 12:30:00', 'DD-MON-YYYY HH24:MI:SS') );
INSERT INTO REPORT VALUES( 2, 59, to_date('10-JAN-2018 12:30:00', 'DD-MON-YYYY HH24:MI:SS') );
INSERT INTO REPORT VALUES( 3, 50, to_date('10-JAN-2017 12:30:00', 'DD-MON-YYYY HH24:MI:SS') );
INSERT INTO REPORT VALUES( 4, 30, to_date('01-JAN-2017 22:00:00', 'DD-MON-YYYY HH24:MI:SS') );
INSERT INTO REPORT VALUES( 5, 33, to_date('02-JAN-2017 22:00:00', 'DD-MON-YYYY HH24:MI:SS') );
INSERT INTO REPORT VALUES( 5, 38, to_date('02-JAN-2018 22:00:00', 'DD-MON-YYYY HH24:MI:SS') );
INSERT INTO REPORT VALUES( 6, 39, to_date('10-MAR-2017 12:30:00', 'DD-MON-YYYY HH24:MI:SS') );
INSERT INTO REPORT VALUES( 7, 45, to_date('20-SEP-2017 22:00:00', 'DD-MON-YYYY HH24:MI:SS') );
INSERT INTO REPORT VALUES( 7, 50, to_date('20-FEB-2018 22:00:00', 'DD-MON-YYYY HH24:MI:SS') );
INSERT INTO REPORT VALUES( 8, 57, to_date('02-JAN-2018 22:00:00', 'DD-MON-YYYY HH24:MI:SS') );
INSERT INTO REPORT VALUES( 9, 50, to_date('20-SEP-2017 21:00:00', 'DD-MON-YYYY HH24:MI:SS') );
INSERT INTO REPORT VALUES( 10, 57, to_date('02-MAR-2017 23:00:00', 'DD-MON-YYYY HH24:MI:SS') );

commit;
