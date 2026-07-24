# Use Java 17 JDK base image
FROM eclipse-temurin:17-jdk

# Set environment variables for Android SDK
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/build-tools/36.0.0

# Install required tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    curl \
    git \
    gradle \
    && rm -rf /var/lib/apt/lists/*

# Download and set up Android Command Line Tools
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/cmdline-tools.zip && \
    unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools && \
    mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip

# Accept SDK licenses and install Android Platform SDK & Build Tools
RUN yes | sdkmanager --licenses && \
    sdkmanager "platforms;android-36" "build-tools;36.0.0" "platform-tools"

# Set working directory
WORKDIR /app

# Copy project files into container
COPY . .

# Build debug APK
RUN gradle assembleDebug --no-daemon

# Default command outputs build status and APK location
CMD ["echo", "APK built successfully at /app/app/build/outputs/apk/debug/app-debug.apk"]
