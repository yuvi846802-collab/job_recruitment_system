-- ============================================================================
-- JOB RECRUITMENT MANAGEMENT SYSTEM (JRMS) - POSTGRESQL SEED DATA (SUPABASE)
-- Password for all seeded users: Password@123
-- ============================================================================

TRUNCATE notifications, interviews, saved_jobs, applications, jobs, categories, candidate_skills, skills, experience, education, job_seekers, companies, users RESTART IDENTITY CASCADE;

-- 1. USERS
INSERT INTO users (id, email, password_hash, role, full_name, phone, is_active) VALUES
(1, 'admin@jrms.com', '$2a$10$5M8pYlG1fU8YgG1N5bX3u.8R9mN0p1q2r3s4t5u6v7w8x9y0z1a2b', 'admin', 'System Administrator', '+1 (555) 019-2831', TRUE),
(2, 'recruiter.tech@innovate.com', '$2a$10$5M8pYlG1fU8YgG1N5bX3u.8R9mN0p1q2r3s4t5u6v7w8x9y0z1a2b', 'recruiter', 'Sarah Jenkins', '+1 (555) 014-9921', TRUE),
(3, 'hr@cloudscale.io', '$2a$10$5M8pYlG1fU8YgG1N5bX3u.8R9mN0p1q2r3s4t5u6v7w8x9y0z1a2b', 'recruiter', 'David Miller', '+1 (555) 017-4820', TRUE),
(4, 'talent@designify.co', '$2a$10$5M8pYlG1fU8YgG1N5bX3u.8R9mN0p1q2r3s4t5u6v7w8x9y0z1a2b', 'recruiter', 'Elena Rostova', '+1 (555) 018-7712', TRUE),
(5, 'candidate.alex@gmail.com', '$2a$10$5M8pYlG1fU8YgG1N5bX3u.8R9mN0p1q2r3s4t5u6v7w8x9y0z1a2b', 'candidate', 'Alex Rivera', '+1 (555) 012-3456', TRUE),
(6, 'candidate.priya@yahoo.com', '$2a$10$5M8pYlG1fU8YgG1N5bX3u.8R9mN0p1q2r3s4t5u6v7w8x9y0z1a2b', 'candidate', 'Priya Sharma', '+1 (555) 013-8822', TRUE),
(7, 'candidate.marcus@outlook.com', '$2a$10$5M8pYlG1fU8YgG1N5bX3u.8R9mN0p1q2r3s4t5u6v7w8x9y0z1a2b', 'candidate', 'Marcus Vance', '+1 (555) 015-6677', TRUE),
(8, 'admin@jrms.local', '$2a$10$9LyxTYPk3LUhzjsgpinSYe3kCjeY2NifAg7cw.BcEBlHvTXn6LYq.', 'admin', 'Demo Admin', '+91 98765 43210', TRUE),
(9, 'hr@jrms.local', '$2a$10$.lYxkO0BhgQfqkgIbB9JpencgA7F/rLPjRZeqP9.vN78E9LvLRyze', 'recruiter', 'Demo HR Manager', '+91 98765 43211', TRUE),
(10, 'user@jrms.local', '$2a$10$ttODAff1LAjdcB/yotPhRuLja5gLqVySsqHOZPEaAxnDQ/oHh3Iea', 'candidate', 'Demo User', '+91 98765 43212', TRUE);

SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));

-- 2. COMPANIES
INSERT INTO companies (id, recruiter_id, company_name, logo_url, description, industry, company_size, website, location) VALUES
(1, 2, 'InnovateTech Solutions', 'https://images.unsplash.com/photo-1549923746-c502d488b3ea?w=300', 'Leading AI and full-stack software development firm specializing in cloud enterprise systems.', 'Software & Technology', '250-500', 'https://innovatetech.example.com', 'San Francisco, CA'),
(2, 3, 'CloudScale Systems', 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=300', 'Next-generation cloud infrastructure, Kubernetes, and DevOps consulting company.', 'Cloud Computing', '100-250', 'https://cloudscale.example.io', 'Austin, TX'),
(3, 4, 'Designify Studio', 'https://images.unsplash.com/photo-1572021335469-31706a17aaef?w=300', 'Award-winning UI/UX digital design agency crafting human-centered mobile and web experiences.', 'Design & Media', '50-100', 'https://designify.example.co', 'New York, NY'),
(4, 9, 'JRMS Technologies Pvt. Ltd.', 'https://images.unsplash.com/photo-1560179707-f14e90ef3623?w=300', 'Enterprise recruitment systems software engineering and cloud infrastructure development firm.', 'Information Technology', '100-500', 'https://jrms.example.local', 'India');

SELECT setval('companies_id_seq', (SELECT MAX(id) FROM companies));

-- 3. JOB SEEKERS
INSERT INTO job_seekers (id, user_id, location, bio, profile_photo, resume_url, resume_filename) VALUES
(1, 5, 'Seattle, WA', 'Passionate Senior Mobile & Flutter Engineer with 4+ years of experience building cross-platform apps.', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300', '/uploads/resumes/alex_rivera_resume.pdf', 'alex_rivera_resume.pdf'),
(2, 6, 'San Jose, CA', 'Full Stack Developer proficient in React, Node.js, Express, and MySQL/PostgreSQL databases.', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300', '/uploads/resumes/priya_sharma_resume.pdf', 'priya_sharma_resume.pdf'),
(3, 7, 'Chicago, IL', 'Product Designer & UI/UX Specialist with expertise in Figma, Design Systems, and Design Tokens.', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300', '/uploads/resumes/marcus_vance_resume.pdf', 'marcus_vance_resume.pdf'),
(4, 10, 'India', 'Fullstack Software Engineer & Demo Candidate for JRMS recruitment system testing.', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300', '/uploads/resumes/demo_user_resume.pdf', 'demo_user_resume.pdf');

SELECT setval('job_seekers_id_seq', (SELECT MAX(id) FROM job_seekers));

-- 4. EDUCATION
INSERT INTO education (seeker_id, degree, institution, field_of_study, start_year, end_year, grade) VALUES
(1, 'Bachelor of Computer Applications (BCA)', 'University of Washington', 'Computer Science & Software Systems', 2018, 2021, '3.8 GPA'),
(1, 'Master of Science in Software Engineering', 'Stanford University', 'Software Architecture', 2021, 2023, '3.9 GPA'),
(2, 'Bachelor of Technology (B.Tech)', 'San Jose State University', 'Information Technology', 2017, 2021, '3.7 GPA'),
(3, 'Bachelor of Fine Arts (BFA)', 'School of the Art Institute of Chicago', 'Interactive Media & Graphic Design', 2018, 2022, '3.85 GPA');

-- 5. EXPERIENCE
INSERT INTO experience (seeker_id, job_title, company_name, location, start_date, end_date, is_current, description) VALUES
(1, 'Senior Flutter Developer', 'Apex Mobile Apps', 'Seattle, WA', '2023-01-15', NULL, TRUE, 'Architected cross-platform Flutter mobile applications for over 500,000 active users.'),
(1, 'Junior Mobile Developer', 'TechCraft Inc', 'Seattle, WA', '2021-06-01', '2022-12-31', FALSE, 'Developed native Android and Flutter widgets, REST API integrations, and local caching.'),
(2, 'Full Stack Engineer', 'WebFlow Systems', 'San Jose, CA', '2021-08-01', NULL, TRUE, 'Built Node.js microservices and React dashboards with database transaction management.'),
(3, 'Lead UI/UX Designer', 'PixelCraft Agency', 'Chicago, IL', '2022-03-01', NULL, TRUE, 'Designed user interfaces, wireframes, and design systems for enterprise SaaS clients.');

-- 6. SKILLS
INSERT INTO skills (id, skill_name) VALUES
(1, 'Flutter'),
(2, 'Dart'),
(3, 'Node.js'),
(4, 'Express.js'),
(5, 'MySQL'),
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
(1, 1), (1, 2), (1, 3), (1, 9), (1, 11),
(2, 3), (2, 4), (2, 5), (2, 6), (2, 9), (2, 11),
(3, 7), (3, 8), (3, 6);

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
(1, 1, 1, 'Senior Flutter Architect', 'We are looking for an expert Flutter Developer to lead cross-platform mobile development for our flag-ship recruitment SaaS product.', 'Architect scalable Flutter applications with Provider state management; Integrate HTTP REST APIs; Implement custom Material 3 design systems.', '3+ years of professional Flutter experience; Strong knowledge of Dart, REST APIs, and SecureStorage.', 'Flutter, Dart, Provider, REST API, Git', 3, 95000.00, 130000.00, 'Full Time', 'Remote', 'San Francisco, CA', 2, '2026-11-30', 'active'),
(2, 1, 2, 'Node.js Backend Engineer', 'Seeking a skilled backend developer to build robust Express.js REST APIs and optimize database queries for high concurrency.', 'Design normalized PostgreSQL database tables; Create secure JWT auth middleware; Build RESTful endpoints.', '2+ years Node.js and Express experience; Strong SQL proficiency.', 'Node.js, Express.js, PostgreSQL, REST API, JWT', 2, 85000.00, 115000.00, 'Full Time', 'Hybrid', 'San Francisco, CA', 3, '2026-12-15', 'active'),
(3, 2, 2, 'Cloud DevOps & Systems Architect', 'Manage cloud infrastructure, CI/CD pipelines, Docker containers, and Kubernetes clusters.', 'Maintain 99.9% system uptime; Automate cloud deployments; Enforce database security protocols.', 'Experience with AWS/GCP, Docker, Kubernetes, Linux system administration.', 'Docker, AWS, Kubernetes, Linux, PostgreSQL', 4, 110000.00, 150000.00, 'Full Time', 'Remote', 'Austin, TX', 1, '2026-10-31', 'active'),
(4, 3, 4, 'Senior UI/UX Product Designer', 'Craft beautiful, accessible, and intuitive visual interfaces for web and mobile applications.', 'Create Figma design components; Conduct user research; Build interactive UI prototypes.', '3+ years in product design; Mastery of Figma, typography, grid systems, and Material Design 3.', 'Figma, UI/UX Design, User Research, Wireframing', 3, 80000.00, 110000.00, 'Full Time', 'On-site', 'New York, NY', 2, '2026-11-15', 'active'),
(5, 2, 1, 'Junior Mobile Developer (Flutter)', 'Great opportunity for enthusiastic junior developers to work with modern Flutter and REST APIs.', 'Assist in building widget layouts; Implement state management; Write unit and widget tests.', 'Understanding of Dart, OOP concepts, Flutter widgets, and REST APIs.', 'Flutter, Dart, Git, REST API', 1, 55000.00, 75000.00, 'Full Time', 'Hybrid', 'Austin, TX', 2, '2026-12-31', 'active'),
(6, 1, 3, 'Lead React & Next.js Web Developer', 'Architect ultra-fast server-side rendered web applications using Next.js 14, TypeScript, and Tailwind CSS.', 'Build modular React components; Optimize Web Vitals performance; Integrate GraphQL & REST APIs.', '4+ years of professional React & Next.js experience; Strong TypeScript and CSS skills.', 'React, Next.js, TypeScript, Tailwind CSS, REST API', 4, 90000.00, 125000.00, 'Full Time', 'Hybrid', 'San Francisco, CA', 2, '2026-12-01', 'active'),
(7, 2, 5, 'Senior Machine Learning & AI Specialist', 'Develop and deploy LLM models, predictive analytics, and natural language processing solutions.', 'Train custom PyTorch / TensorFlow models; Build AI data pipelines; Deploy model microservices on Kubernetes.', '3+ years in Applied ML/AI; Proficiency in Python, PyTorch, LangChain, and MLOps.', 'Python, PyTorch, Machine Learning, TensorFlow, MLOps', 3, 120000.00, 165000.00, 'Full Time', 'Remote', 'Austin, TX', 2, '2026-12-20', 'active'),
(8, 3, 7, 'Growth Marketing & SEO Strategist', 'Lead organic search engine optimization, content strategy, and digital user acquisition campaigns.', 'Execute technical SEO audits; Manage Google Analytics 4 & Search Console; Run targeted paid acquisition campaigns.', '3+ years in B2B SaaS digital marketing & technical SEO.', 'SEO, Google Analytics, Digital Marketing, Content Strategy, SEM', 3, 70000.00, 95000.00, 'Full Time', 'Remote', 'New York, NY', 1, '2026-11-25', 'active'),
(9, 1, 6, 'Cybersecurity & Threat Analyst', 'Protect enterprise cloud architecture, conduct vulnerability assessments, and implement Zero-Trust security.', 'Monitor SIEM logs; Perform penetration testing & risk audits; Enforce SOC2 & ISO27001 compliance protocols.', '3+ years in Information Security; Certifications like CISSP or CEH preferred.', 'Cybersecurity, Penetration Testing, SIEM, SOC2, Network Security', 3, 100000.00, 140000.00, 'Full Time', 'Hybrid', 'San Francisco, CA', 2, '2026-12-10', 'active'),
(10, 2, 8, 'Senior Technical Product Manager', 'Own product strategy, roadmap prioritization, and feature specs for cloud developer tools.', 'Gather customer feedback; Define product requirement documents (PRDs); Lead sprint planning with engineering teams.', '4+ years as Product Manager in tech/SaaS industry; Agile/Scrum expertise.', 'Product Management, Agile, PRD Creation, Roadmap Strategy, Jira', 4, 115000.00, 155000.00, 'Full Time', 'Remote', 'Austin, TX', 2, '2026-11-30', 'active'),
(11, 1, 11, 'QA Automation Engineer (Selenium & Playwright)', 'Build scalable automated E2E testing suites for web and mobile recruitment platforms.', 'Write automated test scripts in JavaScript/Python; Integrate tests into GitHub Actions CI/CD; Perform regression testing.', '2+ years of QA Automation testing experience; Proficiency with Playwright or Cypress.', 'QA Automation, Playwright, Selenium, JavaScript, CI/CD', 2, 75000.00, 100000.00, 'Full Time', 'Remote', 'San Francisco, CA', 3, '2026-12-05', 'active'),
(12, 3, 9, 'Technical Talent Acquisition Specialist', 'Source, interview, and hire top-tier software engineers, product designers, and engineering leaders.', 'Manage end-to-end recruitment lifecycle; Partner with hiring managers; Build candidate pipelines via LinkedIn Recruiter.', '2+ years tech recruiting experience in agency or fast-paced startup.', 'Technical Recruiting, Talent Sourcing, Interviewing, Applicant Tracking Systems', 2, 65000.00, 90000.00, 'Full Time', 'Hybrid', 'New York, NY', 2, '2026-12-18', 'active'),
(13, 2, 10, 'Business Intelligence & Data Analyst', 'Transform complex recruitment metrics into actionable PowerBI dashboards and executive reports.', 'Write complex SQL queries; Build interactive PowerBI / Tableau dashboards; Analyze user retention funnels.', '2+ years in Data Analytics; Advanced SQL, Excel, and PowerBI expertise.', 'SQL, PowerBI, Data Analysis, Tableau, Business Intelligence', 2, 80000.00, 105000.00, 'Full Time', 'Hybrid', 'Austin, TX', 2, '2026-11-28', 'active'),
(14, 1, 12, 'Enterprise SaaS Sales Account Executive', 'Drive B2B SaaS software sales, conduct product demonstrations, and close enterprise recruitment deals.', 'Qualify sales leads; Deliver product demos; Negotiate enterprise subscription contracts with HR leaders.', '3+ years of successful B2B SaaS quota-carrying sales experience.', 'SaaS Sales, B2B Sales, Account Management, CRM, Negotiation', 3, 85000.00, 140000.00, 'Full Time', 'On-site', 'San Francisco, CA', 2, '2026-12-15', 'active'),
(15, 2, 2, 'Go (Golang) Microservices Architect', 'Build ultra-high performance concurrency microservices and gRPC API gateways.', 'Write idiomatic Go microservices; Optimize Redis caching layers; Manage Kafka event streaming pipelines.', '3+ years experience developing backend services in Go (Golang); Knowledge of gRPC & Kafka.', 'Go, Golang, Microservices, gRPC, Redis, Kafka', 3, 110000.00, 150000.00, 'Full Time', 'Remote', 'Austin, TX', 1, '2026-12-22', 'active'),
(16, 3, 4, 'Lead Product Designer & Design Systems Lead', 'Define and scale the master design system, accessibility standards, and UI guidelines across products.', 'Create reusable Figma token libraries; Conduct user usability testing; Guide junior UI designers.', '4+ years UI/UX product design experience; Deep knowledge of Design Systems & Accessibility (WCAG).', 'Figma, Design Systems, UI/UX, Prototyping, Accessibility', 4, 95000.00, 130000.00, 'Full Time', 'Hybrid', 'New York, NY', 2, '2026-12-08', 'active'),
(17, 1, 3, 'Vue.js & Nuxt.js Frontend Engineer', 'Build modern, fast reactive web interfaces for enterprise client web applications.', 'Implement Pinia state management; Craft responsive CSS layouts; Optimize client bundle size.', '2+ years experience building web apps with Vue 3 & Nuxt.js.', 'Vue.js, Nuxt.js, JavaScript, HTML5/CSS3, REST API', 2, 75000.00, 105000.00, 'Full Time', 'Remote', 'San Francisco, CA', 2, '2026-12-12', 'active'),
(18, 2, 2, 'Python & FastAPI Backend Developer', 'Build high-throughput async Python microservices and data processing REST endpoints.', 'Write clean FastAPI endpoints; Integrate SQLAlchemy/PostgreSQL; Implement Celery background tasks.', '2+ years building backend web APIs with Python, FastAPI, or Django.', 'Python, FastAPI, PostgreSQL, AsyncIO, REST API', 2, 85000.00, 115000.00, 'Full Time', 'Hybrid', 'Austin, TX', 2, '2026-12-30', 'active'),
(19, 3, 1, 'Native iOS Swift Developer', 'Craft native iOS mobile apps using Swift, SwiftUI, and modern iOS design architecture.', 'Build intuitive iOS screens in SwiftUI; Integrate CoreData & Push Notifications; Publish apps on Apple App Store.', '3+ years native iOS development experience using Swift & Xcode.', 'Swift, SwiftUI, iOS Development, Xcode, REST API', 3, 90000.00, 125000.00, 'Full Time', 'On-site', 'New York, NY', 2, '2026-12-14', 'active'),
(20, 1, 5, 'Data Engineer & Big Data Architect', 'Design scalable data warehouses, ETL pipelines, and real-time streaming architectures.', 'Build PySpark & Airflow ETL workflows; Manage Snowflake & BigQuery warehouses; Ensure data quality.', '3+ years experience building data pipelines with Apache Spark, Airflow, and SQL.', 'Data Engineering, PySpark, Airflow, SQL, Snowflake', 3, 105000.00, 145000.00, 'Full Time', 'Remote', 'San Francisco, CA', 2, '2026-12-28', 'active'),
(21, 2, 6, 'DevSecOps & Cloud Compliance Specialist', 'Embed automated security scanning and compliance checks into Terraform cloud deployment pipelines.', 'Configure IAM roles & security policies; Automate static code analysis (SAST/DAST); Monitor cloud infrastructure.', '3+ years experience in DevSecOps, Terraform, and Cloud Security.', 'DevSecOps, Terraform, AWS Security, Docker, Compliance', 3, 105000.00, 145000.00, 'Full Time', 'Remote', 'Austin, TX', 1, '2026-12-19', 'active'),
(22, 3, 8, 'Agile Scrum Master & Agile Coach', 'Facilitate sprint ceremonies, remove team blockers, and foster continuous improvement across engineering squads.', 'Lead daily standups, sprint planning, and retrospectives; Track sprint metrics & team velocity.', '3+ years experience as Scrum Master; Certified Scrum Master (CSM) credential.', 'Scrum, Agile Coaching, Jira, Sprint Planning, Team Facilitation', 3, 80000.00, 110000.00, 'Full Time', 'Hybrid', 'New York, NY', 2, '2026-12-11', 'active'),
(23, 1, 7, 'Social Media & Content Brand Specialist', 'Create engaging digital content, manage brand social channels, and drive developer community engagement.', 'Produce tech blog articles & social posts; Manage X/Twitter & LinkedIn corporate profiles; Track brand reach metrics.', '2+ years experience in tech content creation and social media brand management.', 'Content Writing, Social Media, Copywriting, Brand Strategy', 2, 60000.00, 80000.00, 'Full Time', 'Hybrid', 'San Francisco, CA', 2, '2026-12-17', 'active'),
(24, 2, 11, 'SDET (Software Development Engineer in Test)', 'Architect end-to-end framework test infrastructure for scalable cloud APIs and databases.', 'Build automated API test suites using Postman/Jest; Conduct performance & load testing with k6; Maintain CI test scripts.', '3+ years in SDET role with strong programming skills in JavaScript or Java.', 'SDET, API Testing, Jest, Load Testing, CI/CD', 3, 90000.00, 120000.00, 'Full Time', 'Remote', 'Austin, TX', 2, '2026-12-21', 'active'),
(25, 3, 9, 'Human Resources & People Operations Manager', 'Lead employee onboarding, workplace culture initiatives, performance reviews, and team benefits.', 'Manage HR policies; Oversee annual performance appraisals; Organize team engagement events.', '3+ years in HR Operations / People Management.', 'HR Management, People Operations, Employee Relations, Benefits', 3, 75000.00, 100000.00, 'Full Time', 'On-site', 'New York, NY', 2, '2026-12-24', 'active'),
(26, 1, 10, 'Financial Analyst & Corporate Strategist', 'Build financial forecast models, track SaaS revenue metrics (ARR/MRR), and analyze budget allocation.', 'Prepare monthly financial statements; Analyze SaaS customer metrics (CAC, LTV, Churn); Present findings to executives.', '2+ years experience in Corporate Finance or Financial Planning & Analysis (FP&A).', 'Financial Modeling, SaaS Metrics, FP&A, Excel, Forecasting', 2, 80000.00, 110000.00, 'Full Time', 'Hybrid', 'San Francisco, CA', 2, '2026-12-26', 'active'),
(27, 2, 12, 'Strategic Partnerships & BD Lead', 'Identify and forge strategic distribution partnerships with enterprise technology platforms and cloud providers.', 'Build partnership pipeline; Structure co-marketing and integration deals; Negotiate contract terms.', '3+ years in Business Development or Strategic Partnerships.', 'Business Development, Strategic Partnerships, SaaS, Deal Structuring', 3, 95000.00, 135000.00, 'Full Time', 'Remote', 'Austin, TX', 2, '2026-12-29', 'active');

SELECT setval('jobs_id_seq', (SELECT MAX(id) FROM jobs));

-- 10. APPLICATIONS
INSERT INTO applications (id, job_id, seeker_id, status, cover_letter, applied_at) VALUES
(1, 1, 1, 'Interview Scheduled', 'I have over 4 years of hands-on Flutter experience and would love to bring my expertise to InnovateTech.', '2026-09-01 10:30:00+00'),
(2, 2, 2, 'Shortlisted', 'My solid foundation in Express.js and database normalization makes me an ideal fit for this role.', '2026-09-02 14:15:00+00'),
(3, 4, 3, 'Under Review', 'As a product designer passionate about clean visual systems, I am excited about Designify Studio.', '2026-09-03 09:45:00+00'),
(4, 5, 1, 'Applied', 'Interested in exploring additional team collaboration opportunities with CloudScale.', '2026-09-04 16:20:00+00');

SELECT setval('applications_id_seq', (SELECT MAX(id) FROM applications));

-- 11. SAVED_JOBS
INSERT INTO saved_jobs (seeker_id, job_id, saved_at) VALUES
(1, 2, '2026-09-01 11:00:00+00'),
(1, 4, '2026-09-02 12:30:00+00'),
(2, 1, '2026-09-03 15:10:00+00');

-- 12. INTERVIEWS
INSERT INTO interviews (id, application_id, scheduled_date, scheduled_time, interview_mode, location_or_link, interviewer_name, notes, status) VALUES
(1, 1, '2026-09-20', '14:00:00', 'Online', 'https://meet.google.com/jrms-flutter-tech', 'Sarah Jenkins (Hiring Manager)', 'Technical interview focusing on Flutter Provider state management, API architecture, and live coding.', 'Scheduled');

SELECT setval('interviews_id_seq', (SELECT MAX(id) FROM interviews));

-- 13. NOTIFICATIONS
INSERT INTO notifications (id, user_id, title, message, type, is_read) VALUES
(1, 5, 'Application Status Updated', 'Your application for Senior Flutter Architect at InnovateTech Solutions has been updated to Interview Scheduled.', 'success', FALSE),
(2, 5, 'Interview Invitation', 'You have an upcoming technical interview on Sep 20, 2026 at 2:00 PM.', 'info', FALSE),
(3, 2, 'New Job Applicant', 'Alex Rivera applied for Senior Flutter Architect.', 'info', TRUE),
(4, 6, 'Application Status Updated', 'Your application for Node.js Backend Engineer has been Shortlisted.', 'success', FALSE);

SELECT setval('notifications_id_seq', (SELECT MAX(id) FROM notifications));
