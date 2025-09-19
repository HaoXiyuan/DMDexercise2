CREATE TABLE medication_stock (
    medication_id   SERIAL PRIMARY KEY,
    medication_name TEXT NOT NULL,
    quantity        INT  NOT NULL CHECK (quantity >= 0)
);

INSERT INTO medication_stock(medication_name, quantity) VALUES
('Aspirin', 200),
('Insulin', 50),
('Lisinopril', 120),
('Metformin', 30),
('Atorvastatin', 90),
('Warfarin', 15),
('Amlodipine', 75);

 -- Q1: List all patients name and ages
SELECT name, age FROM patients;

-- Q2: List all doctors specializing in 'Cardiology'
SELECT * FROM doctors WHERE specialization = 'Cardiology';

-- Q3: Find all patients that are older than 80
SELECT * FROM patients WHERE age > 80;

-- Q4: List all the patients ordered by their age (youngest first)
SELECT * FROM patients ORDER BY age;

-- Q5: Count the number of doctors in each specialization
SELECT specialization, COUNT(*) AS doctor_count
FROM doctors
GROUP BY specialization;

-- Q6: List patients and their doctors' names
SELECT p.name AS patient_name, d.name AS doctor_name
FROM patients p
JOIN doctors d ON p.doctor_id = d.doctor_id;

-- Q7: Show treatments along with patient names and doctor names
SELECT t.treatment_id,
       t.treatment_type,
       t.treatment_time,
       p.name AS patient_name,
       d.name AS doctor_name
FROM treatments t
JOIN patients p ON p.patient_id = t.patient_id
JOIN doctors  d ON d.doctor_id  = p.doctor_id
ORDER BY t.treatment_time;

-- Q8: Count how many patients each doctor supervises
SELECT d.doctor_id,
       d.name,
       COUNT(p.patient_id) AS patients_supervised
FROM doctors d
LEFT JOIN patients p ON p.doctor_id = d.doctor_id
GROUP BY d.doctor_id, d.name
ORDER BY patients_supervised DESC;

-- Q9: List the average age of patients and display it as average_age
SELECT AVG(age) AS average_age FROM patients;

-- Q10: Find the most common treatment type, and display only that
SELECT treatment_type
FROM treatments
GROUP BY treatment_type
ORDER BY COUNT(*) DESC
LIMIT 1;

-- Q11: List patients who are older than the average age of all patients
SELECT * FROM patients
WHERE age > (SELECT AVG(age) FROM patients);

-- Q12: List all the doctors who have more than 5 patients
SELECT d.doctor_id, d.name, COUNT(p.patient_id) AS patient_count
FROM doctors d
JOIN patients p ON d.doctor_id = p.doctor_id
GROUP BY d.doctor_id, d.name
HAVING COUNT(p.patient_id) > 5;

-- Q13: List all the treatments that are provided by nurses that work in the morning shift. List patient name as well.
SELECT t.treatment_id, t.treatment_type, p.name AS patient_name
FROM treatments t
JOIN nurses n ON t.nurse_id = n.nurse_id
JOIN patients p ON t.patient_id = p.patient_id
WHERE n.shift = 'Morning';

-- Q14: Find the latest treatment for each patient
SELECT DISTINCT ON (patient_id)
       patient_id,
       treatment_id,
       treatment_type,
       treatment_time
FROM treatments
ORDER BY patient_id, treatment_time DESC;

-- Q15: List all the doctors and average age of their patients
SELECT d.doctor_id, d.name, AVG(p.age) AS avg_patient_age
FROM doctors d
JOIN patients p ON p.doctor_id = d.doctor_id
GROUP BY d.doctor_id, d.name;

-- Q16: List the names of the doctors who supervise more than 3 patients
SELECT d.name
FROM doctors d
JOIN patients p ON d.doctor_id = p.doctor_id
GROUP BY d.doctor_id, d.name
HAVING COUNT(*) > 3;

-- Q17: List all the patients who have not received any treatments (HINT: Use NOT IN)
SELECT * FROM patients
WHERE patient_id NOT IN (SELECT DISTINCT patient_id FROM treatments);

-- Q18: List all the medicines whose stock (quantity) is less than the average stock
SELECT medication_id, medication_name, quantity
FROM medication_stock
WHERE quantity < (SELECT AVG(quantity) FROM medication_stock);

-- Q19: For each doctor, rank their patients by age
SELECT doctor_id, patient_id, name, age,
       RANK() OVER (PARTITION BY doctor_id ORDER BY age DESC) AS age_rank
FROM patients;

-- Q20: For each specialization, find the doctor with the oldest patient
SELECT specialization, doctor_id, oldest
FROM (
    SELECT d.specialization,
           d.doctor_id,
           MAX(p.age) AS oldest,
           RANK() OVER (PARTITION BY d.specialization ORDER BY MAX(p.age) DESC) AS rnk
    FROM doctors d
    JOIN patients p ON p.doctor_id = d.doctor_id
    GROUP BY d.specialization, d.doctor_id
) t
WHERE rnk = 1;