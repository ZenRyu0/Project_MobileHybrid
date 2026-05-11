# CI/CD Setup Checklist

Follow this checklist to get everything set up. Check off each item as you complete it.

---

## Phase 1: GitHub Setup

- [ ] **Create GitHub Repository**
  - Command: See CI_CD_SETUP_GUIDE.md Step 1
  - Verify: Can you see your code on github.com?

- [ ] **Create GitHub Secrets**
  - Go to: Repo Settings → Secrets and variables → Actions
  - Add: `RAILWAY_TOKEN` (get from Railway)
  - Add: `NETLIFY_AUTH_TOKEN` (get from Netlify)
  - Add: `NETLIFY_SITE_ID` (get from Netlify)

- [ ] **Verify Workflow Files Exist**
  - File 1: `.github/workflows/backend-ci-cd.yml` ✓
  - File 2: `.github/workflows/frontend-ci-cd.yml` ✓

---

## Phase 2: Netlify Setup (Frontend)

- [ ] **Create Netlify Account**
  - Go to: netlify.com
  - Sign up (free)

- [ ] **Create New Site from Git**
  - Click: "Add new site" → "Import an existing project"
  - Select: GitHub
  - Authorize: Netlify to access GitHub
  - Choose: Your go-fit-app repo

- [ ] **Configure Build Settings**
  - Base directory: `Project_MobileHybrid-main`
  - Build command: `flutter build web --release`
  - Publish directory: `build/web`

- [ ] **Get Netlify Credentials**
  - Site ID: Copy from site settings
  - API Token: Create from account settings

- [ ] **Add Netlify Secrets to GitHub**
  - Secret: `NETLIFY_AUTH_TOKEN`
  - Secret: `NETLIFY_SITE_ID`

- [ ] **Make First Commit**
  - Command: `git push origin main`
  - Watch: GitHub Actions → Workflows
  - Verify: Netlify shows green checkmark

---

## Phase 3: Railway Setup (Backend)

- [ ] **Create Railway Account**
  - Go to: railway.app
  - Sign up (use GitHub - easiest)

- [ ] **Create New Project**
  - Click: "New Project"
  - Select: "Deploy from GitHub repo"
  - Choose: Your go-fit-app repo
  - Select: `Project_MobileHybrid-backend` directory

- [ ] **Add Environment Variables**
  - `NODE_ENV` = `production`
  - `PORT` = `3000`
  - `JWT_SECRET` = (create a strong secret)
  - `FRONTEND_URL` = (your Netlify URL when ready)

- [ ] **Get Railway Token**
  - Go to: Railway account settings
  - Click: Tokens
  - Create: New token

- [ ] **Add Railway Secret to GitHub**
  - Secret: `RAILWAY_TOKEN` = your Railway token

- [ ] **Make Another Commit**
  - Command: `git push origin main`
  - Watch: GitHub Actions
  - Verify: Railway shows deployment success

---

## Phase 4: PostgreSQL Setup (Database)

- [ ] **Choose PostgreSQL Provider**
  - Option A (Recommended): Go to https://neon.tech and sign up
  - Option B: Use Railway Postgres at https://railway.app

- [ ] **Create Database Project**
  - Click: "Create project" or "New project"
  - Select: Region near you
  - Click: Create

- [ ] **Get Connection String**
  - Copy: Connection string from dashboard
  - Format: `postgresql://user:password@host/database`
  - Keep: Safe (don't share!)

- [ ] **Add PostgreSQL to Railway**
  - Go to: Railway project
  - Add Variable: `DATABASE_URL` = your connection string
  - Deploy

---

## Phase 5: Update Frontend API URL

- [ ] **Update All Services**
  - File: `Project_MobileHybrid-main/lib/services/auth_service.dart`
    - Change: `static const String baseUrl = 'http://localhost:3000';`
    - To: `static const String baseUrl = 'https://your-railway-url';`
  
  - File: `Project_MobileHybrid-main/lib/services/workout_service.dart`
    - Change: `static const String baseUrl = 'http://localhost:3000';`
    - To: `static const String baseUrl = 'https://your-railway-url';`
  
  - File: `Project_MobileHybrid-main/lib/services/calorie_service.dart`
    - Change: `static const String baseUrl = 'http://localhost:3000';`
    - To: `static const String baseUrl = 'https://your-railway-url';`
  
  - File: `Project_MobileHybrid-main/lib/services/post_service.dart`
    - Change: `static const String baseUrl = 'http://localhost:3000';`
    - To: `static const String baseUrl = 'https://your-railway-url';`
  
  - File: `Project_MobileHybrid-main/lib/services/user_service.dart`
    - Change: `static const String baseUrl = 'http://localhost:3000';`
    - To: `static const String baseUrl = 'https://your-railway-url';`

- [ ] **Commit Changes**
  - Command: `git add .`
  - Command: `git commit -m "Update API URLs for production"`
  - Command: `git push origin main`

---

## Phase 6: Testing

- [ ] **Test Backend Locally**
  - Command: `cd Project_MobileHybrid-backend`
  - Command: `npm install`
  - Command: `npm run start:dev`
  - Verify: Server runs on `http://localhost:3000`
  - Test: Open `http://localhost:3000/workouts/plans` in browser

- [ ] **Test Frontend Locally**
  - Command: `cd Project_MobileHybrid-main`
  - Command: `flutter pub get`
  - Command: `flutter run -d chrome`
  - Verify: App opens in Chrome
  - Test: Try login with `test@example.com` / `password123`

- [ ] **Test Live Frontend**
  - URL: Go to your Netlify site
  - Verify: App loads
  - Test: Try features

- [ ] **Test Live Backend**
  - Command: `curl https://your-railway-url/workouts/plans`
  - Verify: Get JSON response

---

## Phase 7: Final Verification

- [ ] **GitHub Shows Green Checkmarks**
  - Go to: GitHub repo → Actions
  - Verify: All recent workflows show ✅

- [ ] **Netlify Shows Green**
  - Go to: Netlify dashboard
  - Verify: "Published" status

- [ ] **Railway Shows Green**
  - Go to: Railway dashboard
  - Verify: "Live" status

- [ ] **App Works End-to-End**
  - Open: Your Netlify site
  - Try: Register new user
  - Try: Log workout
  - Try: Log calories
  - Verify: Data shows up

---

## Troubleshooting Checklist

If something doesn't work:

- [ ] **GitHub Actions Failed?**
  - Check: Actions tab → Failed workflow
  - Read: Error message carefully
  - Look: For similar issue in CI_CD_SETUP_GUIDE.md Troubleshooting

- [ ] **Netlify Build Failed?**
  - Check: Netlify → Deploys → Failed deploy
  - Read: Build log from bottom up
  - Verify: Flutter is installed on Netlify

- [ ] **Railway Build Failed?**
  - Check: Railway → Deployments → Failed deployment
  - Read: Deployment log
  - Verify: All environment variables are set

- [ ] **App Not Working?**
  - Check: API URL is correct in frontend services
  - Test: `curl your-railway-url/workouts/plans`
  - Verify: Backend is actually running

- [ ] **Data Not Saving?**
  - Check: MongoDB connection string is correct
  - Test: Can you connect to MongoDB Atlas?
  - Verify: `MONGODB_URI` environment variable is set

---

## Success! 🎉

If all checkboxes are checked, congratulations! You have:

✅ Professional CI/CD pipeline
✅ Automated testing on every push
✅ Automatic deployments to production
✅ Professional workflow
✅ Production-ready app

**From now on:**
- Just push to GitHub: `git push origin main`
- Everything tests and deploys automatically
- No more manual deployment steps needed!

---

## Need Help?

1. Check the CI_CD_SETUP_GUIDE.md for detailed instructions
2. Check GitHub Actions logs for exact error messages
3. Check Netlify/Railway deployment logs
4. Re-read the relevant section in this checklist
