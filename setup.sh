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
    wp core download --allow-root --locale=pt_BR
fi

# Config
if [ ! -f "wp-config.php" ]; then
    # DB Config on docker-compose.yml
    wp core config --dbhost=database \
                   --locale=pt_BR \
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
wp --allow-root plugin install advanced-custom-fields --activate

# Plugins: Jetpack by WordPress.com
wp --allow-root plugin install jetpack --activate

# WooCommerce
wp --allow-root plugin install woocommerce --activate

## Translate
mkdir wp-content/languages/woocommerce

curl -o wp-content/languages/woocommerce/woocommerce-pt_BR.mo 'https://translate.wordpress.org/projects/wp-plugins/woocommerce/stable/pt-br/default/export-translations?format=mo'

## Configure
wp db query --allow-root 'UPDATE wp_options SET option_value="16" WHERE option_name="woocommerce_cart_page_id"'
wp db query --allow-root 'UPDATE wp_options SET option_value="17" WHERE option_name="woocommerce_checkout_page_id"'
wp db query --allow-root 'UPDATE wp_options SET option_value="18" WHERE option_name="woocommerce_myaccount_page_id"'
wp db query --allow-root 'UPDATE wp_options SET option_value="15" WHERE option_name="woocommerce_shop_page_id"'
wp db query --allow-root 'UPDATE wp_options SET option_value="" WHERE option_name="woocommerce_terms_page_id"'
wp db query --allow-root 'UPDATE wp_options SET option_value="yes" WHERE option_name="woocommerce_allow_tracking"'
wp db query --allow-root 'UPDATE wp_options SET option_value="specific" WHERE option_name="woocommerce_allowed_countries"'
wp db query --allow-root 'UPDATE wp_options SET option_value="no" WHERE option_name="woocommerce_calc_taxes"'
wp db query --allow-root 'UPDATE wp_options SET option_value="no" WHERE option_name="woocommerce_cart_redirect_after_add"'
wp db query --allow-root 'UPDATE wp_options SET option_value="BRL" WHERE option_name="woocommerce_currency"'
wp db query --allow-root 'UPDATE wp_options SET option_value="BR:ES" WHERE option_name="woocommerce_default_country"'
wp db query --allow-root 'UPDATE wp_options SET option_value="base" WHERE option_name="woocommerce_default_customer_address"'
wp db query --allow-root 'UPDATE wp_options SET option_value="cm" WHERE option_name="woocommerce_dimension_unit"'
wp db query --allow-root 'UPDATE wp_options SET option_value="yes" WHERE option_name="woocommerce_enable_ajax_add_to_cart"'
wp db query --allow-root 'UPDATE wp_options SET option_value="no" WHERE option_name="woocommerce_enable_coupons"'
wp db query --allow-root 'UPDATE wp_options SET option_value="yes" WHERE option_name="woocommerce_enable_guest_checkout"'
wp db query --allow-root 'UPDATE wp_options SET option_value="yes" WHERE option_name="woocommerce_enable_review_rating"'
wp db query --allow-root 'UPDATE wp_options SET option_value="no" WHERE option_name="woocommerce_enable_reviews"'
wp db query --allow-root 'UPDATE wp_options SET option_value="yes" WHERE option_name="woocommerce_enable_shipping_calc"'
wp db query --allow-root 'UPDATE wp_options SET option_value="yes" WHERE option_name="woocommerce_enable_signup_and_login_from_checkout"'
wp db query --allow-root 'UPDATE wp_options SET option_value="yes" WHERE option_name="woocommerce_hide_out_of_stock_items"'
wp db query --allow-root 'UPDATE wp_options SET option_value="60" WHERE option_name="woocommerce_hold_stock_minutes"'
wp db query --allow-root 'UPDATE wp_options SET option_value="customer-logout" WHERE option_name="woocommerce_logout_endpoint"'
wp db query --allow-root 'UPDATE wp_options SET option_value="no" WHERE option_name="woocommerce_prices_include_tax"'
wp db query --allow-root 'UPDATE wp_options SET option_value="physical" WHERE option_name="woocommerce_product_type"'
wp db query --allow-root 'UPDATE wp_options SET option_value="specific" WHERE option_name="woocommerce_ship_to_countries"'
wp db query --allow-root 'UPDATE wp_options SET option_value="billing" WHERE option_name="woocommerce_ship_to_destination"'
wp db query --allow-root 'UPDATE wp_options SET option_value="no" WHERE option_name="woocommerce_shipping_cost_requires_address"'
wp db query --allow-root 'UPDATE wp_options SET option_value="a:1:{i:0;s:2:\"BR\";}" WHERE option_name="woocommerce_specific_allowed_countries"'
wp db query --allow-root 'UPDATE wp_options SET option_value="a:1:{i:0;s:2:\"BR\";}" WHERE option_name="woocommerce_specific_ship_to_countries"'
wp db query --allow-root 'UPDATE wp_options SET option_value="R. Pres. Lima, 471" WHERE option_name="woocommerce_store_address"'
wp db query --allow-root 'UPDATE wp_options SET option_value="Centro de Vila Velha" WHERE option_name="woocommerce_store_address_2"'
wp db query --allow-root 'UPDATE wp_options SET option_value="Vila Velha" WHERE option_name="woocommerce_store_city"'
wp db query --allow-root 'UPDATE wp_options SET option_value="29100330" WHERE option_name="woocommerce_store_postcode"'
wp db query --allow-root 'UPDATE wp_options SET option_value="shipping" WHERE option_name="woocommerce_tax_based_on"'
wp db query --allow-root 'UPDATE wp_options SET option_value="kg" WHERE option_name="woocommerce_weight_unit"'

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
        curl -o ${WP_IMAG} 'https://picsum.photos/1000/1000/?random'

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