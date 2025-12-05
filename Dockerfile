# ──────────────────────────────────────────────────────────────
# Stage 1 — Angular build
# ──────────────────────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Fast registry
RUN npm config set registry https://registry.npmmirror.com

COPY package*.json ./
RUN npm ci --legacy-peer-deps

COPY . .

RUN npm run build -- --configuration production

# ──────────────────────────────────────────────────────────────
# Stage 2 — Serve with NGINX
# ──────────────────────────────────────────────────────────────
FROM nginx:alpine

# Copy compiled Angular output
COPY --from=builder /app/dist/frontend /usr/share/nginx/html

# If routing exists, enable SPA fallback
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
