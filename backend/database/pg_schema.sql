-- ============================================================================
-- JOB RECRUITMENT MANAGEMENT SYSTEM (JRMS) - POSTGRESQL SCHEMA (SUPABASE)
-- Target RDBMS: PostgreSQL 14+ / Supabase
-- Target Normalization: 1NF, 2NF, 3NF
-- ============================================================================

-- Drop existing types and tables if re-running
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS interviews CASCADE;
DROP TABLE IF EXISTS saved_jobs CASCADE;
DROP TABLE IF EXISTS applications CASCADE;
DROP TABLE IF EXISTS jobs CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS candidate_skills CASCADE;
DROP TABLE IF EXISTS skills CASCADE;
DROP TABLE IF EXISTS experience CASCADE;
DROP TABLE IF EXISTS education CASCADE;
DROP TABLE IF EXISTS job_seekers CASCADE;
DROP TABLE IF EXISTS companies CASCADE;
DROP TABLE IF EXISTS users CASCADE;

DROP TYPE IF EXISTS user_role_enum CASCADE;
DROP TYPE IF EXISTS job_type_enum CASCADE;
DROP TYPE IF EXISTS work_mode_enum CASCADE;
DROP TYPE IF EXISTS job_status_enum CASCADE;
DROP TYPE IF EXISTS application_status_enum CASCADE;
DROP TYPE IF EXISTS interview_mode_enum CASCADE;
DROP TYPE IF EXISTS interview_status_enum CASCADE;

-- Enums
CREATE TYPE user_role_enum AS ENUM ('admin', 'recruiter', 'candidate');
CREATE TYPE job_type_enum AS ENUM ('Full Time', 'Part Time', 'Internship', 'Contract');
CREATE TYPE work_mode_enum AS ENUM ('On-site', 'Remote', 'Hybrid');
CREATE TYPE job_status_enum AS ENUM ('active', 'closed', 'draft');
CREATE TYPE application_status_enum AS ENUM ('Applied', 'Under Review', 'Shortlisted', 'Interview Scheduled', 'Selected', 'Rejected');
CREATE TYPE interview_mode_enum AS ENUM ('Online', 'In-Person', 'Telephonic');
CREATE TYPE interview_status_enum AS ENUM ('Scheduled', 'Rescheduled', 'Completed', 'Cancelled');

-- 1. USERS TABLE
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role user_role_enum NOT NULL DEFAULT 'candidate',
  full_name VARCHAR(150) NOT NULL,
  phone VARCHAR(20) DEFAULT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- 2. COMPANIES TABLE
CREATE TABLE companies (
  id SERIAL PRIMARY KEY,
  recruiter_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  company_name VARCHAR(200) NOT NULL,
  logo_url VARCHAR(500) DEFAULT NULL,
  description TEXT DEFAULT NULL,
  industry VARCHAR(100) DEFAULT NULL,
  company_size VARCHAR(50) DEFAULT NULL,
  website VARCHAR(255) DEFAULT NULL,
  location VARCHAR(200) DEFAULT NULL,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_companies_recruiter ON companies(recruiter_id);

-- 3. JOB_SEEKERS TABLE
CREATE TABLE job_seekers (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  location VARCHAR(200) DEFAULT NULL,
  bio TEXT DEFAULT NULL,
  profile_photo VARCHAR(500) DEFAULT NULL,
  resume_url VARCHAR(500) DEFAULT NULL,
  resume_filename VARCHAR(255) DEFAULT NULL,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_job_seekers_user ON job_seekers(user_id);

-- 4. EDUCATION TABLE
CREATE TABLE education (
  id SERIAL PRIMARY KEY,
  seeker_id INT NOT NULL REFERENCES job_seekers(id) ON DELETE CASCADE,
  degree VARCHAR(150) NOT NULL,
  institution VARCHAR(200) NOT NULL,
  field_of_study VARCHAR(150) DEFAULT NULL,
  start_year INT DEFAULT NULL,
  end_year INT DEFAULT NULL,
  grade VARCHAR(50) DEFAULT NULL
);

CREATE INDEX idx_education_seeker ON education(seeker_id);

-- 5. EXPERIENCE TABLE
CREATE TABLE experience (
  id SERIAL PRIMARY KEY,
  seeker_id INT NOT NULL REFERENCES job_seekers(id) ON DELETE CASCADE,
  job_title VARCHAR(150) NOT NULL,
  company_name VARCHAR(200) NOT NULL,
  location VARCHAR(150) DEFAULT NULL,
  start_date DATE DEFAULT NULL,
  end_date DATE DEFAULT NULL,
  is_current BOOLEAN DEFAULT FALSE,
  description TEXT DEFAULT NULL
);

CREATE INDEX idx_experience_seeker ON experience(seeker_id);

-- 6. SKILLS TABLE
CREATE TABLE skills (
  id SERIAL PRIMARY KEY,
  skill_name VARCHAR(100) NOT NULL UNIQUE
);

-- 7. CANDIDATE_SKILLS TABLE
CREATE TABLE candidate_skills (
  seeker_id INT NOT NULL REFERENCES job_seekers(id) ON DELETE CASCADE,
  skill_id INT NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
  PRIMARY KEY (seeker_id, skill_id)
);

-- 8. CATEGORIES TABLE
CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  icon_name VARCHAR(50) DEFAULT 'work',
  description VARCHAR(255) DEFAULT NULL
);

-- 9. JOBS TABLE
CREATE TABLE jobs (
  id SERIAL PRIMARY KEY,
  company_id INT NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  category_id INT NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
  title VARCHAR(200) NOT NULL,
  description TEXT NOT NULL,
  responsibilities TEXT DEFAULT NULL,
  requirements TEXT DEFAULT NULL,
  skills_required VARCHAR(500) DEFAULT NULL,
  experience_years INT NOT NULL DEFAULT 0,
  salary_min DECIMAL(10,2) DEFAULT 0.00,
  salary_max DECIMAL(10,2) DEFAULT 0.00,
  job_type job_type_enum NOT NULL DEFAULT 'Full Time',
  work_mode work_mode_enum NOT NULL DEFAULT 'On-site',
  location VARCHAR(200) NOT NULL,
  openings INT NOT NULL DEFAULT 1,
  deadline DATE DEFAULT NULL,
  status job_status_enum NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_jobs_company ON jobs(company_id);
CREATE INDEX idx_jobs_category ON jobs(category_id);
CREATE INDEX idx_jobs_title ON jobs(title);
CREATE INDEX idx_jobs_location ON jobs(location);
CREATE INDEX idx_jobs_status ON jobs(status);

-- 10. APPLICATIONS TABLE
CREATE TABLE applications (
  id SERIAL PRIMARY KEY,
  job_id INT NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  seeker_id INT NOT NULL REFERENCES job_seekers(id) ON DELETE CASCADE,
  status application_status_enum NOT NULL DEFAULT 'Applied',
  cover_letter TEXT DEFAULT NULL,
  applied_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (job_id, seeker_id)
);

CREATE INDEX idx_applications_job ON applications(job_id);
CREATE INDEX idx_applications_seeker ON applications(seeker_id);
CREATE INDEX idx_applications_status ON applications(status);

-- 11. SAVED_JOBS TABLE
CREATE TABLE saved_jobs (
  seeker_id INT NOT NULL REFERENCES job_seekers(id) ON DELETE CASCADE,
  job_id INT NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  saved_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (seeker_id, job_id)
);

-- 12. INTERVIEWS TABLE
CREATE TABLE interviews (
  id SERIAL PRIMARY KEY,
  application_id INT NOT NULL UNIQUE REFERENCES applications(id) ON DELETE CASCADE,
  scheduled_date DATE NOT NULL,
  scheduled_time TIME NOT NULL,
  interview_mode interview_mode_enum NOT NULL DEFAULT 'Online',
  location_or_link VARCHAR(500) NOT NULL,
  interviewer_name VARCHAR(150) NOT NULL,
  notes TEXT DEFAULT NULL,
  status interview_status_enum NOT NULL DEFAULT 'Scheduled',
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_interviews_application ON interviews(application_id);
CREATE INDEX idx_interviews_status ON interviews(status);

-- 13. NOTIFICATIONS TABLE
CREATE TABLE notifications (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(200) NOT NULL,
  message TEXT NOT NULL,
  type VARCHAR(50) DEFAULT 'info',
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);
