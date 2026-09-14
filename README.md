# JOB RECRUITMENT MANAGEMENT SYSTEM (JRMS)
### Cross-Platform Multi-Role Recruitment Application (Mobile + Laptop + Web)

---

## 1. PROJECT OVERVIEW
The **Job Recruitment Management System (JRMS)** is an enterprise-grade recruitment platform connecting job seekers (candidates), employers (recruiters/HR), and system administrators in a unified, database-driven ecosystem.

- **Frontend**: Flutter multi-platform application (Dart, Material 3, Provider State Management, Responsive UI, Light/Dark Theme, Cross-Platform Android/Windows/Web).
- **Backend**: Node.js & Express.js RESTful API engine with JWT Auth, Role Access Control, and Multer file upload handling.
- **Database**: Cloud Supabase PostgreSQL (`aws-0-ap-south-1.pooler.supabase.com`) + MySQL DDL/DQL/TCL Academic Schemas.

---

## 2. SYSTEM ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────┐
│                   FLUTTER CLIENT APPLICATION                │
│  (Android APK / Windows Desktop / Web Chrome & Edge)        │
│  - Responsive NavigationRail & BottomNavigationBar          │
│  - Dynamic ApiConfig (Emulator 10.0.2.2 / LAN / localhost)  │
└──────────────────────────────┬──────────────────────────────┘
                               │ HTTPS / REST (JSON)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                    NODE.JS & EXPRESS BACKEND                │
│  (HOST=0.0.0.0, JWT Middleware, Role Security, Multer)      │
└──────────────────────────────┬──────────────────────────────┘
                               │ PostgreSQL Pool (pg)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                   SUPABASE POSTGRESQL DATABASE              │
│  (13 Normalized Relational Tables, FKs, Indexes, Views)     │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. CROSS-PLATFORM NETWORK CONFIGURATION (`ApiConfig`)

JRMS uses a centralized dynamic networking system in `frontend/lib/core/config/api_config.dart`:

| Environment / Platform | Base API URL | Setup Instructions |
| :--- | :--- | :--- |
| **Windows Desktop & Web** | `http://localhost:5000/api` | Automatic zero-config detection |
| **Android Emulator** | `http://10.0.2.2:5000/api` | Automatic loopback IP detection |
| **Physical Android Device (LAN)** | `http://<YOUR-PC-IP>:5000/api` | Connect phone & PC to same Wi-Fi. Enter PC IP in `ApiConfig.setCustomHost()` |
| **Production** | `https://your-api-domain.com/api` | Set production URL in environment |

---

## 4. KEY FEATURES BY ROLE

### Candidate / Job Seeker
- **Authentication**: Registration, Login, JWT session management, Password Reset.
- **Profile & Resume Manager**: Skills, education, work experience, upload/preview/replace PDF resumes.
- **Job Search & Filters**: Keyword search, category chips filter, work mode (`On-site`, `Remote`, `Hybrid`), job type (`Full Time`, `Part Time`, `Internship`, `Contract`), salary range filter.
- **Application Tracking**: Live timeline status badges (`Applied` -> `Under Review` -> `Shortlisted` -> `Interview Scheduled` -> `Selected` / `Rejected`).
- **Interview Invites**: Scheduled interview calendar with video meeting links and notes.

### Recruiter / HR
- **Company Profile Setup**: Company branding, logo uploader, industry specs, website URL.
- **Job Posting Lifecycle**: Form validation, pay range, openings count, requirement checklist, expiry date.
- **Applicant Review Board**: Filter applicant profiles, view uploaded PDF resumes, update application status (`Shortlist`, `Reject`, `Schedule Interview`).
- **Interview Scheduler**: Dynamic interview scheduling modal (Date, Time, Mode, Google Meet / Zoom link, Notes).

### System Administrator
- **Command Center**: Visual metrics for Total Candidates, Recruiters, Companies, Jobs, Applications, Interviews.
- **User Account Moderation**: Filter candidates/recruiters, toggle active/inactive account status.
- **Category CRUD**: Manage master job taxonomy categories.
- **Interactive Analytics**: Interactive `fl_chart` visualizations for job application lifecycle and category density.

---

## 5. TEST DEMO CREDS

All seeded user accounts share the default test password: **`Password@123`**

| Role | Email | Password | Quick Login Action |
| :--- | :--- | :--- | :--- |
| **Candidate** | `candidate.alex@gmail.com` | `Password@123` | Click "Candidate Demo" button on Login |
| **Recruiter** | `recruiter.tech@innovate.com` | `Password@123` | Click "Recruiter Demo" button on Login |
| **Admin** | `admin@jrms.com` | `Password@123` | Click "Admin Demo" button on Login |

---

## 6. INSTALLATION & BUILD COMMANDS

### Step 1: Start Backend Server
```bash
cd backend
npm install
node server.js
```
*Health Check*: [http://localhost:5000/api/health](http://localhost:5000/api/health)

### Step 2: Run Flutter App

#### Run on Web Chrome:
```bash
cd frontend
flutter run -d chrome --web-port 3000
```

#### Run on Windows Desktop:
```bash
cd frontend
flutter run -d windows
```

#### Build Release Artifacts:
- **Android Release APK**: `flutter build apk --release` (Output: `build/app/outputs/flutter-apk/app-release.apk`)
- **Web Release Bundle**: `flutter build web --release` (Output: `build/web/`)
