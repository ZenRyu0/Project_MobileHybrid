# Complete CI/CD Setup Guide for Go-Fit App

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Prerequisites](#prerequisites)
4. [GitHub Setup](#github-setup)
5. [Frontend Deployment (Netlify)](#frontend-deployment-netlify)
6. [Backend Deployment (Railway)](#backend-deployment-railway)
7. [Local Testing](#local-testing)
8. [Troubleshooting](#troubleshooting)

---

## Overview

This guide explains how to set up a **professional CI/CD pipeline** for your Go-Fit application. The pipeline will:

- ✅ Automatically test code when you push to GitHub
- ✅ Build your Flutter app for web
- ✅ Deploy frontend to Netlify automatically
- ✅ Deploy backend to Railway automatically
- ✅ Run linting and tests

### What is CI/CD?
- **CI (Continuous Integration)** = Automatically test code on every push
- **CD (Continuous Deployment)** = Automatically deploy when tests pass

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Your GitHub Repo                       │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────────┐
        │     GitHub Actions Workflow       │
        │  (Runs tests & builds code)       │
        └──────┬──────────────────┬────────┘
               │                  │
        ┌──────▼──────┐    ┌─────▼────────┐
        │   Netlify   │    │   Railway    │
        │  (Frontend) │    │   (Backend)  │
        └─────────────┘    └──────────────┘
```

---

## Prerequisites

Before starting, you need:

1. **GitHub Account** - Free at github.com
2. **Netlify Account** - Free at netlify.com
3. **Railway Account** - Free at railway.app
4. **PostgreSQL Database** - Free options:
   - [Neon](https://neon.tech) (recommended - easiest)
   - [Railway Postgres](https://railway.app) (integrated with Railway)
5. **Local Development Setup**:
   - Node.js 18+
   - Flutter SDK
   - Git

### Check Your Installations

**Check Node.js:**
```bash
node --version
npm --version
```

**Check Flutter:**
```bash
flutter --version
```

**Check Git:**
```bash
git --version
```

---

## GitHub Setup

### Step 1: Create a GitHub Repository

If you haven't already pushed to GitHub:

```bash
cd "c:\Michael\Coding\Mobile Hybrid\revisi\Project"
git init
git add .
git commit -m "Initial commit: Go-Fit app"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/go-fit-app.git
git push -u origin main
```

Replace `YOUR_USERNAME` with your actual GitHub username.

### Step 2: Create GitHub Secrets

GitHub Secrets store sensitive data securely. You'll add:

1. Go to your GitHub repo
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**

Add these secrets:

| Secret Name | Description | Where to Get |
|-------------|-------------|--------------|
| `RAILWAY_TOKEN` | Railway authentication token | Railway dashboard |
| `NETLIFY_AUTH_TOKEN` | Netlify authentication token | Netlify account settings |
| `NETLIFY_SITE_ID` | Your Netlify site ID | Netlify site settings |

### Step 3: Add Workflow Files

These files are already created in:
- `.github/workflows/backend-ci-cd.yml` - Backend CI/CD
- `.github/workflows/frontend-ci-cd.yml` - Frontend CI/CD

They will automatically run when you push to GitHub.

---

## Frontend Deployment (Netlify)

### Step 1: Create a Netlify Account

1. Go to [netlify.com](https://netlify.com)
2. Sign up (free)

### Step 2: Create a New Site

1. Click **Add new site** → **Import an existing project**
2. Select **GitHub** as your Git provider
3. Authorize Netlify to access your GitHub
4. Select your `go-fit-app` repository
5. Fill in build settings:
   - **Base directory**: `Project_MobileHybrid-main`
   - **Build command**: `flutter build web --release`
   - **Publish directory**: `build/web`

### Step 3: Get Your Netlify Credentials

1. Go to your site settings
2. Find **Site ID** - copy it
3. Go to Account settings → **API tokens**
4. Create a new token (keep it secret!)

### Step 4: Add Secrets to GitHub

In your GitHub repo settings, add:
- `NETLIFY_AUTH_TOKEN` = Your Netlify API token
- `NETLIFY_SITE_ID` = Your Site ID

### Step 5: Deploy

Push code to GitHub:
```bash
git push origin main
```

Netlify will automatically:
1. Build your Flutter app
2. Deploy to production
3. Give you a live URL

**Your site will be live at:** `https://your-site-name.netlify.app`

---

## Backend Deployment (Railway)

### Step 1: Create a Railway Account

1. Go to [railway.app](https://railway.app)
2. Sign up with GitHub (easiest)

### Step 2: Create a New Project

1. Click **New Project**
2. Select **Deploy from GitHub repo**
3. Select your `go-fit-app` repository
4. Select `Project_MobileHybrid-backend` directory

### Step 3: Configure Environment Variables

In Railway dashboard:
1. Go to your project
2. Click **Variables**
3. Add these variables:

```
NODE_ENV=production
PORT=3000
JWT_SECRET=your-super-secret-key-change-this
DATABASE_URL=postgresql://user:password@neon-project.neon.tech/go-fit
FRONTEND_URL=https://your-netlify-site.netlify.app
```

### Step 4: Get Your Railway Token

1. Go to your Railway account settings
2. Click **Tokens**
3. Create a new token (keep it secret!)

### Step 5: Add Secret to GitHub

In your GitHub repo settings, add:
- `RAILWAY_TOKEN` = Your Railway token

### Step 6: Deploy

Push code to GitHub:
```bash
git push origin main
```

Railway will automatically:
1. Build your NestJS app
2. Run `npm run start:prod`
3. Deploy to production
4. Give you a live URL

**Your API will be live at:** `https://your-railway-project.up.railway.app`

### Step 7: Update Frontend API URL

Once backend is deployed, update your frontend to use the production URL:

In `Project_MobileHybrid-main/lib/services/workout_service.dart`:

```dart
// Change this:
static const String baseUrl = 'http://localhost:3000';

// To this:
static const String baseUrl = 'https://your-railway-project.up.railway.app';
```

Do the same for all other services (auth, user, calorie, post).

---

## Local Testing

Before pushing to GitHub, test everything locally:

### Test Backend

```bash
cd "Project_MobileHybrid-backend"

# Install dependencies
npm install

# Run linter (checks code quality)
npm run lint

# Run tests
npm run test

# Run the app locally
npm run start:dev
```

The backend runs on `http://localhost:3000`

### Test Frontend

```bash
cd "Project_MobileHybrid-main"

# Get dependencies
flutter pub get

# Run analysis (checks for errors)
flutter analyze

# Run tests
flutter test

# Run the app locally
flutter run -d chrome
```

The app runs on `http://localhost:7357`

### Full Local Test

```bash
# In one terminal, start backend
cd Project_MobileHybrid-backend
npm run start:dev

# In another terminal, start frontend
cd Project_MobileHybrid-main
flutter run -d chrome
```

Now you can test the full app locally before deploying!

---

## Understanding the Workflow Files

### Backend Workflow (`.github/workflows/backend-ci-cd.yml`)

**What it does on every push:**

1. **Checkout** - Gets your latest code
2. **Setup Node.js** - Prepares the environment
3. **Install Dependencies** - Runs `npm install`
4. **Lint** - Checks code quality with ESLint
5. **Build** - Runs `npm run build`
6. **Test** - Runs `npm run test`
7. **Deploy to Railway** - Only if all above pass AND on main branch

**If any step fails, deployment stops.**

### Frontend Workflow (`.github/workflows/frontend-ci-cd.yml`)

**What it does on every push:**

1. **Checkout** - Gets your latest code
2. **Setup Flutter** - Prepares Flutter SDK
3. **Get Dependencies** - Runs `flutter pub get`
4. **Analyze** - Checks for errors
5. **Run Tests** - Runs `flutter test`
6. **Build Web** - Runs `flutter build web --release`
7. **Deploy to Netlify** - Only if all above pass AND on main branch

---

## Making Your First Deployment

### Step 1: Push to GitHub

```bash
cd "c:\Michael\Coding\Mobile Hybrid\revisi\Project"

# Make sure everything is committed
git add .
git commit -m "Setup: CI/CD pipeline"
git push origin main
```

### Step 2: Watch GitHub Actions

1. Go to your GitHub repo
2. Click **Actions** tab
3. You'll see your workflows running
4. Click on them to see detailed logs

### Step 3: Check Deployments

- **Frontend**: Go to your Netlify site
- **Backend**: Go to your Railway project

Both should show green checkmarks = deployed successfully!

---

## Environment Variables Explained

### Backend Variables (`.env`)

```env
# How your app knows it's in production
NODE_ENV=production

# What port the server runs on
PORT=3000

# Secret key for JWT tokens (like a password for tokens)
JWT_SECRET=super-secret-key-that-nobody-guesses

# URL to your MongoDB database
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/go-fit

# Your frontend URL (for CORS - allowing requests from your app)
FRONTEND_URL=https://your-netlify-site.netlify.app
```

### Frontend Variables (`.env`)

```env
# API server address
API_BASE_URL=https://your-railway-backend.up.railway.app

# How many milliseconds to wait before timing out
API_TIMEOUT=30000
```

---

## Troubleshooting

### GitHub Actions: Build Failing

**Check logs:**
1. Go to GitHub repo → **Actions**
2. Click failing workflow
3. Click the failed step
4. Read the error message

**Common issues:**

| Error | Solution |
|-------|----------|
| `npm ERR! 404 Not Found` | Package not found. Run `npm install` locally first |
| `dart: command not found` | Flutter not installed on GitHub runner (it is, but might be wrong version) |
| `ENOENT: no such file` | Path is wrong. Check `working-directory` in workflow |

### Netlify: Build Failing

**Check build log:**
1. Go to Netlify → Your site
2. Click **Deploys**
3. Click the failed deploy
4. Scroll to see error

**Common issues:**

| Error | Solution |
|-------|----------|
| `Flutter command not found` | Add `flutter` to `PATH` in build environment |
| `Cannot find module` | Run `flutter pub get` in build command |

### Railway: Build Failing

**Check deployment log:**
1. Go to Railway → Your project
2. Click **Deployments**
3. Click the failed deployment
4. See the error log

**Common issues:**

| Error | Solution |
|-------|----------|
| `Cannot find package` | Check `package.json` dependencies |
| `Port already in use` | Use PORT from environment variable |
| `MODULE_NOT_FOUND` | Run `npm install` and commit `package-lock.json` |

### App Not Working After Deploy

**Check API URL:**
1. Frontend can't connect to backend
2. Update API URL in all services
3. Check that backend is actually running on Railway
4. Check CORS settings in backend

**Test connection:**
```bash
# From your terminal, test if backend is up
curl https://your-railway-backend.up.railway.app/workouts/plans
```

If you get a response, backend is working!

---

## Database Setup (PostgreSQL)

### Step 1: Choose a PostgreSQL Provider

**Option A: Neon (Recommended - Easiest)**
1. Go to [neon.tech](https://neon.tech)
2. Sign up (free)
3. Create a new project
4. Select region
5. Copy your connection string

**Option B: Railway Postgres (Integrated)**
1. Go to [railway.app](https://railway.app)
2. Create a new project
3. Add PostgreSQL service
4. Copy connection string from variables

### Step 2: Get Your Connection String

It will look like:
```
postgresql://user:password@neon-project.neon.tech/go-fit?sslmode=require
```

### Step 3: Add to Railway

1. Go to your Railway project
2. Go to Variables section
3. Add variable: `DATABASE_URL` = your connection string
4. Deploy

Note: Railway will automatically detect PostgreSQL connection strings and set up the database for you.

---

## Next Steps

After everything is deployed:

1. ✅ Test the live app at your Netlify URL
2. ✅ Test API calls to your Railway backend
3. ✅ Create sample data
4. ✅ Add more features
5. ✅ Keep pushing to GitHub - everything deploys automatically!

---

## Quick Reference

### Commands You'll Use Often

```bash
# Push code (triggers CI/CD)
git push origin main

# Check frontend locally
flutter run -d chrome

# Check backend locally
npm run start:dev

# Build frontend for production
flutter build web --release

# Build backend for production
npm run build
```

### Important URLs to Remember

- GitHub Repo: `https://github.com/YOUR_USERNAME/go-fit-app`
- Netlify Site: `https://your-site-name.netlify.app`
- Railway Backend: `https://your-project-name.up.railway.app`
- MongoDB Atlas: `https://cloud.mongodb.com`

---

## Support

If something doesn't work:

1. **Check the error logs** - GitHub Actions, Netlify, Railway all show detailed logs
2. **Check this guide** - Troubleshooting section has common issues
3. **Read the error carefully** - Most errors tell you exactly what's wrong
4. **Ask for help** - Copy the full error and ask

---

**Congratulations! 🎉 You now have professional CI/CD set up!**

Every time you push code to GitHub, your app automatically tests and deploys. Welcome to modern development! 🚀
