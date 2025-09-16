FROM debian:bookworm-slim

# Install required packages
RUN apt-get update && \
    apt-get install -y fortune-mod cowsay netcat-openbsd bash ca-certificates && \
    rm -rf /var/lib/apt/lists/*


# Set PATH to include cowsay
ENV PATH="/usr/games:${PATH}"

# Create app directory
WORKDIR /app

# Copy the wisecow script
COPY wisecow.sh .

# Make the script executable
RUN chmod +x wisecow.sh

# Expose port 4499
EXPOSE 4499

# Run the application
CMD ["./wisecow.sh"]
