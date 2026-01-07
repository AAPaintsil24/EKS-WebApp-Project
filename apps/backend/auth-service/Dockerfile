# Use Node.js 18 Alpine for a small and secure base image
FROM node:18-alpine

# Set the working directory inside the container to /app
WORKDIR /app

# Copy package.json and package-lock.json (if exists) for dependency installation
# This layer is cached, making rebuilds faster when dependencies don't change
COPY package*.json ./

# Install ONLY production dependencies (listed in 'dependencies' of package.json)
# This excludes dev tools like 'jest', resulting in a smaller and more secure image
RUN npm install --only=production

# Copy the rest of the application source code into the container
COPY . .

# Inform Docker that the container listens on port 4000 (matches your server.js)
EXPOSE 4000

# Use the start script defined in package.json ('node src/server.js') to run the app
CMD ["npm", "start"]