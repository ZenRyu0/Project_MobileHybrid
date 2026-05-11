# Quick Reference: Commands & URLs

## 📋 Common Commands

### Git Commands
```bash
# Check git status
git status

# Add all changes
git add .

# Create a commit
git commit -m "Your message here"

# Push to GitHub (triggers CI/CD)
git push origin main

# Pull latest changes
git pull origin main

# View commit history
git log --oneline
```

### Backend Commands
```bash
# Navigate to backend
cd Project_MobileHybrid-backend

# Install dependencies
npm install

# Start backend in development mode
npm run start:dev

# Start backend in production mode
npm run start:prod

# Build for production
npm run build

# Run tests
npm run test

# Run linter (check code quality)
npm run lint

# Format code
npm run format
```

### Frontend Commands
```bash
# Navigate to frontend
cd Project_MobileHybrid-main

# Get dependencies
flutter pub get

# Run app on Chrome
flutter run -d chrome

# Build for web (release mode)
flutter build web --release

# Run tests
flutter test

# Analyze code for errors
flutter analyze

# Clean build
flutter clean
```

### Docker Commands (if using Docker)
```bash
# Build Docker image
docker build -t go-fit-backend .

# Run Docker container
docker run -p 3000:3000 go-fit-backend

# Check running containers
docker ps
```

---

## 🌐 Important URLs

### Local Development
```
Frontend: http://localhost:7357 (or http://localhost:3000)
Backend: http://localhost:3000
```

### Production URLs (After Deployment)
```
Frontend: https://your-site-name.netlify.app
Backend: https://your-project-name.up.railway.app
Database: postgresql://user:password@host/database
```

### Service Dashboards
```
GitHub: https://github.com/YOUR_USERNAME/go-fit-app
Netlify: https://app.netlify.com
Railway: https://railway.app
PostgreSQL: https://neon.tech (Recommended)
PostgreSQL Alt: https://railway.app (Railway Postgres)
```

---

## 🔐 GitHub Secrets You Need

| Secret Name | Example Value | Where to Get |
|-------------|---------------|--------------|
| `RAILWAY_TOKEN` | `rly_abcd1234...` | Railway account settings → Tokens |
| `NETLIFY_AUTH_TOKEN` | `nfl_abcd1234...` | Netlify account settings → API tokens |
| `NETLIFY_SITE_ID` | `abc123def456...` | Netlify site settings → Site ID |

---

## 📁 Important File Locations

### GitHub Actions Workflows
```
.github/workflows/backend-ci-cd.yml    ← Backend CI/CD
.github/workflows/frontend-ci-cd.yml   ← Frontend CI/CD
```

### Configuration Files
```
Project_MobileHybrid-backend/railway.json      ← Railway config
Project_MobileHybrid-main/netlify.toml         ← Netlify config
Project_MobileHybrid-backend/.env.example      ← Backend env template
Project_MobileHybrid-main/.env.example         ← Frontend env template
```

### Main App Files
```
Project_MobileHybrid-backend/src/main.ts       ← Backend entry
Project_MobileHybrid-main/lib/main.dart        ← Frontend entry
```

---

## 🧪 Testing Checklist

### Before Pushing to GitHub

**Backend:**
```bash
npm run lint      # Check code quality
npm run test      # Run tests
npm run build     # Make sure it builds
```

**Frontend:**
```bash
flutter analyze   # Check for errors
flutter test      # Run tests
flutter build web --release  # Build for web
```

### After Pushing to GitHub

1. Check: GitHub Actions → Workflows show green ✅
2. Check: Netlify Dashboard shows "Published"
3. Check: Railway Dashboard shows "Live"

---

## 🐛 Quick Debugging

### "Build Failed on GitHub"
```
1. Go to GitHub → Actions → Failed workflow
2. Click the failed step
3. Read the error message
4. Look it up in CI_CD_SETUP_GUIDE.md Troubleshooting
```

### "Frontend not connecting to backend"
```
1. Check API URL in services (should be Railway URL)
2. Test: curl https://your-railway-url/workouts/plans
3. Verify backend is running on Railway
4. Check CORS settings in backend
```

### "Database not persisting data"
```
1. Verify MONGODB_URI is set in Railway
2. Check MongoDB Atlas cluster is active
3. Verify database name in connection string
4. Test MongoDB connection locally
```

### "Local app not working"
```
Backend:
- npm run start:dev
- npm run build

Frontend:
- flutter pub get
- flutter run -d chrome
```

---

## 📊 Status Check Commands

### Check if Backend is Running
```bash
# On Windows PowerShell
curl http://localhost:3000/workouts/plans

# On Mac/Linux
curl http://localhost:3000/workouts/plans
```

### Check if Frontend Builds
```bash
cd Project_MobileHybrid-main
flutter build web --release
```

### Check Git Status
```bash
git status
```

---

## 🚀 Deploy Steps

### Quick Deployment Process

```bash
# 1. Make changes to your code
# 2. Test locally
npm run test          # Backend
flutter test          # Frontend

# 3. Commit changes
git add .
git commit -m "Your meaningful message"

# 4. Push to GitHub
git push origin main

# 5. Watch GitHub Actions
# GitHub → Actions tab → Watch workflow

# 6. Verify deployment
# Netlify: Check Deploys
# Railway: Check Deployments

# Done! 🎉 Your app is live!
```

---

## 📝 Environment Variables Reference

### Backend (.env)
```
NODE_ENV=production
PORT=3000
JWT_SECRET=your-secret-key
DATABASE_URL=postgresql://user:password@host/go-fit
FRONTEND_URL=https://your-netlify-site.netlify.app
```

### Frontend (.env)
```
API_BASE_URL=https://your-railway-backend.up.railway.app
DEBUG_MODE=false
```

---

## 💡 Pro Tips

1. **Always test locally first** before pushing
2. **Write meaningful commit messages** for tracking changes
3. **Check GitHub Actions logs** if deployment fails
4. **Keep `.env` files local** - never commit them
5. **Use small commits** instead of big ones
6. **Pull latest changes** before starting work
7. **Review errors carefully** - they tell you exactly what's wrong

---

## 🎓 Learning Resources

- Git: https://git-scm.com/doc
- Flutter: https://flutter.dev/docs
- NestJS: https://docs.nestjs.com
- PostgreSQL: https://www.postgresql.org/docs
- GitHub Actions: https://docs.github.com/en/actions

---

## ✅ Your CI/CD Is Ready When

- ✅ GitHub repo is created and synced
- ✅ All GitHub Secrets are added
- ✅ Netlify site is connected
- ✅ Railway project is set up
- ✅ MongoDB is connected
- ✅ First push to main succeeds
- ✅ App deploys automatically
- ✅ Live app works end-to-end

**Congratulations! You're now using professional deployment practices! 🚀**
