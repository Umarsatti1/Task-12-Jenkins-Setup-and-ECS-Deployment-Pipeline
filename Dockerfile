# Stage 1: Install production dependencies
FROM node:20-alpine AS build
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install --production

# Stage 2: Runtime image
FROM node:20-alpine
WORKDIR /app

# Copy only the installed dependencies
COPY --from=build /app/node_modules ./node_modules

# Copy application source code
COPY app.js ./
COPY public ./public

# Expose application port
EXPOSE 3000

# Start the Node.js application
CMD ["node", "app.js"]