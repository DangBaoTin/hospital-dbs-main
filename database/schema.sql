DROP database `hospitaldbs`;
CREATE SCHEMA `hospitaldbs`;
USE hospitaldbs;
CREATE TABLE `employee` (
  `EmployeeID` CHAR(9) NOT NULL,
  `DCode` INT UNSIGNED NOT NULL,
  `DegreeYear` INT UNSIGNED NOT NULL,
  `DegreeName` VARCHAR(45) NOT NULL,
  `First_Name` VARCHAR(30) NOT NULL,
  `Last_Name` VARCHAR(30) NOT NULL,
  `Gender` CHAR(1) NOT NULL,
  `Date_of_Birth` DATE NOT NULL,
  `Address` VARCHAR(60) NOT NULL,
  `Start_date` DATE NOT NULL,
  PRIMARY KEY (`EmployeeID`),
  CONSTRAINT `check_gender` CHECK (Gender IN ('M', 'F'))
);

DELIMITER //

CREATE TRIGGER check_date_of_birth_trigger
BEFORE INSERT ON `employee`
FOR EACH ROW
BEGIN
  IF NEW.Date_of_Birth >= CURDATE() THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Date_of_Birth must be before the current date.';
  END IF;
END//

DELIMITER ;

CREATE TABLE `phonenumber` (
  `EmployeeID` CHAR(9) NOT NULL,
  `Phone_no` VARCHAR(10) NOT NULL,
  PRIMARY KEY (`EmployeeID`, `Phone_no`),
  CONSTRAINT `fk_phone_emp_ID`
    FOREIGN KEY (`EmployeeID`)
    REFERENCES `employee` (`EmployeeID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `check_phone_length` CHECK (LENGTH(`Phone_no`) BETWEEN 9 AND 10)
);

CREATE TABLE `department` (
  `DCode` INT UNSIGNED NOT NULL,
  `title` VARCHAR(45) NOT NULL,
  `dean_ID` CHAR(9) NOT NULL,
  PRIMARY KEY (`DCode`),
  UNIQUE INDEX `dean_ID_UNIQUE` (`dean_ID` ASC) VISIBLE);

ALTER TABLE `employee` 
ADD INDEX `fk_emp_dept_dcode_idx` (`DCode` ASC) VISIBLE;
;
ALTER TABLE `employee` 
ADD CONSTRAINT `fk_emp_dept_dcode`
  FOREIGN KEY (`DCode`)
  REFERENCES `department` (`DCode`)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;

CREATE TABLE `doctor` (
  `DoctorID` CHAR(9) NOT NULL,
  PRIMARY KEY (`DoctorID`),
  CONSTRAINT `fk_doctor_emp_ID`
    FOREIGN KEY (`DoctorID`)
    REFERENCES `employee` (`EmployeeID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE);

ALTER TABLE `department` 
ADD CONSTRAINT `fk_dept_doctor_ID`
  FOREIGN KEY (`dean_ID`)
  REFERENCES `doctor` (`DoctorID`)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;


DELIMITER //

CREATE TRIGGER check_dean_experience_trigger
BEFORE INSERT ON `department`
FOR EACH ROW
BEGIN
  DECLARE dean_degree_year INT;

  SET dean_degree_year = (
    SELECT DegreeYear
    FROM `db_assignment2`.`employee`
    WHERE EmployeeID = NEW.dean_ID
  );

  IF dean_degree_year IS NOT NULL AND YEAR(CURDATE()) - dean_degree_year <= 5 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'The dean assigned to the new department must have (Current Year - degreeYear) > 5.';
  END IF;
END//

DELIMITER ;


CREATE TABLE `nurse` (
  `NurseID` CHAR(9) NOT NULL,
  PRIMARY KEY (`NurseID`),
  CONSTRAINT `fk_nurse_emp_ID`
    FOREIGN KEY (`NurseID`)
    REFERENCES `employee` (`EmployeeID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE TABLE `medication` (
  `Code` CHAR(9) NOT NULL,
  `Name` VARCHAR(45) NOT NULL,
  `Price` INT UNSIGNED NOT NULL,
  `Expired_Date` DATE NOT NULL,
  PRIMARY KEY (`Code`));

CREATE TABLE `effects` (
  `Code` CHAR(9) NOT NULL,
  `Effects` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Code`, `Effects`),
  CONSTRAINT `fk_eff_med_code`
    FOREIGN KEY (`Code`)
    REFERENCES `medication` (`Code`)
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE TABLE `provider` (
  `Number` INT UNSIGNED NOT NULL,
  `Name` VARCHAR(45) NOT NULL,
  `Address` VARCHAR(60) NOT NULL,
  `Phone` VARCHAR(15) NOT NULL,
  PRIMARY KEY (`Number`),
  UNIQUE INDEX `Phone_UNIQUE` (`Phone` ASC) VISIBLE
);

CREATE TABLE `patient` (
  `Code` CHAR(9) NOT NULL,
  `OPCode` CHAR(11) NULL,
  `IPCode` CHAR(11) NULL,
  `Phone_number` VARCHAR(10) NOT NULL,
  `Address` VARCHAR(60) NOT NULL,
  `Date_of_Birth` DATE NOT NULL,
  `Gender` CHAR(1) NOT NULL,
  `First_Name` VARCHAR(30) NOT NULL,
  `Last_Name` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`Code`),
  UNIQUE INDEX `OPCode_UNIQUE` (`OPCode` ASC) VISIBLE,
  UNIQUE INDEX `IPCode_UNIQUE` (`IPCode` ASC) VISIBLE,
  UNIQUE INDEX `Phone_number_UNIQUE` (`Phone_number` ASC) VISIBLE,
  CONSTRAINT `check_phone_length2` CHECK (LENGTH(`Phone_number`) BETWEEN 9 AND 10),
  CONSTRAINT `check_gender2` CHECK (Gender IN ('M', 'F')),
  CONSTRAINT `check_OPCode_prefix` CHECK (OPCode LIKE 'OP%'),
  CONSTRAINT `check_IPCode_prefix` CHECK (IPCode LIKE 'IP%')
);

DELIMITER //

CREATE TRIGGER check_date_of_birth2_trigger
BEFORE INSERT ON `patient`
FOR EACH ROW
BEGIN
  IF NEW.Date_of_Birth >= CURDATE() THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Date_of_Birth must be before the current date.';
  END IF;
END//

DELIMITER ;

CREATE TABLE `import` (
  `PNumber` INT UNSIGNED NOT NULL,
  `MCode` CHAR(9) NOT NULL,
  `Imported_date` DATE NOT NULL,
  `Price` INT UNSIGNED NOT NULL,
  `Quantity` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`PNumber`, `MCode`),
  INDEX `fk_imp_med_code_idx` (`MCode` ASC) VISIBLE,
  CONSTRAINT `fk_imp_prov_number`
    FOREIGN KEY (`PNumber`)
    REFERENCES `provider` (`Number`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_imp_med_code`
    FOREIGN KEY (`MCode`)
    REFERENCES `medication` (`Code`)
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE TABLE `inpatient` (
	`ICode` CHAR(9) NOT NULL,
    PRIMARY KEY (`ICode`),
	CONSTRAINT `fk_inpa_pat_code`
    FOREIGN KEY (`ICode`)
    REFERENCES `patient` (`Code`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE `ip_detail` (
  `ICode` CHAR(9) NOT NULL,
  `IP_visit` INT UNSIGNED NOT NULL,
  `Admission_date` DATE NOT NULL,
  `Diagnosis` VARCHAR(255) NOT NULL,
  `Sickroom` INT UNSIGNED NOT NULL,
  `Discharge_date` DATE NOT NULL,
  `Fee` INT UNSIGNED NOT NULL,
  `Nurse_ID` CHAR(9) NOT NULL,
  PRIMARY KEY (`ICode`, `IP_visit`),
  INDEX `fk_det_nurse_id_idx` (`Nurse_ID` ASC) VISIBLE,
  CONSTRAINT `fk_det_IP_code`
    FOREIGN KEY (`ICode`)
    REFERENCES `inpatient` (`ICode`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_det_nurse_id`
    FOREIGN KEY (`Nurse_ID`)
    REFERENCES `nurse` (`NurseID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `chk_admission_discharge_dates` CHECK (`Admission_date` <= `Discharge_date`));

CREATE TABLE `outpatient` (
  `OCode` CHAR(9) NOT NULL,
  PRIMARY KEY (`OCode`),
  CONSTRAINT `fk_outpa_pat_code`
    FOREIGN KEY (`OCode`)
    REFERENCES `patient` (`Code`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE `op_detail` (
  `OCode` CHAR(9) NOT NULL,
  `OP_visit` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`OCode`, `OP_visit`),
  CONSTRAINT `fk_det_op_code`
    FOREIGN KEY (`OCode`)
    REFERENCES `outpatient` (`OCode`)
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE TABLE `treat_attribute` (
  `ICode` CHAR(9) NOT NULL,
  `IP_visit` INT UNSIGNED NOT NULL,
  `DoctorID` CHAR(9) NOT NULL,
  `Start_datetime` DATETIME NOT NULL,
  `End_datetime` DATETIME NOT NULL,
  `Result` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`ICode`, `IP_visit`, `DoctorID`, `Start_datetime`, `End_datetime`),
  INDEX `fk_treat_doctor_ID_idx` (`DoctorID` ASC) VISIBLE,
  CONSTRAINT `fk_treat_inpa_code`
    FOREIGN KEY (`ICode` , `IP_visit`)
    REFERENCES `ip_detail` (`ICode` , `IP_visit`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_treat_doctor_ID`
    FOREIGN KEY (`DoctorID`)
    REFERENCES `doctor` (`DoctorID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);

ALTER TABLE `treat_attribute`
ADD CONSTRAINT `check_datetime_range` CHECK (`Start_datetime` < `End_datetime`);

CREATE TABLE `examine_detail` (
  `OCode` CHAR(9) NOT NULL,
  `OP_visit` INT UNSIGNED NOT NULL,
  `DoctorID` CHAR(9) NOT NULL,
  `Exam_datetime` DATETIME NOT NULL,
  `Diagnosis` VARCHAR(255) NOT NULL,
  `Next_datetime` DATETIME NULL,
  `Fee` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`OCode`, `OP_visit`, `DoctorID`, `Exam_datetime`),
  INDEX `fk_exam_doctor_ID_idx` (`DoctorID` ASC) VISIBLE,
  CONSTRAINT `fk_exam_detail_info`
    FOREIGN KEY (`OCode` , `OP_visit`)
    REFERENCES `op_detail` (`OCode` , `OP_visit`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_exam_doctor_ID`
    FOREIGN KEY (`DoctorID`)
    REFERENCES `doctor` (`DoctorID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `check_exam_datetime`
    CHECK (`Next_datetime` IS NULL OR `Exam_datetime` < `Next_datetime`)
);

CREATE TABLE `use` (
  `MCode` CHAR(9) NOT NULL,
  `ICode` CHAR(9) NOT NULL,
  `IP_visit` INT UNSIGNED NOT NULL,
  `DoctorID` CHAR(9) NOT NULL,
  `Start_datetime` DATETIME NOT NULL,
  `End_datetime` DATETIME NOT NULL,
  `NumOfMed` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`MCode`, `ICode`, `IP_visit`, `DoctorID`, `Start_datetime`, `End_datetime`),
  INDEX `fk_use_treat_info_idx` (`ICode` ASC, `IP_visit` ASC, `DoctorID` ASC, `Start_datetime` ASC, `End_datetime` ASC) VISIBLE,
  CONSTRAINT `fk_use_med_code`
    FOREIGN KEY (`MCode`)
    REFERENCES `medication` (`Code`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_use_treat_info`
    FOREIGN KEY (`ICode` , `IP_visit` , `DoctorID` , `Start_datetime` , `End_datetime`)
    REFERENCES `treat_attribute` (`ICode` , `IP_visit` , `DoctorID` , `Start_datetime` , `End_datetime`)
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE TABLE `use_for` (
  `MCode` CHAR(9) NOT NULL,
  `OCode` CHAR(9) NOT NULL,
  `OP_visit` INT UNSIGNED NOT NULL,
  `DoctorID` CHAR(9) NOT NULL,
  `Exam_datetime` DATETIME NOT NULL,
  `NumOfMed` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`MCode`, `OCode`, `OP_visit`, `DoctorID`, `Exam_datetime`),
  INDEX `fk_uf_exam_info_idx` (`OCode` ASC, `OP_visit` ASC, `DoctorID` ASC, `Exam_datetime` ASC) VISIBLE,
  CONSTRAINT `fk_uf_med_code`
    FOREIGN KEY (`MCode`)
    REFERENCES `medication` (`Code`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_uf_exam_info`
    FOREIGN KEY (`OCode` , `OP_visit` , `DoctorID` , `Exam_datetime`)
    REFERENCES `examine_detail` (`OCode` , `OP_visit` , `DoctorID` , `Exam_datetime`)
    ON DELETE CASCADE
    ON UPDATE CASCADE);


SET foreign_key_checks = 0;
START transaction;

INSERT INTO `employee` 
  (`EmployeeID`, `DCode`, `DegreeYear`, `DegreeName`, `First_Name`, `Last_Name`, `Gender`, `Date_of_Birth`, `Address`, `Start_date`)
VALUES
  ('E00000001', 1, 2011, 'Psychotherapy', 'A', 'Nguyen Van', 'M', STR_TO_DATE('01/01/1990', '%d/%m/%Y'), '120 Duong 42, Quan 2, TPHCM', STR_TO_DATE('06/01/2019', '%d/%m/%Y')),
  ('E00000002', 2, 2011, 'Neurosurgeon', 'Duyen', 'Tran Thi', 'F', STR_TO_DATE('15/05/1985', '%d/%m/%Y'), '25 Duong 32, Quan 3, TPHCM', STR_TO_DATE('03/05/2018', '%d/%m/%Y')),
  ('E00000003', 3, 2010, 'Orthopedic Nursing', 'Thu', 'Nguyen Le', 'F', STR_TO_DATE('21/08/1980', '%d/%m/%Y'), '12 Duong 46, Quan Tan Binh, TPHCM', STR_TO_DATE('01/02/2020', '%d/%m/%Y')),
  ('E00000004', 2, 2013, 'Perioperative Nursing', 'Xuan', 'Bui Thanh', 'F', STR_TO_DATE('14/09/1986', '%d/%m/%Y'), '26 Duong 32, Quan 7, TPHCM', STR_TO_DATE('02/04/2019', '%d/%m/%Y')),
  ('E00000005', 4, 2012, 'Cardiac Nursing', 'Tuan', 'Nguyen Van', 'M', STR_TO_DATE('19/11/1987', '%d/%m/%Y'), '12 Duong Bui Thi Xuan, Quan 3, TPHCM', STR_TO_DATE('01/10/2016', '%d/%m/%Y')),
  ('E00000006', 3, 2003, 'Orthopedist', 'Sang', 'Nguyen Tri', 'M', STR_TO_DATE('18/06/1962', '%d/%m/%Y'), '23, Duong 54, Quan 1, TPHCM', STR_TO_DATE('02/03/2010', '%d/%m/%Y')),
  ('E00000007', 4, 2012, 'Cardiologist', 'Lan', 'Nguyen Thuy', 'F', STR_TO_DATE('22/05/1982', '%d/%m/%Y'), '145 Duong 32, Quan 3, TPHCM', STR_TO_DATE('03/05/2020', '%d/%m/%Y')),
  ('E00000008', 1, 2014, 'Psychiatric-Mental Health Nursing', 'Lien', 'Tran My', 'F', STR_TO_DATE('05/11/1978', '%d/%m/%Y'), '123 Duong Tan Quy, Quan Binh Tan, TPHCM', STR_TO_DATE('02/10/2019', '%d/%m/%Y'));
SET foreign_key_checks = 1;


INSERT INTO `phonenumber` (`EmployeeID`, `Phone_no`)
VALUES
  ('E00000001', '0123456789'),
  ('E00000001', '123452234'),
  ('E00000002', '3341425354'),
  ('E00000002', '263173847'),
  ('E00000003', '1274632643'),
  ('E00000004', '3243253984'),
  ('E00000005', '7235610411'),
  ('E00000006', '1415359457'),
  ('E00000006', '423485732'),
  ('E00000007', '3526515351'),
  ('E00000008', '7592561095');
  

INSERT INTO `doctor` (`DoctorID`)
VALUES
  ('E00000001'), ('E00000002'), ('E00000006'), ('E00000007');


INSERT INTO `nurse` (`NurseID`)
VALUES
  ('E00000003'), ('E00000004'), ('E00000005'), ('E00000008');


INSERT INTO `department` (`DCode`, `title`, `dean_ID`)
VALUES
  (1, 'Psychology ', 'E00000001'), 
  (2, 'Surgery', 'E00000002'),
  (3, 'Orthopedic', 'E00000006'), 
  (4, 'Cardiology', 'E00000007');
  

INSERT INTO `medication` (`Code`, `Name`, `Price`, `Expired_Date`)
VALUES
	('M00000001', 'Panadol', 2200, STR_TO_DATE('05/08/2025', '%d/%m/%Y')),
    ('M00000002', 'Advil', 3200, STR_TO_DATE('12/06/2026', '%d/%m/%Y')),
    ('M00000003', 'Ambien', 4120, STR_TO_DATE('21/04/2025', '%d/%m/%Y')),
    ('M00000004', 'Prozac', 8460, STR_TO_DATE('10/07/2026', '%d/%m/%Y')),
    ('M00000005', 'Foradil', 7540, STR_TO_DATE('11/03/2026', '%d/%m/%Y')),
    ('M00000006', 'Advil', 3300, STR_TO_DATE('23/11/2027', '%d/%m/%Y')),
	('M00000007', 'Prinivil', 6470, STR_TO_DATE('24/12/2025', '%d/%m/%Y')),
    ('M00000008', 'Prozac', 8460, STR_TO_DATE('17/08/2027', '%d/%m/%Y'));


INSERT INTO `effects` (`Code`, `Effects`)
VALUES
	('M00000001', 'Fever Reducers'),
    ('M00000002', 'Pain Relievers'),
    ('M00000003', 'Sleep Medications'),
    ('M00000004', 'Antidepressants'),
    ('M00000005', 'Respiratory Medications'),
    ('M00000006', 'Pain Relievers'),
	('M00000007', 'Blood Pressure Medications'),
    ('M00000008', 'Antidepressants');
    

INSERT INTO `provider` (`Number`, `Name`, `Address`, `Phone`)
VALUES
	(1, 'GlaxoSmithKline', 'Dungarvan, County Waterford, Ireland', '3535822500'),
    (2, 'Pfizer Vietnam', '31 Duong Le Duan, Quan 1, TPHCM', '0776646724'),
    (3, 'Sanofi-Synthelabo Vietnam', '10 Ham Nghi, Ben Nghe, Quan 1, TPHCM', '02838331822'),
    (4, 'Eli Lilly and Company', 'Indianapolis, Indiana, United States', '1234567892'),
    (5, 'Novartis', 'Basel, Switzerland', '3210314401'),
	(6, 'AstraZeneca', 'Cambridge, United Kingdoms', '3413528541');


INSERT INTO `import` (`PNumber`, `MCode`, `Imported_date`, `Price`, `Quantity`)
VALUES
	(1, 'M00000001', STR_TO_DATE('04/07/2021', '%d/%m/%Y'), 15000000, 8000),
	(2, 'M00000002', STR_TO_DATE('14/05/2021', '%d/%m/%Y'), 20000000, 7000),
    (3, 'M00000003', STR_TO_DATE('16/11/2021', '%d/%m/%Y'), 22000000, 6000),
    (4, 'M00000004', STR_TO_DATE('21/04/2021', '%d/%m/%Y'), 21000000, 3000),
    (5, 'M00000005', STR_TO_DATE('17/06/2021', '%d/%m/%Y'), 20000000, 3000),
    (6, 'M00000007', STR_TO_DATE('08/01/2021', '%d/%m/%Y'), 22000000, 4000),
    (2, 'M00000006', STR_TO_DATE('20/11/2021', '%d/%m/%Y'), 16000000, 6000),
    (4, 'M00000008', STR_TO_DATE('23/06/2021', '%d/%m/%Y'), 30000000, 4000);
    

INSERT INTO `patient` (`Code`, `OPCode`, `IPCode`, `Phone_number`, `Address`, `Date_of_Birth`, `Gender`, `First_Name`, `Last_Name`)
VALUES
	('000000001', 'OP000000001', 'IP000000001', '0837414012', '21 Duong Hoang Dieu, Quan 5, TPHCM', STR_TO_DATE('21/06/1995', '%d/%m/%Y'), 'M', 'Tien', 'Nguyen Van'),
    ('000000002', 'OP000000002', null, '0971740421', '11 Duong Truong Chinh, Quan 1, TPHCM', STR_TO_DATE('12/02/1998', '%d/%m/%Y'), 'M', 'An', 'Tran Manh'),
    ('000000003', null, 'IP000000003', '0914772529', '124 Duong 41, Quan 8, TPHCM', STR_TO_DATE('04/09/2001', '%d/%m/%Y'), 'F', 'Thu', 'Tran Thien'),
    ('000000004', 'OP000000004', 'IP000000004', '0941476532', '145 Duong Nguyen Van Troi, Quan 10, TPHCM', STR_TO_DATE('12/02/1991', '%d/%m/%Y'), 'M', 'Van', 'Nguyen Nhan'),
    ('000000005', 'OP000000005', null, '0912421445', '46 Duong Dien Bien Phu, Quan 1, TPHCM', STR_TO_DATE('15/09/2002', '%d/%m/%Y'), 'F', 'Duong', 'Tran Le Huong'),
    ('000000006', 'OP000000006', 'IP000000006', '071453523', '124 Duong Hoang Dieu, Quan 5, TPHCM', STR_TO_DATE('25/03/1980', '%d/%m/%Y'), 'M', 'Sang', 'Le Van'),
    ('000000007', 'OP000000007', null, '0971646129', '14 Duong 43, Quan Go Vap, TPHCM', STR_TO_DATE('15/06/1998', '%d/%m/%Y'), 'F', 'Van', 'Le Thuy'),
    ('000000008', null, 'IP000000008', '0794415925', '125 Duong Ton That Thuyet, Quan 3, TPHCM', STR_TO_DATE('12/04/1992', '%d/%m/%Y'), 'F', 'Thuy', 'Mai Thu');

    
INSERT INTO `inpatient` (`ICode`)
VALUES 
	('000000001'), ('000000003'), ('000000004'), ('000000006'), ('000000008');
    
    
INSERT INTO `ip_detail` (`ICode`, `IP_visit`, `Admission_date`, `Diagnosis`, `Sickroom`, `Discharge_date`, `Fee`, `Nurse_ID`)
VALUES
	('000000001', 1, STR_TO_DATE('14/08/2022', '%d/%m/%Y'), 'Mental breakdown', 1, STR_TO_DATE('18/08/2022', '%d/%m/%Y'), 2000000, 'E00000008'),
    ('000000001', 2, STR_TO_DATE('12/05/2023', '%d/%m/%Y'), 'Heart attack', 2, STR_TO_DATE('12/06/2023', '%d/%m/%Y'), 4300000, 'E00000005'),
	('000000003', 1, STR_TO_DATE('23/05/2020', '%d/%m/%Y'), 'Appendix surgery', 3, STR_TO_DATE('05/06/2023', '%d/%m/%Y'), 2250000, 'E00000004'),
    ('000000004', 1, STR_TO_DATE('07/06/2023', '%d/%m/%Y'), 'Arm bone break', 5, STR_TO_DATE('21/06/2023', '%d/%m/%Y'), 1000000, 'E00000003'),
    ('000000006', 1, STR_TO_DATE('11/10/2023', '%d/%m/%Y'), 'Heart pump disorder', 4, STR_TO_DATE('11/11/2023', '%d/%m/%Y'), 2340000, 'E00000005'),
    ('000000008', 1, STR_TO_DATE('06/07/2023', '%d/%m/%Y'), 'Leg bone break', 5, STR_TO_DATE('06/08/2023', '%d/%m/%Y'), 1200000, 'E00000003');
    
    
INSERT INTO `treat_attribute` (`ICode`, `IP_visit`, `DoctorID`, `Start_datetime`, `End_datetime`, `Result`)
VALUES
	('000000001', 1, 'E00000001', STR_TO_DATE('15/08/2023 08:30:45', '%d/%m/%Y %H:%i:%s'), STR_TO_DATE('18/08/2023 12:30:45', '%d/%m/%Y %H:%i:%s'), 'Mental OK'),
    ('000000001', 2, 'E00000002', STR_TO_DATE('12/05/2023 08:30:45', '%d/%m/%Y %H:%i:%s'), STR_TO_DATE('14/05/2023 12:30:45', '%d/%m/%Y %H:%i:%s'), 'Surgery successful'),
    ('000000001', 2, 'E00000007', STR_TO_DATE('14/05/2023 12:30:45', '%d/%m/%Y %H:%i:%s'), STR_TO_DATE('12/06/2023 12:30:45', '%d/%m/%Y %H:%i:%s'), 'Normal heart'),
	('000000003', 1, 'E00000002', STR_TO_DATE('23/05/2023 01:24:42', '%d/%m/%Y %H:%i:%s'), STR_TO_DATE('03/06/2023 11:26:21', '%d/%m/%Y %H:%i:%s'), 'Surgery successful'),
    ('000000004', 1, 'E00000006', STR_TO_DATE('07/06/2023 18:06:24', '%d/%m/%Y %H:%i:%s'), STR_TO_DATE('16/06/2023 14:04:53', '%d/%m/%Y %H:%i:%s'), 'Bone position fixed'),
    ('000000006', 1, 'E00000007', STR_TO_DATE('11/10/2023 01:23:13', '%d/%m/%Y %H:%i:%s'), STR_TO_DATE('11/11/2023 12:06:21', '%d/%m/%Y %H:%i:%s'), 'Heart rate normal'),
    ('000000008', 1, 'E00000006', STR_TO_DATE('06/07/2023 10:13:24', '%d/%m/%Y %H:%i:%s'), STR_TO_DATE('01/08/2023 12:12:12', '%d/%m/%Y %H:%i:%s'), 'Bone position fixed');
    
    
INSERT INTO `use` (`MCode`, `ICode`, `IP_visit`, `DoctorID`, `Start_datetime`, `End_datetime`, `NumOfMed`)
VALUES
	('M00000004', '000000001', 1, 'E00000001', STR_TO_DATE('15/08/2023 08:30:45', '%d/%m/%Y %H:%i:%s'), STR_TO_DATE('18/08/2023 12:30:45', '%d/%m/%Y %H:%i:%s'), 6),
    ('M00000002', '000000001', 2, 'E00000002', STR_TO_DATE('12/05/2023 08:30:45', '%d/%m/%Y %H:%i:%s'), STR_TO_DATE('14/05/2023 12:30:45', '%d/%m/%Y %H:%i:%s'), 6),
    ('M00000007', '000000001', 2, 'E00000007', STR_TO_DATE('14/05/2023 12:30:45', '%d/%m/%Y %H:%i:%s'), STR_TO_DATE('12/06/2023 12:30:45', '%d/%m/%Y %H:%i:%s'), 80),
    ('M00000002', '000000003', 1, 'E00000002', STR_TO_DATE('23/05/2023 01:24:42', '%d/%m/%Y %H:%i:%s'), STR_TO_DATE('03/06/2023 11:26:21', '%d/%m/%Y %H:%i:%s'), 30),
    ('M00000003', '000000003', 1, 'E00000002', STR_TO_DATE('23/05/2023 01:24:42', '%d/%m/%Y %H:%i:%s'), STR_TO_DATE('03/06/2023 11:26:21', '%d/%m/%Y %H:%i:%s'), 30),
    ('M00000005', '000000004', 1, 'E00000006', STR_TO_DATE('07/06/2023 18:06:24', '%d/%m/%Y %H:%i:%s'), STR_TO_DATE('16/06/2023 14:04:53', '%d/%m/%Y %H:%i:%s'), 27),
    ('M00000007', '000000006', 1, 'E00000007', STR_TO_DATE('11/10/2023 01:23:13', '%d/%m/%Y %H:%i:%s'), STR_TO_DATE('11/11/2023 12:06:21', '%d/%m/%Y %H:%i:%s'), 60),
    ('M00000005', '000000008', 1, 'E00000006', STR_TO_DATE('06/07/2023 10:13:24', '%d/%m/%Y %H:%i:%s'), STR_TO_DATE('01/08/2023 12:12:12', '%d/%m/%Y %H:%i:%s'), 40);


INSERT INTO `outpatient` (`OCode`)
VALUES
	('000000001'), ('000000002'), ('000000004'), ('000000005'), ('000000006'), ('000000007');
    
    
INSERT INTO `op_detail` (`OCode`, `OP_visit`)
VALUES	
	('000000001', 1), 
    ('000000001', 2),
    ('000000002', 1),
    ('000000004', 1),
    ('000000004', 2),
    ('000000005', 1),
    ('000000006', 1),
    ('000000006', 2),
    ('000000007', 1);


INSERT INTO `examine_detail` (`OCode`, `OP_visit`, `DoctorID`, `Exam_datetime`, `Diagnosis`, `Next_datetime`, `Fee`)
VALUES
	('000000001', 1, 'E00000001', STR_TO_DATE('12/02/2023 07:30:42', '%d/%m/%Y %H:%i:%s'), 'Memory lost', STR_TO_DATE('12/03/2023 07:30:42', '%d/%m/%Y %H:%i:%s'), 400000),
    ('000000001', 2, 'E00000001', STR_TO_DATE('12/03/2023 07:45:42', '%d/%m/%Y %H:%i:%s'), 'Memory recovered', null, 150000),
	('000000002', 1, 'E00000001', STR_TO_DATE('03/04/2023 08:30:20', '%d/%m/%Y %H:%i:%s'), 'Small problem with mental health', null, 200000),
    ('000000004', 1, 'E00000006', STR_TO_DATE('02/05/2023 09:00:20', '%d/%m/%Y %H:%i:%s'), 'Small wrist injury', STR_TO_DATE('02/06/2023 09:00:00', '%d/%m/%Y %H:%i:%s'), 200000),
    ('000000004', 2, 'E00000006', STR_TO_DATE('02/06/2023 09:10:00', '%d/%m/%Y %H:%i:%s'), 'Wrist recovered', null, 150000),
    ('000000005', 1, 'E00000001', STR_TO_DATE('23/09/2023 10:30:20', '%d/%m/%Y %H:%i:%s'), 'Normal mental health', null, 150000),
    ('000000006', 1, 'E00000002', STR_TO_DATE('21/10/2023 09:20:31', '%d/%m/%Y %H:%i:%s'), 'Small brain damage', STR_TO_DATE('07/11/2023 10:00:00', '%d/%m/%Y %H:%i:%s'), 200000),
    ('000000006', 2, 'E00000002', STR_TO_DATE('07/11/2023 10:05:23', '%d/%m/%Y %H:%i:%s'), 'Brain recovered', null, 150000),
    ('000000007', 1, 'E00000007', STR_TO_DATE('12/11/2023 07:10:24', '%d/%m/%Y %H:%i:%s'), 'Normal heart pressure', null, 100000);


INSERT INTO `use_for` (`MCode`, `OCode`, `OP_visit`, `DoctorID`, `Exam_datetime`, `NumOfMed`)
VALUES
	('M00000004', '000000001', 1, 'E00000001', STR_TO_DATE('12/02/2023 07:30:42', '%d/%m/%Y %H:%i:%s'), 60),
	('M00000008', '000000002', 1, 'E00000001', STR_TO_DATE('03/04/2023 08:30:20', '%d/%m/%Y %H:%i:%s'), 30),
    ('M00000005', '000000004', 1, 'E00000006', STR_TO_DATE('02/05/2023 09:00:20', '%d/%m/%Y %H:%i:%s'), 60),
('M00000001', '000000004', 1, 'E00000006', STR_TO_DATE('02/05/2023 09:00:20', '%d/%m/%Y %H:%i:%s'), 30),
    ('M00000005', '000000006', 1, 'E00000002', STR_TO_DATE('21/10/2023 09:20:31', '%d/%m/%Y %H:%i:%s'), 60);

COMMIT;


