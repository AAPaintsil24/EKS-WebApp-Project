# Applications

This directory contains the core application services of the project.  
It consists of **two containerised microservices**:

- **Frontend**: A React single-page application acting as the homepage and UI
- **Backend**: A Node.js (Express) authentication service connected to persistent storage

Both services are Dockerised, independently deployable, and designed for cloud-native environments.

---

## Directory Structure
```
apps/
├── backend/
│   └── auth-service/
│       ├── Dockerfile         # Production container build (Node 18 Alpine)
│       ├── package.json       # Backend dependencies & scripts
│       ├── sql/
│       │   └── init.sql       # PostgreSQL schema (users table)
│       ├── src/
│       │   ├── db.js          # Database connection
│       │   ├── routes/
│       │   │   └── auth.js    # Authentication endpoints
│       │   └── server.js      # Express server (port 4000)
│       └── test/              # Unit & integration tests
│
└── frontend/
    ├── Dockerfile             # Multi-stage build (Node + Nginx)
    ├── package.json           # Frontend dependencies & scripts
    ├── public/
    │   └── index.html         # HTML template
    └── src/
        ├── App.js             # Root React component
        ├── api.js             # HTTP client for backend API
        ├── index.js           # React entry point
        ├── pages/             # Application pages
        │   ├── Landing.js
        │   ├── Login.js
        │   ├── Signup.js
        │   └── Welcome.js
        ├── setupTests.js      # Jest setup
        └── __tests__/         # Component tests

```


## Backend: Authentication Service
A lightweight Express.js API that handles user authentication, registration, and session management.

**Docker Image:** `node:18-alpine`  
**Port:** `4000`  
**Health Check:** None (consider adding `/health` endpoint)  
**Database:** PostgreSQL (schema in `sql/init.sql`)

### Backend Dependencies
| Package | Purpose | Version |
|---------|---------|---------|
| express | HTTP server framework | ^4.18.2 |
| bcrypt | Password hashing | ^5.1.0 |
| pg | PostgreSQL client | ^8.11.1 |
| cors | Cross-origin resource sharing | ^2.8.5 |
| jest | Testing framework | ^29.6.1 |
| supertest | HTTP integration testing | ^6.3.3 |

### Backend Development
```bash
cd apps/backend/auth-service
npm install
npm start  # Listens on http://localhost:4000
npm test

---

## Application Flow
Client (Browser)
|
v
Frontend (React + Nginx)
|
v
Backend (Node.js Auth Service)
|
v
Relational Database (Users Table)


---

## Backend: Authentication Service

The backend is a lightweight **Express.js API** responsible for:

- User registration
- User authentication
- Secure password hashing
- Database persistence

### Runtime Details

- **Docker Image:** `node:18-alpine`
- **Listening Port:** `4000`
- **Database:** PostgreSQL
- **Schema File:** `sql/init.sql`

---

### Backend Dependencies

| Package     | Purpose                       | Version   |
|------------|-------------------------------|-----------|
| express    | HTTP server framework         | ^4.18.2  |
| bcrypt     | Password hashing              | ^5.1.0   |
| pg         | PostgreSQL client             | ^8.11.1  |
| cors       | Cross-origin support          | ^2.8.5   |
| jest       | Testing framework             | ^29.6.1  |
| supertest  | API integration testing       | ^6.3.3   |

---

### Backend Development

```bash
cd apps/backend/auth-service
npm install
npm start    # http://localhost:4000
npm test
