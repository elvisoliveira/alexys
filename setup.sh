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

## WooCommerce: Correios
wp --allow-root plugin install woocommerce-correios --activate

## WooCommerce: Translate
if [ ! -d "wp-content/languages/woocommerce" ]; then
    mkdir wp-content/languages/woocommerce
fi

if [ ! -f "wp-content/languages/woocommerce/woocommerce-pt_BR.mo" ]; then
    curl -o wp-content/languages/woocommerce/woocommerce-pt_BR.mo 'https://translate.wordpress.org/projects/wp-plugins/woocommerce/stable/pt-br/default/export-translations?format=mo'
fi

## WooCommerce: Configure Params
declare -a option_name=("cart_page_id" "checkout_page_id" "myaccount_page_id" "shop_page_id" "allow_tracking" "allowed_countries" "calc_taxes" "cart_redirect_after_add" "currency" "default_country" "default_customer_address" "dimension_unit" "enable_ajax_add_to_cart" "enable_coupons" "enable_guest_checkout" "enable_review_rating" "enable_reviews" "enable_shipping_calc" "enable_signup_and_login_from_checkout" "hide_out_of_stock_items" "hold_stock_minutes" "logout_endpoint" "prices_include_tax" "product_type" "ship_to_countries" "ship_to_destination" "shipping_cost_requires_address" "specific_allowed_countries" "specific_ship_to_countries" "store_address" "store_address_2" "store_city" "store_postcode" "tax_based_on" "weight_unit" "admin_notices")
declare -a option_value=("16" "17" "18" "15" "yes" "specific" "no" "no" "BRL" "BR:ES" "base" "cm" "yes" "no" "yes" "yes" "no" "yes" "yes" "yes" "60" "customer-logout" "no" "physical" "specific" "billing" "no" 'a:1:{i:0;s:2:\"BR\";}' 'a:1:{i:0;s:2:\"BR\";}' "R. Pres. Lima, 471" "Centro de Vila Velha" "Vila Velha" "29100330" "shipping" "kg" "a:0:{}")

for ((i=0;i<${#option_name[@]};i++)); do
    wp db query --allow-root "UPDATE wp_options SET option_value=\"${option_value[$i]}\" WHERE option_name=\"woocommerce_{option_name[$i]}\""
done

## WooCommerce: Configure Shipping
wp --allow-root db query < .docker/database/woocommerce_shipping.sql

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

declare -a page_slug=("cart" "myaccount" "checkout" "shop" "terms")
declare -a page_name=("Carrinho" "Minha conta" "Finalizar compra" "Shop" "Terms and Conditions")

# Pages
for ((i=0;i<${#page_slug[@]};i++)); do
    wp post create "./.docker/wordpress/page-${page_slug[$i]}.txt" --allow-root \
                                                                   --post_type='page' \
                                                                   --post_status='publish' \
                                                                   --post_title="${page_name[$i]}"

    WP_PAGE=$(wp --allow-root db query "SELECT ID FROM wp_posts WHERE post_title = \"${page_name[$i]}\"" | paste -s -d',' | sed "s/^ID,//")

    wp db query --allow-root "UPDATE wp_options SET option_value='${WP_PAGE}' WHERE option_name='woocommerce_${page_slug[$i]}_page_id'"
done

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