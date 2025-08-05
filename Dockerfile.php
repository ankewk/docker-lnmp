# 使用构建参数指定PHP版本
ARG PHP_VERSION=8.2-fpm-alpine
FROM php:${PHP_VERSION}

# 安装系统依赖
RUN apk add --no-cache \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libzip-dev \
    oniguruma-dev \
    icu-dev \
    curl-dev \
    openssl-dev \
    libxml2-dev \
    gettext-dev \
    gmp-dev \
    imap-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        pdo_mysql \
        mysqli \
        mbstring \
        curl \
        json \
        openssl \
        zip \
        xml \
        intl \
        gettext \
        gmp \
        imap \
    && docker-php-ext-enable \
        gd \
        pdo_mysql \
        mysqli \
        mbstring \
        curl \
        json \
        openssl \
        zip \
        xml \
        intl \
        gettext \
        gmp \
        imap

# 安装Redis扩展
RUN apk add --no-cache \
    autoconf \
    g++ \
    make \
    && pecl install redis \
    && docker-php-ext-enable redis

# 安装MongoDB扩展
RUN apk add --no-cache \
    libbsd-dev \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb

# 安装gRPC和Protobuf扩展
RUN apk add --no-cache \
    linux-headers \
    && pecl install grpc \
    && pecl install protobuf \
    && docker-php-ext-enable grpc protobuf

# 安装OPcache
RUN docker-php-ext-install opcache

# 安装Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 设置工作目录
WORKDIR /var/www/html

# 创建www-data用户（如果不存在）
RUN addgroup -g 1000 www-data && \
    adduser -u 1000 -G www-data -s /bin/sh -D www-data

# 设置权限
RUN chown -R www-data:www-data /var/www/html

# 暴露端口
EXPOSE 9000

# 启动PHP-FPM
CMD ["php-fpm"] 