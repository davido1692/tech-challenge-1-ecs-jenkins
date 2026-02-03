# ---------- Build stage ----------
FROM node:16-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# ---------- Runtime stage ----------
FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy our build output
COPY --from=build /app/build /usr/share/nginx/html

# Expose HTTP
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
