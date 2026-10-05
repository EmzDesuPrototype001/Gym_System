-- ============================================================
-- FITTRACK GYM SYSTEM DATABASE SCRIPT
-- Purpose: Database structure, relations, and sample data
-- ============================================================

DROP DATABASE IF EXISTS gym_system;
CREATE DATABASE gym_system;
USE gym_system;

-- ------------------------------------------------------------
-- TABLE 1: tbl_users
-- Purpose: Stores authorized staff and admin login accounts.
-- CHANGE: Login is now by email. 'username' replaced by email,
-- and first_name, last_name, phone, status added for the
-- Accounts page (list, add-new-account modal, status badge).
-- ------------------------------------------------------------
CREATE TABLE tbl_users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    CHECK (role IN ('admin', 'staff')),
    CHECK (status IN ('Active', 'Inactive'))
);

-- ------------------------------------------------------------
-- TABLE 2: tbl_members
-- Purpose: Stores member personal and contact details.
-- Note: emergency_contact uses VARCHAR(20) to prevent 
-- numeric overflow and retain leading zeros for phone numbers.
-- ------------------------------------------------------------
CREATE TABLE tbl_members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    emergency_contact VARCHAR(20) NOT NULL,
    date_of_birth DATE NOT NULL,
    address VARCHAR(255) NOT NULL,
    registration_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    CHECK (status IN ('Active', 'Inactive'))
);

-- ------------------------------------------------------------
-- TABLE 3: tbl_membership_plans
-- Purpose: Stores the membership packages offered by the gym.
-- ------------------------------------------------------------
CREATE TABLE tbl_membership_plans (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(50) NOT NULL UNIQUE,
    duration_months INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    description VARCHAR(255),
    CHECK (duration_months > 0),
    CHECK (price >= 0)
);

-- ------------------------------------------------------------
-- TABLE 4: tbl_services
-- Purpose: Stores individual services/amenities offered by the gym.
-- ------------------------------------------------------------
CREATE TABLE tbl_services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255),
    price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CHECK (price >= 0)
);

-- ------------------------------------------------------------
-- TABLE 5: tbl_memberships
-- Purpose: Stores actual active or historical plan subscriptions for members.
-- ------------------------------------------------------------
CREATE TABLE tbl_memberships (
    membership_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    CHECK (status IN ('Active', 'Inactive', 'Expired')),
    CHECK (end_date >= start_date),
    FOREIGN KEY (member_id) REFERENCES tbl_members(member_id),
    FOREIGN KEY (plan_id) REFERENCES tbl_membership_plans(plan_id)
);

-- ------------------------------------------------------------
-- TABLE 6: tbl_plan_services
-- Purpose: Junction table resolving the M:N relationship 
-- between membership plans and included services.
-- ------------------------------------------------------------
CREATE TABLE tbl_plan_services (
    plan_id INT NOT NULL,
    service_id INT NOT NULL,
    PRIMARY KEY (plan_id, service_id),
    FOREIGN KEY (plan_id) REFERENCES tbl_membership_plans(plan_id),
    FOREIGN KEY (service_id) REFERENCES tbl_services(service_id)
);

-- ------------------------------------------------------------
-- TABLE 7: tbl_payments
-- Purpose: Stores payment transaction details connected to memberships.
-- ------------------------------------------------------------
CREATE TABLE tbl_payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    membership_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(30) NOT NULL,
    CHECK (amount > 0),
    CHECK (payment_method IN ('Cash', 'GCash', 'Bank Transfer', 'Card')),
    FOREIGN KEY (membership_id) REFERENCES tbl_memberships(membership_id)
);

-- ------------------------------------------------------------
-- TABLE 8: tbl_attendance
-- Purpose: Stores daily member check-in and check-out logs.
-- ------------------------------------------------------------
CREATE TABLE tbl_attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    check_in DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    check_out DATETIME NULL,
    CHECK (check_out IS NULL OR check_out >= check_in),
    FOREIGN KEY (member_id) REFERENCES tbl_members(member_id)
);


-- ============================================================
-- SAMPLE DATA INSERTIONS
-- ============================================================

-- Purpose: Insert sample user accounts for admin and staff
-- Default password for ALL sample accounts: FitTrack@2026 (bcrypt hashed). Change after first login.
INSERT INTO tbl_users (first_name, last_name, email, phone, password_hash, role, status) VALUES
('Alex','Johnson','admin@fittrack.com','09123456780','$2b$10$vZCWBVKw6OSjzSRA5DLJcOK/5IGX63pMYxvq5r.rx.k6M09cgtW9S','admin','Active'),
('Mark','Villanueva','mark@fittrack.com','09123456781','$2b$10$vZCWBVKw6OSjzSRA5DLJcOK/5IGX63pMYxvq5r.rx.k6M09cgtW9S','staff','Active'),
('Anna','Cruz','anna@fittrack.com','09123456782','$2b$10$vZCWBVKw6OSjzSRA5DLJcOK/5IGX63pMYxvq5r.rx.k6M09cgtW9S','staff','Active'),
('John','Bautista','john@fittrack.com','09123456783','$2b$10$vZCWBVKw6OSjzSRA5DLJcOK/5IGX63pMYxvq5r.rx.k6M09cgtW9S','staff','Active'),
('Maria','Aquino','maria@fittrack.com','09123456784','$2b$10$vZCWBVKw6OSjzSRA5DLJcOK/5IGX63pMYxvq5r.rx.k6M09cgtW9S','staff','Active');

-- Purpose: Insert sample member profile records
INSERT INTO tbl_members
(first_name, last_name, email, phone, emergency_contact, date_of_birth, address, registration_date, status)
VALUES
('Juan','Dela Cruz','juan.delacruz@email.com','09171234567','09181234567','2001-05-14','Cabuyao, Laguna','2026-01-10','Active'),
('Maria','Santos','maria.santos@email.com','09182345678','09192345678','2002-08-22','Santa Rosa, Laguna','2026-02-15','Active'),
('Carlos','Reyes','carlos.reyes@email.com','09193456789','09203456789','1999-11-03','Calamba, Laguna','2026-01-10','Active'),
('Ana','Garcia','ana.garcia@email.com','09204567890','09214567890','2000-02-18','Biñan, Laguna','2026-04-05','Active'),
('Mark','Lopez','mark.lopez@email.com','09215678901','09225678901','1998-07-27','Cabuyao, Laguna','2026-05-12','Active'),
('Sofia','Ramos','sofia.ramos@email.com','09226789012','09236789012','2003-09-10','Santa Rosa, Laguna','2026-06-20','Active'),
('Daniel','Mendoza','daniel.mendoza@email.com','09237890123','09247890123','1997-12-30','Calamba, Laguna','2026-05-28','Active'),
('Lea','Navarro','lea.navarro@email.com','09248901234','09258901234','2001-03-25','Biñan, Laguna','2025-09-28','Active');

-- Purpose: Insert gym membership plans (Student plan removed)
INSERT INTO tbl_membership_plans
(plan_name, duration_months, price, description)
VALUES
('Basic',1,800.00,'Basic gym access.'),
('Standard',3,2100.00,'Gym access with additional member benefits.'),
('Premium',6,3600.00,'Gym access with premium services.'),
('Annual',12,6000.00,'Full-year gym membership.');

-- Purpose: Insert standalone services offered by the gym
INSERT INTO tbl_services (service_name, description, price) VALUES
('Boxing equipment','Access to standard gym equipment.', 100.00),
('Locker','Use of an assigned gym locker.',150.00),
('Sauna','Access to the gym sauna.',200.00);

-- Purpose: Insert active and expired member subscriptions
-- Note: Member 6 reassigned from deleted plan 5 to plan 1 (Basic)
INSERT INTO tbl_memberships
(member_id, plan_id, start_date, end_date, status)
VALUES
(1,3,'2026-04-01','2026-10-01','Expired'),
(2,2,'2026-08-01','2026-11-01','Active'),
(3,4,'2026-01-15','2027-01-15','Active'),
(4,1,'2026-09-01','2026-10-01','Expired'),
(5,3,'2026-07-01','2027-01-01','Active'),
(6,1,'2026-09-15','2026-10-15','Active'),
(7,2,'2026-06-01','2026-09-01','Expired'),
(8,4,'2025-10-01','2026-09-30','Expired');

-- Purpose: Map services to their respective membership plans
INSERT INTO tbl_plan_services (plan_id, service_id) VALUES
(1,1),
(2,1),(2,2),
(3,1),(3,2),(3,3),
(4,1),(4,2),(4,3);

-- Purpose: Insert payment transaction logs
-- Note: Payment for membership 6 updated to 800.00 to match Basic plan
INSERT INTO tbl_payments
(membership_id, amount, payment_date, payment_method)
VALUES
(1,3600.00,'2026-04-01 09:15:00','GCash'),
(2,2100.00,'2026-08-01 10:30:00','Cash'),
(3,6000.00,'2026-01-15 08:45:00','Bank Transfer'),
(4,800.00,'2026-09-01 11:20:00','Card'),
(5,3600.00,'2026-07-01 14:10:00','GCash'),
(6,800.00,'2026-09-15 09:00:00','Cash'),
(7,2100.00,'2026-06-01 13:35:00','GCash'),
(8,6000.00,'2025-10-01 10:00:00','Bank Transfer');

-- Purpose: Insert attendance check-in and check-out logs
INSERT INTO tbl_attendance (member_id, check_in, check_out) VALUES
(1,'2026-09-01 08:00:00','2026-09-01 10:00:00'),
(2,'2026-09-02 09:15:00','2026-09-02 11:00:00'),
(3,'2026-09-03 07:30:00','2026-09-03 09:20:00'),
(4,'2026-09-04 17:00:00','2026-09-04 18:45:00'),
(5,'2026-09-05 16:20:00','2026-09-05 18:10:00'),
(6,'2026-09-20 10:00:00','2026-09-20 11:30:00'),
(7,'2026-08-20 15:00:00','2026-08-20 16:40:00'),
(8,'2026-09-08 08:30:00','2026-09-08 10:15:00'),
(2,'2026-09-10 09:00:00','2026-09-10 10:45:00'),
(3,'2026-09-11 07:45:00','2026-09-11 09:30:00');


-- ============================================================
-- SAMPLE REPORT / SEARCH QUERIES
-- ============================================================

-- Purpose: Search member records matching name, email, or phone number
SELECT * FROM tbl_members
WHERE first_name LIKE '%Juan%'
   OR last_name LIKE '%Juan%'
   OR email LIKE '%Juan%'
   OR phone LIKE '%Juan%';

-- Purpose: Report listing member subscriptions sorted by expiration date
SELECT m.member_id,
       m.first_name, m.last_name,
       p.plan_name, ms.start_date, ms.end_date, ms.status
FROM tbl_memberships ms
JOIN tbl_members m ON ms.member_id = m.member_id
JOIN tbl_membership_plans p ON ms.plan_id = p.plan_id
ORDER BY ms.end_date;

-- Purpose: Report displaying full payment history with member and plan details
SELECT pay.payment_id,
       m.first_name, m.last_name,
       p.plan_name, pay.amount, pay.payment_date, pay.payment_method
FROM tbl_payments pay
JOIN tbl_memberships ms ON pay.membership_id = ms.membership_id
JOIN tbl_members m ON ms.member_id = m.member_id
JOIN tbl_membership_plans p ON ms.plan_id = p.plan_id
ORDER BY pay.payment_date DESC;

-- Purpose: Report showing member attendance check-in/out logs sorted by newest check-ins
SELECT a.attendance_id,
       m.first_name, m.last_name,
       a.check_in, a.check_out
FROM tbl_attendance a
JOIN tbl_members m ON a.member_id = m.member_id
ORDER BY a.check_in DESC;

-- Purpose: Report mapping membership plans to their included services
SELECT p.plan_name, s.service_name,
       s.price AS standalone_service_price
FROM tbl_plan_services ps
JOIN tbl_membership_plans p ON ps.plan_id = p.plan_id
JOIN tbl_services s ON ps.service_id = s.service_id
ORDER BY p.plan_id, s.service_id;