# Verification Checklist - CI/CD Installation

Use this to verify everything was installed correctly.

---

## ✅ Verify Files Exist

### GitHub Actions Workflows
- [ ] File exists: `.github/workflows/backend-ci-cd.yml`
  - Contains: Backend build, test, and Railway deployment
  
- [ ] File exists: `.github/workflows/frontend-ci-cd.yml`
  - Contains: Frontend build, test, and Netlify deployment

### Configuration Files
- [ ] File exists: `Project_MobileHybrid-backend/railway.json`
  - Contains: Railway build & deploy instructions
  
- [ ] File exists: `Project_MobileHybrid-main/netlify.toml`
  - Contains: Netlify build & deploy instructions

### Documentation Files
- [ ] File exists: `CI_CD_SETUP_GUIDE.md`
- [ ] File exists: `CI_CD_CHECKLIST.md`
- [ ] File exists: `QUICK_REFERENCE.md`
- [ ] File exists: `CI_CD_FILES_SUMMARY.md`
- [ ] File exists: `CI_CD_VERIFICATION.md` (this file)

---

## ✅ Verify File Contents

### Backend Workflow (`backend-ci-cd.yml`)

Check that it contains:
- [ ] `name: Backend CI/CD (NestJS)`
- [ ] `npm ci` (installs dependencies)
- [ ] `npm run lint` (code quality check)
- [ ] `npm run build` (builds the app)
- [ ] `npm run test` (runs tests)
- [ ] `railway up` (deploys to Railway)

### Frontend Workflow (`frontend-ci-cd.yml`)

Check that it contains:
- [ ] `name: Frontend CI/CD (Flutter Web)`
- [ ] `flutter pub get` (gets dependencies)
- [ ] `flutter analyze` (checks for errors)
- [ ] `flutter test` (runs tests)
- [ ] `flutter build web --release` (builds for web)
- [ ] Netlify deployment step

### Railway Config (`railway.json`)

Check that it contains:
- [ ] `npm run build` as build command
- [ ] `npm run start:prod` as start command
- [ ] Port 3000
- [ ] Production environment

### Netlify Config (`netlify.toml`)

Check that it contains:
- [ ] `publish = "build/web"`
- [ ] `flutter build web --release` as build command
- [ ] Base directory: `Project_MobileHybrid-main`

---

## ✅ Verify GitHub Repo Structure

From your repo root, run:

```bash
# Check if .github directory exists
ls -la .github/
# Should show: workflows/

# Check workflows exist
ls -la .github/workflows/
# Should show:
#   backend-ci-cd.yml
#   frontend-ci-cd.yml

# Check backend config
ls -la Project_MobileHybrid-backend/railway.json

# Check frontend config
ls -la Project_MobileHybrid-main/netlify.toml
```

---

## ✅ Verify Environment Files

### Backend

- [ ] `.env.example` exists in `Project_MobileHybrid-backend/`
- [ ] Contains: `NODE_ENV`, `PORT`, `JWT_SECRET`, `DATABASE_URL`, etc.
- [ ] Has comments explaining each variable

### Frontend

- [ ] `.env.example` exists in `Project_MobileHybrid-main/`
- [ ] Contains: `API_BASE_URL`, `API_TIMEOUT`, etc.

---

## ✅ Pre-Deployment Verification

Before your first deployment, verify:

### Local Backend Setup
```bash
cd Project_MobileHybrid-backend

# Verify dependencies can be installed
npm install

# Verify it builds
npm run build

# Verify tests run
npm run test

# Verify it can start
npm run start:prod
```

### Local Frontend Setup
```bash
cd Project_MobileHybrid-main

# Verify dependencies can be installed
flutter pub get

# Verify it analyzes
flutter analyze

# Verify it can build
flutter build web --release
```

---

## ✅ GitHub Repository Setup

- [ ] Repository is public or has GitHub Actions enabled
- [ ] You have write access to the repository
- [ ] `main` branch is the default branch
- [ ] Files are committed and pushed to GitHub

### Verify via GitHub Web

1. Go to https://github.com/YOUR_USERNAME/go-fit-app
2. [ ] Can you see `.github/workflows/` folder?
3. [ ] Can you see `backend-ci-cd.yml` file?
4. [ ] Can you see `frontend-ci-cd.yml` file?
5. [ ] Can you see the project files?

---

## ✅ Accounts Created & Connected

- [ ] **GitHub** - Repository created
- [ ] **Netlify** - Account created
- [ ] **Railway** - Account created
- [ ] **PostgreSQL** - Account created (Neon or Railway Postgres recommended)

---

## ✅ GitHub Secrets Added

Go to: GitHub Repo → Settings → Secrets and variables → Actions

Verify these exist:
- [ ] `RAILWAY_TOKEN` - Check it's not empty
- [ ] `NETLIFY_AUTH_TOKEN` - Check it's not empty
- [ ] `NETLIFY_SITE_ID` - Check it's not empty

**How to verify:**
1. Go to your repo on GitHub
2. Click Settings
3. Left sidebar: "Secrets and variables"
4. Click "Actions"
5. You should see 3 secrets listed

---

## ✅ Make Your First Commit

```bash
# Add all files
git add .

# Commit
git commit -m "Setup: Complete CI/CD pipeline"

# Push to GitHub
git push origin main
```

### After First Push

1. Go to GitHub: https://github.com/YOUR_USERNAME/go-fit-app
2. Click **Actions** tab
3. [ ] You should see workflows running
4. [ ] Backend workflow should show (blue circle = running, green check = passed)
5. [ ] Frontend workflow should show (blue circle = running, green check = passed)

**Wait for them to complete** (usually 5-10 minutes)

---

## ✅ Verify Workflow Execution

### On GitHub

1. Go to your repo → **Actions** tab
2. [ ] See "Backend CI/CD (NestJS)" - should show status
3. [ ] See "Frontend CI/CD (Flutter Web)" - should show status
4. Click on each one to see detailed logs

### Backend Workflow Steps

Click the backend workflow and verify these steps completed:
- [ ] ✅ Checkout code
- [ ] ✅ Setup Node.js
- [ ] ✅ Install dependencies
- [ ] ✅ Run linter
- [ ] ✅ Build application
- [ ] ✅ Run tests
- [ ] ⏳ Deploy to Railway (will fail if Railway not set up yet)

### Frontend Workflow Steps

Click the frontend workflow and verify these steps completed:
- [ ] ✅ Checkout code
- [ ] ✅ Setup Flutter
- [ ] ✅ Get dependencies
- [ ] ✅ Analyze code
- [ ] ✅ Run tests
- [ ] ✅ Build web
- [ ] ⏳ Deploy to Netlify (will fail if Netlify not set up yet)

---

## ✅ Set Up Netlify

After first push:

1. Go to https://app.netlify.com
2. [ ] Click "Add new site" or "Import an existing project"
3. [ ] Select GitHub as provider
4. [ ] Find your go-fit-app repository
5. [ ] Configure build settings:
   - [ ] Base directory: `Project_MobileHybrid-main`
   - [ ] Build command: `flutter build web --release`
   - [ ] Publish directory: `build/web`
6. [ ] Click Deploy
7. [ ] Get your Site ID from site settings
8. [ ] Generate API token from account settings
9. [ ] Add to GitHub Secrets: `NETLIFY_AUTH_TOKEN` and `NETLIFY_SITE_ID`

---

## ✅ Set Up Railway

After Netlify setup:

1. Go to https://railway.app
2. [ ] Create new project
3. [ ] Deploy from GitHub repo
4. [ ] Select go-fit-app repository
5. [ ] Select Project_MobileHybrid-backend directory
6. [ ] Add environment variables:
   - [ ] NODE_ENV=production
   - [ ] PORT=3000
   - [ ] JWT_SECRET=your-secret-key
7. [ ] Get your Railway token from account settings
8. [ ] Add to GitHub Secrets: `RAILWAY_TOKEN`
9. [ ] Wait for first deployment

---

## ✅ Verify Live Deployment

After everything is set up:

### Test Frontend
- [ ] Go to your Netlify URL
- [ ] App loads without errors
- [ ] You can see the login page
- [ ] UI looks correct

### Test Backend
- [ ] Open terminal
- [ ] Run: `curl https://your-railway-url.up.railway.app/workouts/plans`
- [ ] You should get a JSON response
- [ ] No errors in the response

### Test End-to-End
- [ ] Go to your Netlify URL
- [ ] Try to log in
- [ ] Try to register (if backend allows)
- [ ] Check Network tab (F12) for API calls
- [ ] Verify requests go to Railway URL, not localhost

---

## ✅ Troubleshooting Checklist

If something doesn't work:

### Workflows Don't Run
- [ ] Check files exist: `.github/workflows/*.yml`
- [ ] Check they're committed and pushed to main
- [ ] Go to GitHub → Actions → Check for errors
- [ ] Make sure workflows have proper YAML syntax

### Build Fails
- [ ] Read the error in GitHub Actions logs
- [ ] Check locally: `npm run build` or `flutter build web --release`
- [ ] Make sure all dependencies are installed locally
- [ ] Check for missing files referenced in code

### Deploy Fails
- [ ] Check GitHub Secrets are set correctly
- [ ] Verify RAILWAY_TOKEN is valid
- [ ] Verify NETLIFY_AUTH_TOKEN is valid
- [ ] Verify NETLIFY_SITE_ID is valid

### App Works Locally But Not Live
- [ ] Check API URL in frontend (should be Railway URL, not localhost)
- [ ] Verify Railway backend is running
- [ ] Check CORS settings in backend
- [ ] Verify database connection string in Railway (DATABASE_URL)

---

## ✅ Final Verification Checklist

Complete this checklist to confirm everything is working:

- [ ] GitHub repo has all files
- [ ] Workflows exist in `.github/workflows/`
- [ ] Configuration files exist (netlify.toml, railway.json)
- [ ] Documentation files exist
- [ ] GitHub Secrets are added (3 secrets)
- [ ] Netlify is connected
- [ ] Railway is connected
- [ ] First commit pushed successfully
- [ ] GitHub Actions workflows completed (mostly)
- [ ] Netlify shows deployment status
- [ ] Railway shows deployment status
- [ ] Frontend loads at Netlify URL
- [ ] Backend responds at Railway URL
- [ ] End-to-end test works (frontend talks to backend)

---

## 🎉 Success!

If all checkboxes are ✅, your CI/CD is properly set up!

From now on:
1. Make code changes
2. Push to GitHub: `git push origin main`
3. GitHub Actions automatically tests & builds
4. Automatic deployment to Netlify & Railway
5. Your app goes live automatically! 🚀

---

## 📞 Need Help?

If something isn't working:

1. **Check the error** - Read GitHub Actions logs
2. **Consult CI_CD_SETUP_GUIDE.md** - Has troubleshooting section
3. **Check QUICK_REFERENCE.md** - Has debugging tips
4. **Verify steps** - Use CI_CD_CHECKLIST.md to retrace

**Most issues are simple** - Check error messages carefully, they usually tell you exactly what's wrong!
