# Step 1: Build Stage
FROM maven:3.8.4-openjdk-17 AS builder

# Install Git using apk (Alpine package manager)
RUN apk update && apk add git

# Set the working directory
WORKDIR /app

# Copy the code into the container
COPY . .

# Set the Maven profile (defaults to 'staging' if not specified)
ARG MAVEN_PROFILE=staging

# Build the project using Maven
RUN mvn clean package -P ${MAVEN_PROFILE}

# Step 2: Runtime Stage
FROM openjdk:17-slim

# Set the working directory
WORKDIR /app

# Copy the built JAR file from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose port 8080
EXPOSE 8080

# Start the application
ENTRYPOINT ["java", "-jar", "app.jar"]
