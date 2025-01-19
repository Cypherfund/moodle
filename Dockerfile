# Use an official Moodle base image (e.g., Bitnami’s image) as a starting point.
FROM bitnami/moodle:latest

# Copy your forked Moodle code into the image.
# (Assuming your custom code is in the ./moodle folder)
COPY . /bitnami/moodle

# Adjust permissions if necessary. This example ensures the web server can write to the Moodle folder.
RUN chown -R daemon:daemon /bitnami/moodle

# Expose the port the container will use (default 80)
EXPOSE 80