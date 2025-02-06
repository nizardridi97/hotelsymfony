FROM php:8.3-apache

# Installation des extensions PHP requises
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libicu-dev \
    libpq-dev \
    libzip-dev \
    zip \
    && docker-php-ext-install intl pdo pdo_mysql zip

# Activation des modules Apache nécessaires
RUN a2enmod rewrite

# Copier la configuration Apache
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Définition du répertoire de travail
WORKDIR /var/www/html

# Copier les fichiers du projet
COPY . .

# Copier les fichiers .env pour la configuration de Symfony
COPY .env* ./

# Installation des dépendances Symfony
RUN composer install --no-dev --optimize-autoloader

# Attribution des droits à Symfony
RUN chown -R www-data:www-data /var/www/html/var /var/www/html/public

# Exposer le port Apache
EXPOSE 80

# Démarrage d'Apache
CMD ["apache2-foreground"]
