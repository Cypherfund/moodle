# Use Debian 11 as the base image.
FROM debian:11

# Set non-interactive mode for apt-get.
ENV DEBIAN_FRONTEND=noninteractive

# Install Apache, PHP7.4 (and its modules), MariaDB server/client,
# git, and other tools (clamav, graphviz, aspell) as well as supervisor and cron.
# Install prerequisites including wget and gnupg
RUN apt-get update && \
    apt-get install -y \
      software-properties-common \
      lsb-release \
      apt-transport-https \
      wget \
      gnupg && \
    wget -qO- https://packages.sury.org/php/apt.gpg | apt-key add - && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/sury-php.list && \
    apt-get update && \
    apt-get install -y \
      apache2 \
      php8.1 \
      libapache2-mod-php8.1 \
      php8.1-mysql \
      php8.1-pspell \
      php8.1-curl \
      php8.1-gd \
      php8.1-intl \
      php8.1-xml \
      php8.1-xmlrpc \
      php8.1-ldap \
      php8.1-zip \
      php8.1-soap \
      php8.1-mbstring \
      graphviz \
      aspell \
      git \
      clamav \
      supervisor \
      cron && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


# Configure Apache:
# Copy the default virtual host and change the DocumentRoot from /var/www/html to /var/www/moodle.
COPY moodle.conf /etc/apache2/sites-available/moodle.conf
RUN a2ensite moodle.conf && \
    a2dissite 000-default.conf && \
    a2enmod rewrite

# Create required directories for Moodle and its data.
RUN mkdir -p /var/www/moodle /var/www/moodledata

# Set proper ownership and permissions for moodledata.
RUN chown -R www-data:www-data /var/www/moodledata && \
    chmod -R 777 /var/www/moodledata

# Copy your local Moodle code into the image.
# Ensure that the local "moodle" directory is in the build context.
COPY . /var/www/moodle/

# Ensure Moodle files have the proper permissions.
RUN chown -R www-data:www-data /var/www/moodle && \
    chmod -R 755 /var/www/moodle


# (Optional) Add your own PHP configuration overrides.
# Create a custom php.ini file (see the sample below) and copy it into the image.
COPY custom-php.ini /etc/php/8.1/apache2/conf.d/99-custom.ini

# Configure Supervisor to run both Apache.
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose HTTP and HTTPS ports.
EXPOSE 80 443

# Start Supervisor (which will run Apache in the foreground).
CMD ["/usr/bin/supervisord", "-n"]
