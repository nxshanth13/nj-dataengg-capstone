create database nishanthj;

use nishanthj;

CREATE TABLE Patients (
    PatientID INT PRIMARY KEY,
    PatientName VARCHAR(100),
    Gender CHAR(1),
    DOB DATE,
    Phone VARCHAR(15),
    Address VARCHAR(200)
);

INSERT INTO Patients VALUES
(1, 'John Smith', 'M', '1985-06-15', '1234567890', '123 Main St'),
(2, 'Jane Doe', 'F', '1990-09-25', '2345678901', '456 Oak St'),
(3, 'Emily Davis', 'F', '1975-03-12', '3456789012', '789 Pine St'),
(4, 'Michael Brown', 'M', '2000-01-01', '4567890123', '101 Maple St'),
(5, 'Sarah Lee', 'F', '1988-11-30', '5678901234', '202 Cedar St');

CREATE TABLE Doctors (
    DoctorID INT PRIMARY KEY,
    DoctorName VARCHAR(100),
    Specialty VARCHAR(50),
    Phone VARCHAR(15)
);

INSERT INTO Doctors VALUES
(1, 'Dr. Wilson', 'Cardiology', '9876543210'),
(2, 'Dr. Thomas', 'Neurology', '8765432109'),
(3, 'Dr. Green', 'Orthopedics', '7654321098');

CREATE TABLE Appointments (
    AppointmentID INT PRIMARY KEY,
    PatientID INT FOREIGN KEY REFERENCES Patients(PatientID),
    DoctorID INT FOREIGN KEY REFERENCES Doctors(DoctorID),
    AppointmentDate DATE,
    Status VARCHAR(20)
);

INSERT INTO Appointments VALUES
(1, 1, 1, '2023-07-01', 'Completed'),
(2, 2, 2, '2023-07-02', 'Completed'),
(3, 3, 3, '2023-07-03', 'Cancelled'),
(4, 4, 1, '2023-07-04', 'Completed'),
(5, 5, 3, '2023-07-05', 'Scheduled'),
(6, 1, 2, '2023-07-15', 'Completed'),
(7, 2, 3, '2023-07-18', 'Completed'),
(8, 3, 1, '2023-07-22', 'Completed');


CREATE TABLE Treatments (
    TreatmentID INT PRIMARY KEY,
    AppointmentID INT FOREIGN KEY REFERENCES Appointments(AppointmentID),
    Diagnosis VARCHAR(200),
    TreatmentDetails VARCHAR(200),
    Cost DECIMAL(10, 2)
);

INSERT INTO Treatments VALUES
(1, 1, 'Heart Pain', 'ECG, Aspirin, Rest', 2500.00),
(2, 2, 'Migraine', 'MRI, Painkillers', 1800.00),
(3, 4, 'Chest Pain', 'X-ray, Rest', 2000.00),
(4, 6, 'Headache', 'CT Scan, Paracetamol', 1600.00),
(5, 7, 'Back Pain', 'Physiotherapy', 2200.00),
(6, 8, 'Hypertension', 'BP Check, Medication', 1700.00);


CREATE TABLE Medications (
    MedicationID INT PRIMARY KEY,
    TreatmentID INT FOREIGN KEY REFERENCES Treatments(TreatmentID),
    MedicationName VARCHAR(100),
    Dosage VARCHAR(50)
);

INSERT INTO Medications VALUES
(1, 1, 'Aspirin', '100mg'),
(2, 1, 'Atorvastatin', '20mg'),
(3, 2, 'Ibuprofen', '400mg'),
(4, 3, 'Paracetamol', '500mg'),
(5, 4, 'Sumatriptan', '50mg'),
(6, 5, 'Diclofenac', '75mg'),
(7, 6, 'Amlodipine', '5mg');

select * from patients;
select * from doctors;
select * from appointments;
select * from treatments;
select * from medications;

--List all patients with their appointment dates and doctor names.
select p.patientname,d.doctorname,a.appointmentdate from patients as p join appointments as a on p.patientid= a.appointmentid
join doctors as d on d.doctorid=a.doctorid order by p.patientid,a.appointmentdate;


--Find the total number of appointments per doctor.
SELECT d.DoctorName,COUNT(a.AppointmentID) AS TotalAppointments
FROM Doctors d LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID
GROUP BY d.DoctorName;


--Display the list of medications prescribed during treatment ID = 1.
select distinct p.PatientName from Patients p join Appointments a on p.PatientID = a.PatientID
where a.Status = 'Completed';


--Get the list of patients who have appointments marked as 'Completed'.
select p.patientname,p.patientid from patients as p join appointments as a on p.patientid=a.patientid where a.status='Completed';


--Show the names and phone numbers of doctors who specialize in 'Neurology'.
select DoctorName,phone from doctors where Specialty='Neurology';


-- List patients whose total treatment cost is above the average treatment cost of all patients.



-- List doctors who treated patients with diagnoses containing the word 'Pain'.
select distinct d.DoctorID,d.DoctorName,d.Specialty FROM Doctors d join Appointments a ON d.DoctorID = a.DoctorID
join Treatments t ON a.AppointmentID = t.AppointmentID  where t.Diagnosis LIKE '%Pain%';


--Rank patients by total treatment cost (highest to lowest).
select  p.PatientID, p.PatientName,sum(t.Cost) as totcost, RANK() OVER (ORDER BY SUM(t.Cost) DESC) AS TreatmentCostRank from Patients p
join Appointments a on p.PatientID = a.PatientID
join Treatments t on a.AppointmentID = t.AppointmentID
group by p.PatientID, p.PatientName order by TreatmentCostRank;


-- For each doctor, show their appointments ranked by most recent first.
select d.DoctorID, d.DoctorName, a.AppointmentID, a.AppointmentDate,
rank() over (PARTITION BY d.DoctorID order by a.AppointmentDate desc) as AppointmentRank
from Doctors d
join  Appointments a ON d.DoctorID = a.DoctorID
order by d.DoctorID, AppointmentRank;


--Show appointments with extracted month and year of appointment.
select AppointmentID,AppointmentDate, YEAR(AppointmentDate) as a_year,
MONTH(AppointmentDate) as a_month from Appointments;


--List the total cost of treatments done by each doctor.
select d.DoctorID,d.DoctorName,SUM(t.Cost) as tot_cost from  Doctors d
join  Appointments a on d.DoctorID = a.DoctorID
join  Treatments t on a.AppointmentID = t.AppointmentID group by  d.DoctorID, d.DoctorName;


--Display patients who have more than 1 appointment.
select p.PatientID,p.PatientName,count(a.AppointmentID) AS a_count
from Patients p join Appointments a ON p.PatientID = a.PatientID GROUP BY p.PatientID, p.PatientName having count(a.AppointmentID) > 1;


--Find the average treatment cost for each diagnosis.
select Diagnosis, avg(Cost) as avg_cost FROM Treatments group by Diagnosis;


--List patients who have not received any treatments yet.
select p.patientid,p.patientname,a.status from patients as p join appointments as a on p.patientid=a.patientid where a.status!='Completed'; 

--List all patient and doctor pairs with appointments scheduled for July 2023








