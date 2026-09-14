-- ============================================================================
-- JOB RECRUITMENT MANAGEMENT SYSTEM (JRMS) - POSTGRESQL SEED DATA (SUPABASE)
-- 1 ADMIN | 3 HR ACCOUNTS | 5 USER ACCOUNTS (TOTAL = 9 ACCOUNTS)
-- Passwords:
-- Admin: Admin@JRMS2026
-- HR:    HR1@JRMS2026, HR2@JRMS2026, HR3@JRMS2026
-- Users: User1@JRMS2026, User2@JRMS2026, User3@JRMS2026, User4@JRMS2026, User5@JRMS2026
-- ============================================================================

TRUNCATE notifications, interviews, saved_jobs, applications, jobs, categories, candidate_skills, skills, experience, education, job_seekers, companies, users RESTART IDENTITY CASCADE;

-- 1. USERS (1 Admin + 3 HR + 5 Users = 9 Total Accounts)
INSERT INTO users (id, email, password_hash, role, full_name, phone, is_active) VALUES
-- 1 ADMIN ACCOUNT
(1, 'admin@jrms.local', '$2a$10$0nhOBuMsdX3.D7/X9ZEK3e04fIvfnuE8xuADs7alxtRHV//hVvVwy', 'admin', 'System Administrator', '+91 98765 43210', TRUE),

-- 3 HR ACCOUNTS
(2, 'hr1@jrms.local', '$2a$10$MK4KOhJlvOqEH8S/JNpTpOs6Vwm.DxQkwydlM/U0TK7ydorreSEhy', 'recruiter', 'Aarav Sharma', '+91 98765 43211', TRUE),
(3, 'hr2@jrms.local', '$2a$10$7d8N.vDgz5NELeLTsw/1/.Dwb0oQm4HfZnBZZORpPROrAIaCTi3ZW', 'recruiter', 'Priya Verma', '+91 98765 43212', TRUE),
(4, 'hr3@jrms.local', '$2a$10$1Hx.O4etRq5qR2ZYr5Baeuc8g0Wj7IZYTqIyxnLfWcjDXPkF02Hu6', 'recruiter', 'Rahul Mehta', '+91 98765 43213', TRUE),

-- 5 USER ACCOUNTS (CANDIDATES)
(5, 'user1@jrms.local', '$2a$10$T41C0bQje1Y4mZVmZ0RQQulvgekLQXBjSVLBpr73aKEmNrSalVhr2', 'candidate', 'Aditya Kumar', '+91 98765 43214', TRUE),
(6, 'user2@jrms.local', '$2a$10$wXD6qj//nI0hhy/e7rQVnedgOxhQ4qR3KtaVw9WQj1TD10hlTQHz.', 'candidate', 'Ananya Singh', '+91 98765 43215', TRUE),
(7, 'user3@jrms.local', '$2a$10$Aq6QHkdlki8oTxGTMA5RaewS9YnRZsdwUHSj.iDYGRKU7MTD3a9b6', 'candidate', 'Rohan Gupta', '+91 98765 43216', TRUE),
(8, 'user4@jrms.local', '$2a$10$Z43rXzcwaikLIiqMxj8PWezF9dAKuVbAgUJDCJelyc7qFSrAaQU8K', 'candidate', 'Sneha Patel', '+91 98765 43217', TRUE),
(9, 'user5@jrms.local', '$2a$10$Mil/177j4qpKFTBN7JJ0RewJLvhgbSQZ1uTBl7MITt4eUkFk.PIbi', 'candidate', 'Vivek Sharma', '+91 98765 43218', TRUE);

SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));

-- 2. COMPANIES (3 HR Companies)
INSERT INTO companies (id, recruiter_id, company_name, logo_url, description, industry, company_size, website, location) VALUES
(1, 2, 'JRMS Technologies Pvt. Ltd.', 'https://images.unsplash.com/photo-1560179707-f14e90ef3623?w=300', 'Enterprise recruitment systems software engineering and cloud infrastructure development firm.', 'Information Technology', '100-500', 'https://jrms.example.local', 'India'),
(2, 3, 'NextGen Solutions India', 'https://images.unsplash.com/photo-1549923746-c502d488b3ea?w=300', 'Leading AI, cloud computing, and full-stack software development solutions company.', 'Software & Technology', '250-500', 'https://nextgen.example.in', 'Bengaluru, India'),
(3, 4, 'InnovateWorks Systems', 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=300', 'Next-generation cloud infrastructure, Kubernetes, and DevOps software engineering firm.', 'Cloud Computing', '100-250', 'https://innovateworks.example.io', 'Mumbai, India');

SELECT setval('companies_id_seq', (SELECT MAX(id) FROM companies));

-- 3. JOB SEEKERS (5 Users)
INSERT INTO job_seekers (id, user_id, location, bio, profile_photo, resume_url, resume_filename) VALUES
(1, 5, 'Bengaluru, India', 'Full Stack Flutter & Node.js Developer with experience building scalable enterprise cloud platforms.', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300', '/uploads/resumes/aditya_kumar_resume.pdf', 'aditya_kumar_resume.pdf'),
(2, 6, 'Delhi NCR, India', 'Senior Mobile Engineer specializing in cross-platform Flutter and Dart app architecture.', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300', '/uploads/resumes/ananya_singh_resume.pdf', 'ananya_singh_resume.pdf'),
(3, 7, 'Pune, India', 'Backend Software Engineer proficient in Node.js, Express, PostgreSQL, REST APIs, and Microservices.', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300', '/uploads/resumes/rohan_gupta_resume.pdf', 'rohan_gupta_resume.pdf'),
(4, 8, 'Hyderabad, India', 'UI/UX Product Designer with expertise in Figma design systems, Material 3, and user research.', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300', '/uploads/resumes/sneha_patel_resume.pdf', 'sneha_patel_resume.pdf'),
(5, 9, 'Mumbai, India', 'Frontend Engineer specializing in React, Next.js, TypeScript, and modern web application interfaces.', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300', '/uploads/resumes/vivek_sharma_resume.pdf', 'vivek_sharma_resume.pdf');

SELECT setval('job_seekers_id_seq', (SELECT MAX(id) FROM job_seekers));

-- 4. EDUCATION
INSERT INTO education (seeker_id, degree, institution, field_of_study, start_year, end_year, grade) VALUES
(1, 'Bachelor of Technology (B.Tech)', 'Indian Institute of Technology', 'Computer Science & Engineering', 2018, 2022, '3.9 GPA'),
(2, 'Bachelor of Computer Applications (BCA)', 'Delhi University', 'Computer Applications & Systems', 2018, 2021, '3.8 GPA'),
(2, 'Master of Technology (M.Tech)', 'IIT Delhi', 'Software Engineering', 2021, 2023, '3.9 GPA'),
(3, 'Bachelor of Engineering (B.E.)', 'Pune University', 'Information Technology', 2017, 2021, '3.7 GPA'),
(4, 'Bachelor of Design (B.Des)', 'National Institute of Design', 'Interaction & Industrial Design', 2018, 2022, '3.85 GPA'),
(5, 'Bachelor of Science (B.Sc)', 'Mumbai University', 'Computer Science', 2019, 2023, '3.8 GPA');

-- 5. EXPERIENCE
INSERT INTO experience (seeker_id, job_title, company_name, location, start_date, end_date, is_current, description) VALUES
(1, 'Full Stack Software Engineer', 'JRMS Tech', 'Bengaluru, India', '2022-07-01', NULL, TRUE, 'Built scalable Node.js microservices, PostgreSQL databases, and Flutter user interfaces.'),
(2, 'Senior Flutter Developer', 'Apex Mobile Solutions', 'Delhi NCR, India', '2023-01-15', NULL, TRUE, 'Architected cross-platform Flutter mobile applications for active users.'),
(3, 'Backend Engineer', 'CloudStack India', 'Pune, India', '2021-08-01', NULL, TRUE, 'Built Express.js REST APIs and PostgreSQL queries with transaction safety.'),
(4, 'Lead UI/UX Designer', 'PixelCraft Digital', 'Hyderabad, India', '2022-03-01', NULL, TRUE, 'Created user interface component systems and interactive prototypes.'),
(5, 'Frontend Web Developer', 'WebTech Innovations', 'Mumbai, India', '2023-06-01', NULL, TRUE, 'Developed responsive web applications with React and modern JavaScript.');

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
(1, 1, 1, 'Senior Flutter Architect', 'We are looking for an expert Flutter Developer to lead cross-platform mobile development for our recruitment SaaS product.', 'Architect scalable Flutter applications with Provider state management; Integrate HTTP REST APIs; Implement custom Material 3 design systems.', '3+ years of professional Flutter experience; Strong knowledge of Dart, REST APIs, and state management.', 'Flutter, Dart, Provider, REST API, Git', 3, 95000.00, 130000.00, 'Full Time', 'Remote', 'Bengaluru, India', 2, '2026-11-30', 'active'),
(2, 1, 2, 'Node.js Backend Engineer', 'Seeking a backend developer to build robust Express.js REST APIs and optimize database queries.', 'Design normalized PostgreSQL database tables; Create secure JWT auth middleware; Build RESTful endpoints.', '2+ years Node.js and Express experience; Strong SQL proficiency.', 'Node.js, Express.js, PostgreSQL, REST API, JWT', 2, 85000.00, 115000.00, 'Full Time', 'Hybrid', 'Bengaluru, India', 3, '2026-12-15', 'active'),
(3, 2, 1, 'Lead Mobile Engineer (Flutter)', 'Lead mobile app development for our enterprise client software products at NextGen Solutions.', 'Build intuitive mobile screens; Integrate cloud REST APIs; Lead sprint planning.', '3+ years mobile development experience.', 'Flutter, Dart, REST API, Git', 3, 90000.00, 125000.00, 'Full Time', 'Remote', 'Delhi NCR, India', 2, '2026-12-01', 'active'),
(4, 3, 2, 'Cloud DevOps & Systems Architect', 'Manage cloud infrastructure, CI/CD pipelines, Docker containers, and Kubernetes clusters at InnovateWorks.', 'Maintain system uptime; Automate cloud deployments; Enforce database security protocols.', 'Experience with Docker, Kubernetes, Linux system administration.', 'Docker, Kubernetes, Linux, PostgreSQL', 4, 110000.00, 150000.00, 'Full Time', 'Remote', 'Mumbai, India', 1, '2026-10-31', 'active'),
(5, 1, 4, 'UI/UX Product Designer', 'Craft visual interfaces for web and mobile recruitment management software.', 'Create Figma design components; Conduct user research; Build interactive UI prototypes.', '3+ years in product design; Mastery of Figma and UI component design.', 'Figma, UI/UX Design, User Research, Wireframing', 3, 80000.00, 110000.00, 'Full Time', 'On-site', 'Bengaluru, India', 2, '2026-11-15', 'active');

SELECT setval('jobs_id_seq', (SELECT MAX(id) FROM jobs));

-- 10. APPLICATIONS
INSERT INTO applications (id, job_id, seeker_id, status, cover_letter, applied_at) VALUES
(1, 1, 1, 'Interview Scheduled', 'I have extensive experience building fullstack Node.js and Flutter applications and would love to contribute to JRMS Tech.', '2026-09-01 10:30:00+00'),
(2, 2, 2, 'Shortlisted', 'My solid foundation in Express.js and database normalization makes me an ideal fit for this backend role.', '2026-09-02 14:15:00+00'),
(3, 3, 3, 'Under Review', 'As a fullstack engineer passionate about cloud architecture, I am excited to apply.', '2026-09-03 09:45:00+00'),
(4, 4, 4, 'Applied', 'Product designer eager to craft user-centered UI/UX design systems.', '2026-09-04 16:20:00+00'),
(5, 5, 5, 'Applied', 'Frontend developer enthusiastic about building modern web application interfaces.', '2026-09-05 11:10:00+00');

SELECT setval('applications_id_seq', (SELECT MAX(id) FROM applications));

-- 11. SAVED_JOBS
INSERT INTO saved_jobs (seeker_id, job_id, saved_at) VALUES
(1, 2, '2026-09-01 11:00:00+00'),
(1, 4, '2026-09-02 12:30:00+00'),
(2, 1, '2026-09-03 15:10:00+00');

-- 12. INTERVIEWS
INSERT INTO interviews (id, application_id, scheduled_date, scheduled_time, interview_mode, location_or_link, interviewer_name, notes, status) VALUES
(1, 1, '2026-09-20', '14:00:00', 'Online', 'https://meet.google.com/jrms-flutter-tech', 'Aarav Sharma', 'Technical interview focusing on Flutter Provider state management, API architecture, and live coding.', 'Scheduled');

SELECT setval('interviews_id_seq', (SELECT MAX(id) FROM interviews));

-- 13. NOTIFICATIONS
INSERT INTO notifications (id, user_id, title, message, type, is_read) VALUES
(1, 5, 'Application Status Updated', 'Your application for Senior Flutter Architect at JRMS Technologies Pvt. Ltd. has been updated to Interview Scheduled.', 'success', FALSE),
(2, 5, 'Interview Invitation', 'You have an upcoming technical interview on Sep 20, 2026 at 2:00 PM.', 'info', FALSE),
(3, 2, 'New Job Applicant', 'Aditya Kumar applied for Senior Flutter Architect.', 'info', TRUE),
(4, 6, 'Application Status Updated', 'Your application for Node.js Backend Engineer has been Shortlisted.', 'success', FALSE);

SELECT setval('notifications_id_seq', (SELECT MAX(id) FROM notifications));
