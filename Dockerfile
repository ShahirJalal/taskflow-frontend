# ──────────────────────────────────────────────────────────────
# Stage 1 — Angular build
# ──────────────────────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Use fast registry mirror
RUN npm config set registry https://registry.npmmirror.com

# Install deps
COPY package*.json ./
RUN npm ci --legacy-peer-deps

# Copy full source and build
COPY . .
RUN npm run build -- --configuration production

# ──────────────────────────────────────────────────────────────
# Stage 2 — Serve with NGINX
# ──────────────────────────────────────────────────────────────
FROM nginx:alpine

# Copy built Angular app
COPY --from=builder /app/dist/frontend /usr/share/nginx/html

# Copy custom SPA fallback config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
