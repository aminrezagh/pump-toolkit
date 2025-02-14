# Stage 1: Python dependencies and cloning the repository
FROM python:3.9-slim-bullseye as builder

WORKDIR /app

# Install required system dependencies and Python dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    git clone https://github.com/aminrezagh/pump-selection-toolkit.git . && \
    pip install --no-cache-dir -r requirements.txt && \
    apt-get purge -y --auto-remove git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Stage 2: Build the final image
FROM python:3.9-slim-bullseye

WORKDIR /app

# Copy only the necessary files from the builder stage
# Assuming your app does not need the full git repository to run
# Copy the installed Python packages and the application code
COPY --from=builder /app /app
COPY --from=builder /usr/local /usr/local

# Copy the supervisord config file into the container
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose only the ports that are required
EXPOSE 8501 8000

# The command to run the http server and the application
CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]