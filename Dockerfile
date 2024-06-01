# Use Google's official Dart Docker image to build the Flutter app
FROM google/dart as build

# Add missing GPG keys
RUN sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
RUN sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_testing.list > /etc/apt/sources.list.d/dart_testing.list'
RUN sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_unstable.list > /etc/apt/sources.list.d/dart_unstable.list'
RUN curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E88979FB9B30ACF2

# Update apt and install required tools
RUN apt-get update && apt-get install -y git unzip

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Verify installation and setup
RUN flutter doctor

# Set the working directory
WORKDIR /app

# Copy the pubspec files and run pub get to cache dependencies
COPY pubspec.yaml pubspec.lock ./

# Get all dependencies
RUN flutter pub get

# Copy the rest of the application files
COPY . .

# Enable web support and build the Flutter web app
RUN flutter config --enable-web
RUN flutter build web

# Use an nginx image to serve the built Flutter web app
FROM nginx:alpine

# Copy the built files from the build stage to the nginx html directory
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
