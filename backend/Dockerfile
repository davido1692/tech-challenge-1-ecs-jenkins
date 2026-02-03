# Use lightweight Node image
FROM node:18-alpine

# Create app directory
WORKDIR /app

# Copy dependency files first (better caching)
COPY package*.json ./

# Install dependencies
RUN npm ci --omit=dev

# Copy the rest of the app
COPY . .

# App listens on 8080
EXPOSE 8080

# Start backend
CMD ["npm", "start"]
