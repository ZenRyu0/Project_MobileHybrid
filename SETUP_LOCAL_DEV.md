# Local Development Setup Guide

## Prerequisites
- Node.js 18+
- Flutter SDK
- PostgreSQL 13+ OR Docker
- Git

---

## Backend Setup (NestJS)

### 1. Database Setup (Choose One)

#### Using Docker (Easiest)
```bash
docker run -d \
  --name gofit-postgres \
  -e POSTGRES_PASSWORD=devpass123 \
  -e POSTGRES_DB=gofit_dev \
  -p 5432:5432 \
  postgres:15

# Wait 10 seconds for startup
```

#### Using Local PostgreSQL
```bash
# Windows: Use PostgreSQL installer from https://www.postgresql.org/download/windows/
# macOS: brew install postgresql@15
# Linux: sudo apt install postgresql

# Create database:
psql -U postgres -c "CREATE DATABASE gofit_dev;"
```

### 2. Configure Backend

```bash
cd Project_MobileHybrid-backend

# Update .env with local database:
# DATABASE_URL="postgresql://postgres:devpass123@localhost:5432/gofit_dev"
# DIRECT_URL="postgresql://postgres:devpass123@localhost:5432/gofit_dev"

# Install dependencies
npm install

# Run migrations
npx prisma migrate deploy

# Or generate Prisma Client fresh
npx prisma generate
```

### 3. Start Backend

```bash
cd Project_MobileHybrid-backend
npm start
# Server runs on http://localhost:3000
```

---

## Frontend Setup (Flutter)

### 1. Install Dependencies
```bash
cd Project_MobileHybrid-main
flutter pub get
```

### 2. Run on Emulator/Device
```bash
# List available devices
flutter devices

# Run app
flutter run

# Or specify device
flutter run -d <device_id>
```

### 3. Enable Hot Reload
- Press `r` to reload
- Press `R` to restart
- Press `q` to quit

---

## Testing the App

### 1. Backend Endpoints
```bash
# Register
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"Test123","name":"Test User"}'

# Get token from response, then:
TOKEN="<your_token_here>"

# Get feed
curl -X GET http://localhost:3000/posts/feed \
  -H "Authorization: Bearer $TOKEN"
```

### 2. Food Search (Mock Data)
```bash
curl -X GET "http://localhost:3000/calories/search-foods?query=apple" \
  -H "Authorization: Bearer $TOKEN"


```

---

## Troubleshooting

### Backend Issues

**Port 3000 already in use**
```bash
# Kill process using port 3000
lsof -i :3000 | grep LISTEN | awk '{print $2}' | xargs kill -9
```

**Database connection refused**
- Ensure PostgreSQL is running: `psql -U postgres -c "SELECT version();"`
- Check DATABASE_URL in .env is correct
- Verify database exists: `psql -U postgres -c "\l"`

**Prisma migration errors**
```bash
# Reset database (WARNING: clears all data)
npx prisma migrate reset

# Or manually run migrations
npx prisma db push
```

### Frontend Issues

**Android emulator not found**
```bash
# List emulators
flutter emulators

# Create one
flutter emulators create --name myemulator

# Start it
flutter emulators launch myemulator
```

**Port conflicts**
- Flutter dev server uses port 5037 by default
- If needed, specify different port: `flutter run --host localhost --port 5038`

---

## Development Workflow

1. **Backend changes**: Auto-restart with `npm start` in dev mode
2. **Frontend changes**: Use `r` for hot reload, `R` for hot restart
3. **Database changes**: 
   ```bash
   # After schema.prisma changes:
   npx prisma migrate dev --name <migration_name>
   ```

---

## Environment Variables

### Backend (.env)
```
PORT=3000
NODE_ENV=development
JWT_SECRET=your-secret-key
DATABASE_URL=postgresql://postgres:password@localhost:5432/gofit_dev
DIRECT_URL=postgresql://postgres:password@localhost:5432/gofit_dev
USDA_API_KEY=demo  # or your actual USDA API key
```

### Frontend (lib/config/api_config.dart)
Already configured with `http://localhost:3000` as default.

---

## First Run Checklist

- [ ] PostgreSQL running
- [ ] `.env` configured with local database
- [ ] `npm install` completed in backend
- [ ] `npx prisma migrate deploy` successful
- [ ] `npm start` backend running
- [ ] `flutter pub get` completed
- [ ] `flutter run` app launching
- [ ] Can register and login in app
- [ ] Can view feed (even if empty)

---

## Next Steps

Once local setup is complete:
1. Test all features in the app
2. Check backend logs for errors
3. Use Flutter DevTools for debugging: `flutter pub global activate devtools`
4. Monitor database with: `psql -U postgres -d gofit_dev -c "SELECT * FROM \"User\" LIMIT 5;"`
