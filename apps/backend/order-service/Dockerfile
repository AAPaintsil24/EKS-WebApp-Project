# Base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install dependencies
COPY package.json ./
RUN npm install --production

# Copy source code
COPY . ./

# Expose port
EXPOSE 3000

# Start service
CMD ["node", "src/index.js"]
