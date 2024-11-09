# Use an official Node.js runtime as a parent image
FROM node:16-alpine as build

# Set the working directory in the container
WORKDIR /app

# Copy all files to the working directory
COPY . .

# Install http-server globally to serve the static files
RUN npm install -g http-server

# Expose the new port (3000)
EXPOSE 3000

# Run http-server on port 3000
CMD ["http-server", ".", "-p", "3000"]
