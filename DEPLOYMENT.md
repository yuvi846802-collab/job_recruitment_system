# 🚀 Job Recruitment Management System (JRMS) - Deployment Guide

This repository contains the complete fullstack source code for the **Job Recruitment Management System (JRMS)**:
- **Backend**: Node.js Express REST API (`/backend`)
- **Frontend**: Flutter Web & Mobile Application (`/frontend`)
- **Database**: PostgreSQL on Supabase Cloud (`/backend/database`)

---

## ☁️ 1. Deploy Backend API to Render (Free Cloud Hosting)

### Method A: Automatic 1-Click Blueprint (Recommended)
1. Login to [Render.com](https://dashboard.render.com).
2. Click **New +** -> **Blueprint**.
3. Connect repository: `yuvi846802-collab/job_recruitment_system`.
4. Render will read `render.yaml` and auto-configure all environment variables & settings!
5. Click **Apply**. Done! Your backend API will be live at `https://jrms-backend-api.onrender.com`.

### Method B: Manual Web Service Setup
1. Click **New +** -> **Web Service**.
2. Connect `yuvi846802-collab/job_recruitment_system`.
3. Set **Root Directory**: `backend`
4. Set **Build Command**: `npm install`
5. Set **Start Command**: `node server.js`
6. Add Environment Variables:
   - `NODE_ENV` = `production`
   - `JWT_SECRET` = `super_secret_jrms_jwt_key_2026_bca_project`
   - `DATABASE_URL` = `postgresql://postgres.cqfcmrzayvtctbqlqzlo:Manpreet%4011@aws-0-ap-south-1.pooler.supabase.com:6543/postgres?pgbouncer=true`
   - `DIRECT_URL` = `postgresql://postgres.cqfcmrzayvtctbqlqzlo:Manpreet%4011@aws-0-ap-south-1.pooler.supabase.com:5432/postgres`
   - `CLIENT_ORIGIN` = `*`

---

## 🗄️ 2. Database Setup (Supabase Cloud PostgreSQL)

The backend connects directly to Supabase PostgreSQL.
- SQL Schema: [`backend/database/pg_schema.sql`](file:///backend/database/pg_schema.sql)
- Seed Data (27 jobs, 12 categories, 7 user roles): [`backend/database/pg_seed.sql`](file:///backend/database/pg_seed.sql)

---

## 📱 3. Build Android APK File

1. Update `baseUrl` in [`frontend/lib/core/config/api_config.dart`](file:///frontend/lib/core/config/api_config.dart) to point to your live Render backend URL:
   ```dart
   return 'https://jrms-backend-api.onrender.com/api';
   ```
2. Build the Android release APK:
   ```bash
   cd frontend
   flutter build apk --release
   ```
3. Locate APK output file:
   `frontend/build/app/outputs/flutter-apk/app-release.apk`

---

## 🌐 4. Deploy Frontend Web App (Netlify / Vercel / GitHub Pages)

1. Compile Flutter Web release bundle:
   ```bash
   cd frontend
   flutter build web --release
   ```
2. Deploy the generated output directory `frontend/build/web` to **Netlify** or **Vercel**.
