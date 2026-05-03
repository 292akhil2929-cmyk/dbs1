FROM node:22-alpine

WORKDIR /app

# Install backend deps first (better layer caching)
COPY backend/package*.json ./backend/
RUN cd backend && npm ci

# Copy source (backend serves frontend/public statically)
COPY backend ./backend
COPY frontend ./frontend

EXPOSE 3000

CMD ["node", "backend/server.js"]

