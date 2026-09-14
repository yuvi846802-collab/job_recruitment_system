-- ============================================================================
-- JOB RECRUITMENT MANAGEMENT SYSTEM (JRMS) - POSTGRESQL SEED DATA (SUPABASE)
-- 1 ADMIN | 3 HR ACCOUNTS | 5 USER ACCOUNTS
-- Default Passwords: Admin@JRMS2026, HR@JRMS2026, User@JRMS2026
-- ============================================================================

TRUNCATE notifications, interviews, saved_jobs, applications, jobs, categories, candidate_skills, skills, experience, education, job_seekers, companies, users RESTART IDENTITY CASCADE;

-- 1. USERS (1 Admin + 3 HR + 5 Users = 9 Total Accounts)
INSERT INTO users (id, email, password_hash, role, full_name, phone, is_active) VALUES
-- 1 ADMIN
(1, 'admin@jrms.local', '$2a$10$9LyxTYPk3LUhzjsgpinSYe3kCjeY2NifAg7cw.BcEBlHvTXn6LYq.', 'admin', 'System Administrator', '+91 98765 43210', TRUE),

-- 3 HR ACCOUNTS
(2, 'hr@jrms.local', '$2a$10$.lYxkO0BhgQfqkgIbB9JpencgA7F/rLPjRZeqP9.vN78E9LvLRyze', 'recruiter', 'Demo HR Manager', '+91 98765 43211', TRUE),
(3, 'hr.innovate@innovate.com', '$2a$10$.lYxkO0BhgQfqkgIbB9JpencgA7F/rLPjRZeqP9.vN78E9LvLRyze', 'recruiter', 'Sarah Jenkins (HR Lead)', '+1 (555) 014-9921', TRUE),
(4, 'hr.cloudscale@cloudscale.io', '$2a$10$.lYxkO0BhgQfqkgIbB9JpencgA7F/rLPjRZeqP9.vN78E9LvLRyze', 'recruiter', 'David Miller (Talent Director)', '+1 (555) 017-4820', TRUE),

-- 5 USER ACCOUNTS (CANDIDATES)
(5, 'user@jrms.local', '$2a$10$ttODAff1LAjdcB/yotPhRuLja5gLqVySsqHOZPEaAxnDQ/oHh3Iea', 'candidate', 'Demo User', '+91 98765 43212', TRUE),
(6, 'user.alex@gmail.com', '$2a$10$ttODAff1LAjdcB/yotPhRuLja5gLqVySsqHOZPEaAxnDQ/oHh3Iea', 'candidate', 'Alex Rivera', '+1 (555) 012-3456', TRUE),
(7, 'user.priya@yahoo.com', '$2a$10$ttODAff1LAjdcB/yotPhRuLja5gLqVySsqHOZPEaAxnDQ/oHh3Iea', 'candidate', 'Priya Sharma', '+1 (555) 013-8822', TRUE),
(8, 'user.marcus@outlook.com', '$2a$10$ttODAff1LAjdcB/yotPhRuLja5gLqVySsqHOZPEaAxnDQ/oHh3Iea', 'candidate', 'Marcus Vance', '+1 (555) 015-6677', TRUE),
(9, 'user.rachel@gmail.com', '$2a$10$ttODAff1LAjdcB/yotPhRuLja5gLqVySsqHOZPEaAxnDQ/oHh3Iea', 'candidate', 'Rachel Green', '+1 (555) 018-9900', TRUE);

SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));

-- 2. COMPANIES (3 HR Companies)
INSERT INTO companies (id, recruiter_id, company_name, logo_url, description, industry, company_size, website, location) VALUES
(1, 2, 'JRMS Technologies Pvt. Ltd.', 'https://images.unsplash.com/photo-1560179707-f14e90ef3623?w=300', 'Enterprise recruitment systems software engineering and cloud infrastructure development firm.', 'Information Technology', '100-500', 'https://jrms.example.local', 'India'),
(2, 3, 'InnovateTech Solutions', 'https://images.unsplash.com/photo-1549923746-c502d488b3ea?w=300', 'Leading AI and full-stack software development firm specializing in cloud enterprise systems.', 'Software & Technology', '250-500', 'https://innovatetech.example.com', 'San Francisco, CA'),
(3, 4, 'CloudScale Systems', 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=300', 'Next-generation cloud infrastructure, Kubernetes, and DevOps consulting company.', 'Cloud Computing', '100-250', 'https://cloudscale.example.io', 'Austin, TX');

SELECT setval('companies_id_seq', (SELECT MAX(id) FROM companies));

-- 3. JOB SEEKERS (5 Users)
INSERT INTO job_seekers (id, user_id, location, bio, profile_photo, resume_url, resume_filename) VALUES
(1, 5, 'India', 'Fullstack Software Engineer & Demo Candidate for JRMS recruitment system testing.', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300', '/uploads/resumes/demo_user_resume.pdf', 'demo_user_resume.pdf'),
(2, 6, 'Seattle, WA', 'Passionate Senior Mobile & Flutter Engineer with 4+ years of experience building cross-platform apps.', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300', '/uploads/resumes/alex_rivera_resume.pdf', 'alex_rivera_resume.pdf'),
(3, 7, 'San Jose, CA', 'Full Stack Developer proficient in React, Node.js, Express, and MySQL/PostgreSQL databases.', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300', '/uploads/resumes/priya_sharma_resume.pdf', 'priya_sharma_resume.pdf'),
(4, 8, 'Chicago, IL', 'Product Designer & UI/UX Specialist with expertise in Figma, Design Systems, and Design Tokens.', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300', '/uploads/resumes/marcus_vance_resume.pdf', 'marcus_vance_resume.pdf'),
(5, 9, 'New York, NY', 'Frontend Engineer specializing in React, Next.js, and modern UI/UX web development.', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300', '/uploads/resumes/rachel_green_resume.pdf', 'rachel_green_resume.pdf');

SELECT setval('job_seekers_id_seq', (SELECT MAX(id) FROM job_seekers));

-- 4. EDUCATION
INSERT INTO education (seeker_id, degree, institution, field_of_study, start_year, end_year, grade) VALUES
(1, 'Bachelor of Technology (B.Tech)', 'Indian Institute of Technology', 'Computer Science & Engineering', 2018, 2022, '3.9 GPA'),
(2, 'Bachelor of Computer Applications (BCA)', 'University of Washington', 'Computer Science & Software Systems', 2018, 2021, '3.8 GPA'),
(2, 'Master of Science in Software Engineering', 'Stanford University', 'Software Architecture', 2021, 2023, '3.9 GPA'),
(3, 'Bachelor of Technology (B.Tech)', 'San Jose State University', 'Information Technology', 2017, 2021, '3.7 GPA'),
(4, 'Bachelor of Fine Arts (BFA)', 'School of the Art Institute of Chicago', 'Interactive Media & Graphic Design', 2018, 2022, '3.85 GPA'),
(5, 'Bachelor of Science (BS)', 'Columbia University', 'Computer Science', 2019, 2023, '3.8 GPA');

-- 5. EXPERIENCE
INSERT INTO experience (seeker_id, job_title, company_name, location, start_date, end_date, is_current, description) VALUES
(1, 'Full Stack Software Engineer', 'JRMS Tech', 'India', '2022-07-01', NULL, TRUE, 'Built scalable Node.js microservices, PostgreSQL databases, and Flutter user interfaces.'),
(2, 'Senior Flutter Developer', 'Apex Mobile Apps', 'Seattle, WA', '2023-01-15', NULL, TRUE, 'Architected cross-platform Flutter mobile applications for over 500,000 active users.'),
(3, 'Full Stack Engineer', 'WebFlow Systems', 'San Jose, CA', '2021-08-01', NULL, TRUE, 'Built Node.js microservices and React dashboards with database transaction management.'),
(4, 'Lead UI/UX Designer', 'PixelCraft Agency', 'Chicago, IL', '2022-03-01', NULL, TRUE, 'Designed user interfaces, wireframes, and design systems for enterprise SaaS clients.'),
(5, 'Frontend Web Developer', 'MediaTech Inc', 'New York, NY', '2023-06-01', NULL, TRUE, 'Developed responsive web applications with Next.js, React, and TypeScript.');

-- 6. SKILLS
INSERT INTO skills (id, skill_name) VALUES
(1, 'Flutter'),
(2, 'Dart'),
(3, 'Node.js'),
(4, 'Express.js'),
(5, 'PostgreSQL'),
(6, 'React.js'),
(7, 'Figma'),
(8, 'UI/UX Design'),
(9, 'REST API'),
(10, 'Docker'),
(11, 'Git'),
(12, 'Python');

SELECT setval('skills_id_seq', (SELECT MAX(id) FROM skills));

-- 7. CANDIDATE_SKILLS
INSERT INTO candidate_skills (seeker_id, skill_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 9), (1, 11),
(2, 1), (2, 2), (2, 3), (2, 9), (2, 11),
(3, 3), (3, 4), (3, 5), (3, 6), (3, 9), (3, 11),
(4, 7), (4, 8), (4, 6),
(5, 6), (5, 9), (5, 11);

-- 8. CATEGORIES
INSERT INTO categories (id, name, icon_name, description) VALUES
(1, 'Mobile Development', 'phone_android', 'Flutter, React Native, Android Native, iOS Swift development roles'),
(2, 'Backend & Cloud', 'dns', 'Node.js, Python, Java, PostgreSQL, Cloud Infrastructure & Microservices'),
(3, 'Frontend Web', 'web', 'React, Vue, Angular, Modern Web Technologies'),
(4, 'UI/UX & Design', 'palette', 'Product Design, UI/UX, Figma, User Research & Prototyping'),
(5, 'Data Science & AI', 'psychology', 'Machine Learning, Data Engineering, Analytics & AI Engineering'),
(6, 'Cybersecurity & Networks', 'security', 'Information Security, Network Engineering, Ethical Hacking & SecOps'),
(7, 'Digital Marketing & SEO', 'campaign', 'Growth Marketing, SEO, Social Media, Content & Digital Strategy'),
(8, 'Product & Management', 'assignment', 'Technical Product Management, Project Operations & Agile Leadership'),
(9, 'Human Resources & Talent', 'people', 'Technical Recruitment, HR Operations, People Experience & Culture'),
(10, 'Finance & Business Intelligence', 'insights', 'Financial Planning, Business Intelligence, Data Analysis & Strategy'),
(11, 'Quality Assurance & Testing', 'bug_report', 'QA Automation, SDET, Software Testing & Performance Engineering'),
(12, 'Sales & Business Development', 'handshake', 'Enterprise B2B Sales, Account Management & Business Partnerships');

SELECT setval('categories_id_seq', (SELECT MAX(id) FROM categories));

-- 9. JOBS
INSERT INTO jobs (id, company_id, category_id, title, description, responsibilities, requirements, skills_required, experience_years, salary_min, salary_max, job_type, work_mode, location, openings, deadline, status) VALUES
(1, 1, 1, 'Senior Flutter Architect', 'We are looking for an expert Flutter Developer to lead cross-platform mobile development for our flag-ship recruitment SaaS product.', 'Architect scalable Flutter applications with Provider state management; Integrate HTTP REST APIs; Implement custom Material 3 design systems.', '3+ years of professional Flutter experience; Strong knowledge of Dart, REST APIs, and SecureStorage.', 'Flutter, Dart, Provider, REST API, Git', 3, 95000.00, 130000.00, 'Full Time', 'Remote', 'India', 2, '2026-11-30', 'active'),
(2, 1, 2, 'Node.js Backend Engineer', 'Seeking a skilled backend developer to build robust Express.js REST APIs and optimize database queries for high concurrency.', 'Design normalized PostgreSQL database tables; Create secure JWT auth middleware; Build RESTful endpoints.', '2+ years Node.js and Express experience; Strong SQL proficiency.', 'Node.js, Express.js, PostgreSQL, REST API, JWT', 2, 85000.00, 115000.00, 'Full Time', 'Hybrid', 'India', 3, '2026-12-15', 'active'),
(3, 2, 1, 'Lead Mobile Engineer (Flutter/React Native)', 'Lead mobile app development for our enterprise client software products.', 'Build intuitive mobile screens; Integrate cloud REST APIs; Lead sprint planning.', '3+ years mobile development experience.', 'Flutter, Dart, REST API, Git', 3, 90000.00, 125000.00, 'Full Time', 'Remote', 'San Francisco, CA', 2, '2026-12-01', 'active'),
(4, 3, 2, 'Cloud DevOps & Systems Architect', 'Manage cloud infrastructure, CI/CD pipelines, Docker containers, and Kubernetes clusters.', 'Maintain 99.9% system uptime; Automate cloud deployments; Enforce database security protocols.', 'Experience with AWS/GCP, Docker, Kubernetes, Linux system administration.', 'Docker, AWS, Kubernetes, Linux, PostgreSQL', 4, 110000.00, 150000.00, 'Full Time', 'Remote', 'Austin, TX', 1, '2026-10-31', 'active'),
(5, 1, 4, 'UI/UX Product Designer', 'Craft beautiful, accessible, and intuitive visual interfaces for web and mobile applications.', 'Create Figma design components; Conduct user research; Build interactive UI prototypes.', '3+ years in product design; Mastery of Figma, typography, grid systems, and Material Design 3.', 'Figma, UI/UX Design, User Research, Wireframing', 3, 80000.00, 110000.00, 'Full Time', 'On-site', 'India', 2, '2026-11-15', 'active');

SELECT setval('jobs_id_seq', (SELECT MAX(id) FROM jobs));

-- 10. APPLICATIONS
INSERT INTO applications (id, job_id, seeker_id, status, cover_letter, applied_at) VALUES
(1, 1, 1, 'Interview Scheduled', 'I have extensive experience building fullstack Node.js and Flutter applications and would love to contribute to JRMS Tech.', '2026-09-01 10:30:00+00'),
(2, 2, 2, 'Shortlisted', 'My solid foundation in Express.js and database normalization makes me an ideal fit for this role.', '2026-09-02 14:15:00+00'),
(3, 3, 3, 'Under Review', 'As a fullstack engineer passionate about cloud architecture, I am excited to apply.', '2026-09-03 09:45:00+00'),
(4, 4, 4, 'Applied', 'Product designer eager to craft user-centered UI/UX systems.', '2026-09-04 16:20:00+00'),
(5, 5, 5, 'Applied', 'Frontend developer enthusiastic about building modern web applications.', '2026-09-05 11:10:00+00');

SELECT setval('applications_id_seq', (SELECT MAX(id) FROM applications));

-- 11. SAVED_JOBS
INSERT INTO saved_jobs (seeker_id, job_id, saved_at) VALUES
(1, 2, '2026-09-01 11:00:00+00'),
(1, 4, '2026-09-02 12:30:00+00'),
(2, 1, '2026-09-03 15:10:00+00');

-- 12. INTERVIEWS
INSERT INTO interviews (id, application_id, scheduled_date, scheduled_time, interview_mode, location_or_link, interviewer_name, notes, status) VALUES
(1, 1, '2026-09-20', '14:00:00', 'Online', 'https://meet.google.com/jrms-flutter-tech', 'Demo HR Manager', 'Technical interview focusing on Flutter Provider state management, API architecture, and live coding.', 'Scheduled');

SELECT setval('interviews_id_seq', (SELECT MAX(id) FROM interviews));

-- 13. NOTIFICATIONS
INSERT INTO notifications (id, user_id, title, message, type, is_read) VALUES
(1, 5, 'Application Status Updated', 'Your application for Senior Flutter Architect at JRMS Technologies Pvt. Ltd. has been updated to Interview Scheduled.', 'success', FALSE),
(2, 5, 'Interview Invitation', 'You have an upcoming technical interview on Sep 20, 2026 at 2:00 PM.', 'info', FALSE),
(3, 2, 'New Job Applicant', 'Demo User applied for Senior Flutter Architect.', 'info', TRUE),
(4, 6, 'Application Status Updated', 'Your application for Node.js Backend Engineer has been Shortlisted.', 'success', FALSE);

SELECT setval('notifications_id_seq', (SELECT MAX(id) FROM notifications));
