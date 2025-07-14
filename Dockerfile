FROM php:8.3.23-apache-bookworm

LABEL maintainer="Khalibre <infra@khalibre.com>"

ENV DEBIAN_FRONTEND=noninteractive

ARG COMPOSER_VERSION=2.8.9
ARG MOOSH_VERSION=1.27
ARG MOODLE_VERSION=v4.5.5


USER root

# Install required packages
RUN apt-get update && \
    apt-get install -y \
        software-properties-common \
        curl \
        gnupg2 \
        libpq5 \
        ghostscript \
        poppler-utils \
        unzip \
        git \
        gettext \
        runit \
        locales && \
    locale-gen en_US.UTF-8
#&& \
    # apt-get clean && rm -rf /var/lib/apt/lists/*

# Set locale
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# USER nobody

# Set default environment variables
ENV SITE_URL=http://localhost \
    DB_TYPE=pgsql \
    DB_HOST=postgres \
    DB_PORT=5432 \
    DB_NAME=moodle \
    DB_USER=moodle \
    DB_PASS=moodle \
    DB_PREFIX=mdl_ \
    DB_DBHANDLEOPTIONS=false \
    REDIS_HOST= \
    REVERSEPROXY=false \
    SSLPROXY=false \
    MY_CERTIFICATES=none \
    MOODLE_EMAIL=user@example.com \
    MOODLE_LANGUAGE=en \
    MOODLE_SITENAME=Dockerized_Moodle \
    MOODLE_USERNAME=moodleuser \
    MOODLE_PASSWORD=PLEASE_CHANGEME \
    SMTP_HOST=smtp.gmail.com \
    SMTP_PORT=587 \
    SMTP_USER=your_email@gmail.com \
    SMTP_PASSWORD=your_password \
    SMTP_PROTOCOL=tls \
    MOODLE_MAIL_NOREPLY_ADDRESS=noreply@localhost \
    MOODLE_MAIL_PREFIX=[moodle] \
    AUTO_UPDATE_MOODLE=true \
    DEBUG=false \
    client_max_body_size=50M \
    post_max_size=50M \
    upload_max_filesize=50M \
    max_input_vars=5000


USER root

# Download and extract Moodle
RUN mkdir -p /var/www/html && \
    if [ "$MOODLE_VERSION" = "main" ]; then \
        MOODLE_URL="https://github.com/moodle/moodle/archive/main.tar.gz"; \
    else \
        MOODLE_URL="https://github.com/moodle/moodle/tarball/refs/tags/${MOODLE_VERSION}"; \
    fi && \
    echo "Downloading Moodle from: $MOODLE_URL" && \
    curl -L "$MOODLE_URL" | tar xz --strip-components=1 -C /var/www/html/

# Install Composer
RUN	echo "Installing composer"; \
    curl -o composer.phar -fSL "https://github.com/composer/composer/releases/download/${COMPOSER_VERSION}/composer.phar"; \
    chmod +x ./composer.phar; \
    mv ./composer.phar /usr/local/bin/composer

# Install Moosh CLI
ENV MOOSH_URL=https://github.com/tmuras/moosh/archive/refs/tags/${MOOSH_VERSION}.tar.gz
RUN mkdir -p /opt/moosh && \
    curl -L "$MOOSH_URL" | tar xz --strip-components=1 -C /opt/moosh && \
    composer install --no-interaction --no-cache --working-dir=/opt/moosh

# Copy rootfs and set ownership
COPY --chown=nobody:nogroup rootfs/ /


#USER nobody

EXPOSE 80
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
#CMD ["apache2-foreground"]
