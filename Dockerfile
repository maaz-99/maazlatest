# ---- build stage ----
FROM node:20-alpine AS build
WORKDIR /app

# Install deps (use lockfile if present)
COPY package*.json ./
RUN if [ -f package-lock.json ]; then npm ci --omit=dev=false; else npm install; fi

# Copy source and build (if you have a build step; otherwise it's harmless)
COPY . .
RUN npm run build || true

# Prune devDependencies for a slim runtime
RUN npm prune --omit=dev

# ---- runtime stage ----
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production \
    PORT=3000

# Copy only the built app + prod deps
COPY --from=build /app /app

# If your app listens on a different port, change this
EXPOSE 3000

# Start the app (ensure "start" script exists in package.json)
CMD ["npm", "start"]
