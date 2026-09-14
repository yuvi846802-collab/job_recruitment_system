-- ============================================================================
-- JOB RECRUITMENT MANAGEMENT SYSTEM (JRMS)
-- ACADEMIC DBMS DEMONSTRATION QUERIES
-- Showcase for BCA Evaluation: DDL, DML, DQL, DCL, TCL, JOINs, Group By, Having, Subqueries, Views, Indexes & Transactions.
-- ============================================================================

USE recruitment_db;

-- ----------------------------------------------------------------------------
-- 1. DDL DEMONSTRATIONS (Data Definition Language)
-- ----------------------------------------------------------------------------
-- Creating an audit log index to optimize system monitoring
CREATE INDEX idx_applications_composite ON applications(job_id, seeker_id, status);

-- Adding a constraint/column alter example
ALTER TABLE users ADD COLUMN last_login TIMESTAMP NULL DEFAULT NULL AFTER is_active;


-- ----------------------------------------------------------------------------
-- 2. DQL DEMONSTRATIONS (Data Query Language & Relational Operations)
-- ----------------------------------------------------------------------------

-- A. INNER JOIN & LEFT JOIN (Fetching Job Applications with Candidate & Job Details)
SELECT 
    a.id AS application_id,
    u.full_name AS candidate_name,
    u.email AS candidate_email,
    j.title AS job_title,
    c.company_name,
    a.status AS application_status,
    a.applied_at
FROM applications a
INNER JOIN job_seekers js ON a.seeker_id = js.id
INNER JOIN users u ON js.user_id = u.id
INNER JOIN jobs j ON a.job_id = j.id
INNER JOIN companies c ON j.company_id = c.id
ORDER BY a.applied_at DESC;

-- B. MULTI-TABLE JOIN (Candidate Skills Breakdown)
SELECT 
    u.full_name,
    js.location,
    GROUP_CONCAT(s.skill_name SEPARATOR ', ') AS skills_list
FROM job_seekers js
JOIN users u ON js.user_id = u.id
LEFT JOIN candidate_skills cs ON js.id = cs.seeker_id
LEFT JOIN skills s ON cs.skill_id = s.id
GROUP BY js.id, u.full_name, js.location;

-- C. AGGREGATE FUNCTIONS, GROUP BY & HAVING (Applications Per Job Category > 0)
SELECT 
    cat.name AS category_name,
    COUNT(j.id) AS total_jobs_posted,
    AVG(j.salary_max) AS average_max_salary,
    COUNT(a.id) AS total_applications_received
FROM categories cat
LEFT JOIN jobs j ON cat.id = j.category_id
LEFT JOIN applications a ON j.id = a.job_id
GROUP BY cat.id, cat.name
HAVING total_jobs_posted >= 1
ORDER BY total_applications_received DESC;

-- D. SUBQUERIES (Candidates who applied for jobs with salary greater than average)
SELECT 
    u.full_name,
    u.email,
    j.title AS applied_job_title,
    j.salary_max
FROM users u
JOIN job_seekers js ON u.id = js.user_id
JOIN applications a ON js.id = a.seeker_id
JOIN jobs j ON a.job_id = j.id
WHERE j.salary_max > (SELECT AVG(salary_max) FROM jobs);


-- ----------------------------------------------------------------------------
-- 3. SQL VIEWS DEMONSTRATION
-- ----------------------------------------------------------------------------
-- View for Admin & Recruiter Analytics Summary
CREATE OR REPLACE VIEW view_recruitment_analytics AS
SELECT 
    j.id AS job_id,
    j.title AS job_title,
    c.company_name,
    cat.name AS category,
    j.work_mode,
    j.status AS job_status,
    COUNT(DISTINCT a.id) AS total_applicants,
    SUM(CASE WHEN a.status = 'Shortlisted' THEN 1 ELSE 0 END) AS shortlisted_count,
    SUM(CASE WHEN a.status = 'Interview Scheduled' THEN 1 ELSE 0 END) AS interview_count,
    SUM(CASE WHEN a.status = 'Selected' THEN 1 ELSE 0 END) AS selected_count
FROM jobs j
JOIN companies c ON j.company_id = c.id
JOIN categories cat ON j.category_id = cat.id
LEFT JOIN applications a ON j.id = a.job_id
GROUP BY j.id, j.title, c.company_name, cat.name, j.work_mode, j.status;

-- Query the view
SELECT * FROM view_recruitment_analytics;


-- ----------------------------------------------------------------------------
-- 4. TCL DEMONSTRATION (Transaction Control Language - Shortlist & Schedule Interview)
-- ----------------------------------------------------------------------------
START TRANSACTION;

-- Step 1: Update Application Status
UPDATE applications 
SET status = 'Interview Scheduled', updated_at = NOW() 
WHERE id = 1;

-- Step 2: Insert Scheduled Interview Entry
INSERT INTO interviews (application_id, scheduled_date, scheduled_time, interview_mode, location_or_link, interviewer_name, notes, status)
VALUES (1, '2026-09-25', '11:00:00', 'Online', 'https://meet.google.com/jrms-round2', 'Sarah Jenkins', 'Round 2 Technical Interview', 'Scheduled')
ON DUPLICATE KEY UPDATE scheduled_date = '2026-09-25', scheduled_time = '11:00:00';

-- Step 3: Insert Notification for Candidate
INSERT INTO notifications (user_id, title, message, type)
SELECT js.user_id, 'Interview Scheduled', 'Your interview for Senior Flutter Architect has been scheduled for Sep 25, 2026.', 'info'
FROM applications a
JOIN job_seekers js ON a.seeker_id = js.id
WHERE a.id = 1;

COMMIT;

-- ----------------------------------------------------------------------------
-- 5. DML DEMONSTRATIONS (Data Manipulation Language)
-- ----------------------------------------------------------------------------
-- Soft delete / deactivate user
UPDATE users SET is_active = FALSE WHERE id = 9999;
