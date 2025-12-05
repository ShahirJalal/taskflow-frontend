# ──────────────────────────────────────────────────────────────
# Stage 1 — Angular build
# ──────────────────────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Fast registry + retry settings
RUN npm config set registry https://registry.npmmirror.com \
    && npm config set fetch-retries 5 \
    && npm config set fetch-retry-mintimeout 20000 \
    && npm config set fetch-retry-maxtimeout 120000

COPY package*.json ./

# Install deps with retry fallback
RUN npm ci --legacy-peer-deps \
 || npm ci --legacy-peer-deps \
 || npm install --legacy-peer-deps

COPY . .

RUN npm run build -- --configuration production

# ──────────────────────────────────────────────────────────────
# Stage 2 — Serve with NGINX
# ──────────────────────────────────────────────────────────────
FROM nginx:alpine

# SPA routing + backend proxy
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built Angular output
COPY --from=builder /app/dist/frontend /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
