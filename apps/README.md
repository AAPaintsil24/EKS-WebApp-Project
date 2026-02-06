Apps – Application Services

This directory contains the application layer of the project.
It is composed of two containerised microservices:

Backend (auth-service) – A Node.js authentication API

Frontend (frontend) – A React-based web application acting as the homepage

Each service is independently built using Docker and deployed as a container image (stored in Amazon ECR), while communication between services happens over HTTP.

Directory Structure
apps/
├── backend/
│   └── auth-service/
│       ├── Dockerfile
│       ├── package.json
│       ├── sql/
│       │   └── init.sql
│       ├── src/
│       │   └── server.js
│       └── test/
│
└── frontend/
    ├── Dockerfile
    ├── package.json
    ├── public/
    │   └── index.html
    └── src/
        ├── App.js
        ├── api.js
        ├── index.js
        ├── pages/
        └── setupTests.js

Architecture Overview

The Frontend serves as the homepage and user interface.

The Backend (Auth Service) exposes REST APIs for authentication and user management.

The backend persists user data in a relational database (e.g., PostgreSQL).

The frontend communicates with the backend via HTTP (typically through an API endpoint or ingress in Kubernetes).
[ Browser ]
     |
     v
[ Frontend (React + Nginx) ]
     |
     v
[ Backend Auth Service (Node.js / Express) ]
     |
     v
[ Database (Users Table) ]


Backend – Auth Service
Purpose

The auth-service is a lightweight authentication microservice responsible for:

Handling user-related requests

Managing credentials securely

Communicating with a relational database for persistence

Technology Stack

Node.js 18

Express.js

PostgreSQL (pg)

bcrypt for password hashing

CORS enabled for cross-origin requests

Backend Dockerfile (Overview)

Uses node:18-alpine for a minimal and secure image

Installs production-only dependencies

Exposes port 4000

Starts the service using npm start

Key characteristics:

Optimised image size

Faster rebuilds via Docker layer caching

Suitable for production deployment

Backend Application Entry Point

src/server.js:

Configures Express middleware

Enables JSON parsing and CORS

Registers authentication routes

Starts the server only when run directly (supports testing)

Database Initialization

sql/init.sql defines the initial schema:

Creates a users table

Enforces unique email addresses

Stores hashed passwords (not plaintext)

This script is typically executed during database provisioning (e.g., via RDS init or migration tooling).

Frontend – Web Application
Purpose

The frontend provides the user-facing homepage and interacts with the backend authentication service to:

Send login or registration requests

Display responses from the backend

Serve static content efficiently

Technology Stack

React 18

react-scripts

Nginx (production server)

Jest & Testing Library for testing

Frontend Dockerfile (Overview)

This service uses a multi-stage Docker build:

Build Stage

Uses node:18-alpine

Installs dependencies

Builds an optimized production bundle using npm run build

Production Stage

Uses nginx:alpine

Serves static React build files

Exposes port 80

Benefits:

Very small production image

No Node.js runtime in production

Fast and secure static file serving

Service Communication

The frontend sends HTTP requests to the backend API (e.g. /auth/login, /auth/register)

API base URLs are typically injected via:

Environment variables

Kubernetes ConfigMaps

Helm values.yaml

Containerisation & Deployment

Each service has its own Dockerfile

Images are built independently

Images are pushed to Amazon ECR

Runtime orchestration is handled outside this folder (Kubernetes, Helm, ArgoCD)

Key Design Decisions

Microservice separation: frontend and backend are fully decoupled

Production-optimised Docker images

Stateless services, suitable for horizontal scaling

Clear boundary between UI, API, and data storage layers


