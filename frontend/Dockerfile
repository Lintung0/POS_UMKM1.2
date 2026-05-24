# Build stage
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production stage — Caddy (static files only)
# Reverse proxy to backend is handled by the EXTERNAL Caddy at /home/senvada/hosting/Caddyfile
FROM caddy:2-alpine

COPY --from=build /app/dist /srv

RUN cat > /etc/caddy/Caddyfile << 'CADDYFILE'
:80 {
    root * /srv
    try_files {path} /index.html
    file_server
    encode gzip zstd
}
CADDYFILE

EXPOSE 80
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile"]
