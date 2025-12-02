# ──────────────────────────────────────────────────────────────
# Multi-stage build — super fast + works on slow networks
# ──────────────────────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Use the ultra-fast Chinese mirror inside Docker too
RUN npm config set registry https://registry.npmmirror.com

COPY package*.json ./
RUN npm ci --legacy-peer-deps

COPY . .
RUN npm run build -- --configuration production

# ──────────────────────────────────────────────────────────────
FROM nginx:alpine

# Copy built app
COPY --from=builder /app/dist/frontend /usr/share/nginx/html

# Copy custom nginx config (if you have one)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]