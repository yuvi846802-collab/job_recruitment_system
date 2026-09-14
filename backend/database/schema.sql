-- ============================================================================
-- JOB RECRUITMENT MANAGEMENT SYSTEM (JRMS) - DATABASE SCHEMA (DDL)
-- Target RDBMS: MySQL 8.0+
-- Target Normalization: 1NF, 2NF, 3NF
-- ============================================================================

CREATE DATABASE IF NOT EXISTS recruitment_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE recruitment_db;

-- Drop tables in reverse order of foreign key dependency if re-running script
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS interviews;
DROP TABLE IF EXISTS saved_jobs;
DROP TABLE IF EXISTS applications;
DROP TABLE IF EXISTS jobs;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS candidate_skills;
DROP TABLE IF EXISTS skills;
DROP TABLE IF EXISTS experience;
DROP TABLE IF EXISTS education;
DROP TABLE IF EXISTS job_seekers;
DROP TABLE IF EXISTS companies;
DROP TABLE IF EXISTS users;

-- ----------------------------------------------------------------------------
-- 1. USERS TABLE (Core Authentication & Role Management)
-- ----------------------------------------------------------------------------
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('admin', 'recruiter', 'candidate') NOT NULL DEFAULT 'candidate',
  full_name VARCHAR(150) NOT NULL,
  phone VARCHAR(20) DEFAULT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_users_email (email),
  INDEX idx_users_role (role)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 2. COMPANIES TABLE (Managed by Recruiters)
-- ----------------------------------------------------------------------------
CREATE TABLE companies (
  id INT AUTO_INCREMENT PRIMARY KEY,
  recruiter_id INT NOT NULL,
  company_name VARCHAR(200) NOT NULL,
  logo_url VARCHAR(500) DEFAULT NULL,
  description TEXT DEFAULT NULL,
  industry VARCHAR(100) DEFAULT NULL,
  company_size VARCHAR(50) DEFAULT NULL,
  website VARCHAR(255) DEFAULT NULL,
  location VARCHAR(200) DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (recruiter_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_companies_recruiter (recruiter_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 3. JOB_SEEKERS TABLE (Candidate Profiles)
-- ----------------------------------------------------------------------------
CREATE TABLE job_seekers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL UNIQUE,
  location VARCHAR(200) DEFAULT NULL,
  bio TEXT DEFAULT NULL,
  profile_photo VARCHAR(500) DEFAULT NULL,
  resume_url VARCHAR(500) DEFAULT NULL,
  resume_filename VARCHAR(255) DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_job_seekers_user (user_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 4. EDUCATION TABLE (Candidate Education Records)
-- ----------------------------------------------------------------------------
CREATE TABLE education (
  id INT AUTO_INCREMENT PRIMARY KEY,
  seeker_id INT NOT NULL,
  degree VARCHAR(150) NOT NULL,
  institution VARCHAR(200) NOT NULL,
  field_of_study VARCHAR(150) DEFAULT NULL,
  start_year INT DEFAULT NULL,
  end_year INT DEFAULT NULL,
  grade VARCHAR(50) DEFAULT NULL,
  FOREIGN KEY (seeker_id) REFERENCES job_seekers(id) ON DELETE CASCADE,
  INDEX idx_education_seeker (seeker_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 5. EXPERIENCE TABLE (Candidate Work Experience)
-- ----------------------------------------------------------------------------
CREATE TABLE experience (
  id INT AUTO_INCREMENT PRIMARY KEY,
  seeker_id INT NOT NULL,
  job_title VARCHAR(150) NOT NULL,
  company_name VARCHAR(200) NOT NULL,
  location VARCHAR(150) DEFAULT NULL,
  start_date DATE DEFAULT NULL,
  end_date DATE DEFAULT NULL,
  is_current BOOLEAN DEFAULT FALSE,
  description TEXT DEFAULT NULL,
  FOREIGN KEY (seeker_id) REFERENCES job_seekers(id) ON DELETE CASCADE,
  INDEX idx_experience_seeker (seeker_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 6. SKILLS TABLE (Master Skill Taxonomy)
-- ----------------------------------------------------------------------------
CREATE TABLE skills (
  id INT AUTO_INCREMENT PRIMARY KEY,
  skill_name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 7. CANDIDATE_SKILLS TABLE (Junction Table for Candidate <-> Skill)
-- ----------------------------------------------------------------------------
CREATE TABLE candidate_skills (
  seeker_id INT NOT NULL,
  skill_id INT NOT NULL,
  PRIMARY KEY (seeker_id, skill_id),
  FOREIGN KEY (seeker_id) REFERENCES job_seekers(id) ON DELETE CASCADE,
  FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 8. CATEGORIES TABLE (Job Categories)
-- ----------------------------------------------------------------------------
CREATE TABLE categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  icon_name VARCHAR(50) DEFAULT 'work',
  description VARCHAR(255) DEFAULT NULL
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 9. JOBS TABLE (Job Listings Posted by Recruiters)
-- ----------------------------------------------------------------------------
CREATE TABLE jobs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  company_id INT NOT NULL,
  category_id INT NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT NOT NULL,
  responsibilities TEXT DEFAULT NULL,
  requirements TEXT DEFAULT NULL,
  skills_required VARCHAR(500) DEFAULT NULL,
  experience_years INT NOT NULL DEFAULT 0,
  salary_min DECIMAL(10,2) DEFAULT 0.00,
  salary_max DECIMAL(10,2) DEFAULT 0.00,
  job_type ENUM('Full Time', 'Part Time', 'Internship', 'Contract') NOT NULL DEFAULT 'Full Time',
  work_mode ENUM('On-site', 'Remote', 'Hybrid') NOT NULL DEFAULT 'On-site',
  location VARCHAR(200) NOT NULL,
  openings INT NOT NULL DEFAULT 1,
  deadline DATE DEFAULT NULL,
  status ENUM('active', 'closed', 'draft') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,
  INDEX idx_jobs_company (company_id),
  INDEX idx_jobs_category (category_id),
  INDEX idx_jobs_title (title),
  INDEX idx_jobs_location (location),
  INDEX idx_jobs_status (status)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 10. APPLICATIONS TABLE (Job Applications Submitted by Candidates)
-- ----------------------------------------------------------------------------
CREATE TABLE applications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  job_id INT NOT NULL,
  seeker_id INT NOT NULL,
  status ENUM('Applied', 'Under Review', 'Shortlisted', 'Interview Scheduled', 'Selected', 'Rejected') NOT NULL DEFAULT 'Applied',
  cover_letter TEXT DEFAULT NULL,
  applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_job_candidate (job_id, seeker_id),
  FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
  FOREIGN KEY (seeker_id) REFERENCES job_seekers(id) ON DELETE CASCADE,
  INDEX idx_applications_job (job_id),
  INDEX idx_applications_seeker (seeker_id),
  INDEX idx_applications_status (status)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 11. SAVED_JOBS TABLE (Candidate Bookmarks)
-- ----------------------------------------------------------------------------
CREATE TABLE saved_jobs (
  seeker_id INT NOT NULL,
  job_id INT NOT NULL,
  saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (seeker_id, job_id),
  FOREIGN KEY (seeker_id) REFERENCES job_seekers(id) ON DELETE CASCADE,
  FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 12. INTERVIEWS TABLE (Scheduled Interviews for Applications)
-- ----------------------------------------------------------------------------
CREATE TABLE interviews (
  id INT AUTO_INCREMENT PRIMARY KEY,
  application_id INT NOT NULL UNIQUE,
  scheduled_date DATE NOT NULL,
  scheduled_time TIME NOT NULL,
  interview_mode ENUM('Online', 'In-Person', 'Telephonic') NOT NULL DEFAULT 'Online',
  location_or_link VARCHAR(500) NOT NULL,
  interviewer_name VARCHAR(150) NOT NULL,
  notes TEXT DEFAULT NULL,
  status ENUM('Scheduled', 'Rescheduled', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Scheduled',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE CASCADE,
  INDEX idx_interviews_application (application_id),
  INDEX idx_interviews_status (status)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 13. NOTIFICATIONS TABLE (System Notifications for Users)
-- ----------------------------------------------------------------------------
CREATE TABLE notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(200) NOT NULL,
  message TEXT NOT NULL,
  type VARCHAR(50) DEFAULT 'info',
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_notifications_user (user_id),
  INDEX idx_notifications_read (is_read)
) ENGINE=InnoDB;
