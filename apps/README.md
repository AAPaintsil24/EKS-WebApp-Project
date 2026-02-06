# Applications

This directory contains the core application services of the project.  
It consists of **two containerised microservices**:

- **Frontend**: A React single-page application acting as the homepage and UI
- **Backend**: A Node.js (Express) authentication service connected to persistent storage

Both services are Dockerised, independently deployable, and designed for cloud-native environments.

---

## Directory Structure
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


