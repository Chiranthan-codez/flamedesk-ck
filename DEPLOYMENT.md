# FlameDesk Deployment Guide

## Stack

- Frontend: Vite + React
- Backend: Node.js + Express
- Database: MySQL

## Recommended Hosting

- Frontend: Vercel
- Backend: Render
- Database: Railway MySQL

## 1. Prepare GitHub

1. Create a GitHub repository.
2. Push this project to GitHub.
3. Make sure `backend/.env` and `frontend/.env` are not committed.

## 2. Create the MySQL Database

Recommended: Railway MySQL.

1. Create a Railway project.
2. Add a MySQL database service.
3. Open the database connection details and copy:
   - host
   - port
   - user
   - password
   - database
4. Import [sql/cloud_kitchen.sql](/c:/Users/Chiranthan/Downloads/FlameDesk/sql/cloud_kitchen.sql) into the Railway database.

## 3. Deploy the Backend on Render

You can use [render.yaml](/c:/Users/Chiranthan/Downloads/FlameDesk/render.yaml) or configure manually.

### Manual Render setup

1. Open Render.
2. Click `New +`.
3. Click `Web Service`.
4. Connect your GitHub repository.
5. Select this repo.
6. Set:
   - Name: `flamedesk-backend`
   - Root Directory: `backend`
   - Runtime: `Node`
   - Build Command: `npm install`
   - Start Command: `npm start`
7. Add environment variables:
   - `JWT_SECRET`
   - `DB_HOST`
   - `DB_PORT`
   - `DB_USER`
   - `DB_PASS`
   - `DB_NAME`
   - `DB_CONNECTION_LIMIT=10`
   - `CORS_ORIGINS`

### Example `CORS_ORIGINS`

```env
https://your-frontend.vercel.app,http://localhost:5173
```

## 4. Deploy the Frontend

Recommended: Vercel.

1. Open Vercel.
2. Click `Add New...`.
3. Click `Project`.
4. Import the GitHub repository.
5. Set the root directory to `frontend`.
6. Add environment variable:

```env
VITE_API_BASE=https://your-render-backend.onrender.com/api
```

7. Deploy.

## 5. Update Backend CORS

After Vercel gives you the frontend URL:

1. Go back to Render.
2. Open backend environment variables.
3. Set `CORS_ORIGINS` to include your Vercel domain.
4. Redeploy the backend if needed.

## 6. Local Example Env Files

Backend example: [backend/.env.example](/c:/Users/Chiranthan/Downloads/FlameDesk/backend/.env.example)

Frontend example: [frontend/.env.example](/c:/Users/Chiranthan/Downloads/FlameDesk/frontend/.env.example)

## Notes

- Render free tier may sleep after inactivity.
- Use a strong `JWT_SECRET`.
- Do not commit real database passwords.
- If you change the backend URL later, update `VITE_API_BASE` in the frontend host.
