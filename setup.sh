#!/bin/bash
# docker exec -i -t alexys-webserver /bin/sh -c "/var/www/alexys/setup.sh"
#
# Check line endings, it must be unix like styled
# Don't forget to remap your hosts file to: alexys
################################################################################

# Node.js resources
read -p "Execute NPM? y/n [n] " npm

while [[ -z "$npm" ]]; do
    npm="n"
done

if [ "$npm" == "y" ]; then
  (cd ./wp-content/themes/alexys/node && npm run assets)
fi

# WordPress Install ############################################################
################################################################################

# Download
if [ ! -f "wp-settings.php" ]; then
    wp core download --allow-root # --locale=pt_BR
fi

# Config
if [ ! -f "wp-config.php" ]; then
    # DB Config on docker-compose.yml
    wp core config --dbhost=database \
                   --dbname=$MYSQL_DATABASE \
                   --dbuser=$MYSQL_USER \
                   --dbpass=$MYSQL_PASSWORD \
                   --allow-root
fi

# Install
while [[ -z "$admin_user" ]]; do
    read -p "[WP] User: " admin_user
done

while [[ -z "$admin_password" ]]; do
    read -p "[WP] Password: " admin_password
done

while [[ -z "$admin_email" ]]; do
    read -p "[WP] Email: " admin_email
done

wp core install --url=http://alexys/ \
                --title='Alexys' \
                --admin_user=$admin_user \
                --admin_email=$admin_email \
                --admin_password=$admin_password \
                --allow-root \
                --skip-email # Avoid postmail: 'sh: 1: -t: not found'

# WordPress Setup ##############################################################
################################################################################

# Post Type: Banner
if [ ! -f "wp-content/themes/alexys/post-types/banner.php" ]; then
    wp scaffold post-type banner --theme='alexys' \
                                 --label='Banner' \
                                 --dashicon='images-alt' \
                                 --allow-root
fi

# Plugins: ACF
wp plugin install advanced-custom-fields --activate --allow-root

# Plugins: Jetpack by WordPress.com
wp --allow-root plugin install jetpack --activate

# Jetpack: Contact
wp --allow-root jetpack module activate contact-form

# Theme: Alexys
wp --allow-root theme activate alexys

# WordPress Content: Post ######################################################
################################################################################

# Delete default post.
wp site empty --yes --allow-root

# Page: About
wp post create ./.docker/wordpress/post-content.txt --allow-root \
                                                    --post_type='page' \
                                                    --post_status='publish' \
                                                    --post_title='About'

# Page: Home
wp post create ./.docker/wordpress/post-content.txt --allow-root \
                                                    --post_type='page' \
                                                    --post_status='publish' \
                                                    --post_title='Home'

# Slugfy
wp rewrite structure '/%postname%' --allow-root

# WordPress Content: Menu ######################################################
################################################################################

wp menu create "Home" --allow-root

# Menu: Item
wp --allow-root menu item add-custom home 'About' / --target=about

# WordPress Content: Banner ####################################################
################################################################################

WP_TEMP=$(mktemp -d)

read -p "Download images? y/n [n] " img

while [[ -z "$img" ]]; do
    img="n"
done

if [ "$img" == "y" ]; then

    for WP_INDX in {1..5}; do

        # Temp location
        WP_IMAG="${WP_TEMP}/${WP_INDX}.jpg"

        # Download 5 ramdom images 1000x1000
        curl -o ${WP_IMAG} 'https://unsplash.it/1000/1000/?random'

        # Attach on WordPress
        WP_ATTC=$(wp media import ${WP_IMAG} --porcelain --allow-root)

        # Posts
        WP_NODE=("wp post create --post_type='banner'      " # Type
                 "               --post_status='publish'   " # Status
                 "               --post_title='${WP_IMAG}' " # Title: Unsupported spaces
                 "               --porcelain               " # Return
                 "               --allow-root              ")

        WP_POST=$(${WP_NODE[@]})

        # ACF
        wp eval-file ./.docker/wordpress/post-content.php --allow-root \
                                                          $WP_INDX \
                                                          $WP_TEMP \
                                                          $WP_ATTC \
                                                          $WP_POST
    done

fi