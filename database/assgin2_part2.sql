/*Increase Inpatient Fee to 10% for all the current inpatients who are admitted to
hospital from 01/09/2020. (0.5 mark)*/
SET SQL_SAFE_UPDATES = 0;

UPDATE ip_detail 
SET Fee = Fee * 1.1 
WHERE Admission_date >= '2020-09-01 00:00:00';

SET SQL_SAFE_UPDATES = 1;



/*Select all the patients (outpatient & inpatient) of the doctor named ‘Nguyen Van
A’. (0.5 mark)*/

SELECT DISTINCT ip_detail.ICode
FROM ip_detail JOIN treat_attribute ON ip_detail.ICode = treat_attribute.ICode 
				JOIN doctor ON treat_attribute.DoctorID = doctor.DoctorID
				JOIN employee ON doctor.DoctorID = EmployeeID
WHERE First_Name = 'A' AND Last_Name = 'Nguyen Van'
UNION
SELECT DISTINCT op_detail.OCode
FROM op_detail JOIN examine_detail ON op_detail.OCode = examine_detail.OCode 
				JOIN doctor ON examine_detail.DoctorID = doctor.DoctorID
				JOIN employee ON doctor.DoctorID = EmployeeID
WHERE First_Name = 'A' AND Last_Name = 'Nguyen Van';


/*Write a function to calculate the total medication price a patient has to pay for
each treatment or examination (1 mark).
Input: Patient ID
Output: A list of payment of each treatment or examination*/

DROP PROCEDURE IF EXISTS med_price;
Delimiter //
CREATE PROCEDURE med_price(id char(9))
	BEGIN
	SELECT `use`.IP_visit, NULL as OP_visit, SUM(price*NumOfMed) as med_price
	FROM medication JOIN `use` ON `use`.MCode = medication.`Code`
	WHERE `use`.ICode = id
    GROUP BY `use`.IP_visit
    UNION
    SELECT NULL as IP_visit, use_for.OP_visit , SUM(price*NumOfMed) as med_price
	FROM medication JOIN use_for ON use_for.MCode = medication.`Code`
	WHERE use_for.OCode = id
    GROUP BY use_for.OP_visit;
	END//
Delimiter ;

-- CALL med_price('000000001');


/*Write a procedure to sort the doctor in increasing number of patients he/she
takes care in a period of time (1 mark).
Input: Start date, End date
Output: A list of sorting doctors.*/


DROP PROCEDURE IF EXISTS sort_doctor;
Delimiter //
CREATE PROCEDURE sort_doctor(IN start_date DATETIME, IN end_date DATETIME)
	BEGIN
	SELECT EmployeeID, First_Name, Last_Name, COUNT(DISTINCT Ptable.`Code`) as number_of_patients
	FROM (	SELECT treat_attribute.DoctorID, patient.`Code`
			FROM treat_attribute JOIN patient ON treat_attribute.ICODE = patient.`Code`
			WHERE Start_datetime >= start_date AND End_datetime <= end_date
            UNION
            SELECT examine_detail.DoctorID, patient.`Code`
			FROM examine_detail JOIN patient ON examine_detail.OCODE = patient.`Code`
			WHERE Exam_datetime >= start_date AND Exam_datetime <= end_date
            ) as Ptable
	JOIN doctor ON Ptable.DoctorID = doctor.DoctorID
	JOIN employee ON doctor.DoctorID = EmployeeID
    GROUP BY EmployeeID, First_Name, Last_Name
	ORDER BY number_of_patients ASC;
	END//
Delimiter ;