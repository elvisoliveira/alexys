#!/bin/bash
# docker exec -i -t alexys-webserver /bin/sh -c "/var/www/alexys/setup.sh"
#
# Check line endings, it must be unix like styled
# Don't forget to: Remap your hosts file to: alexys.ddns.net
#                  Set the info from the payment gateway. (PagSeguro)
################################################################################

# WordPress Install ############################################################
################################################################################

# Clear
read -p "Clear current filesystem? y/n [n] " erase

while [[ -z "$erase" ]]; do
    erase="n"
done

if [ "$erase" == "y" ]; then
    # Drop DB
    wp db drop --yes --allow-root
    # Remove all
    rm -rf *.php *.html *.txt ./wp-admin ./wp-includes ./wp-content/languages
    rm -rf ./wp-content/plugins ./wp-content/upgrade ./wp-content/uploads
fi

# Download
if [ ! -f "wp-settings.php" ]; then
    wp core download --version=4.8.2 --allow-root --locale=pt_BR
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
    # DB CREATE
    wp db create --allow-root
fi

# Install
while [[ -z "$admin_user" ]]; do
    read -p "[WP] User: " admin_user
done

while [[ -z "$admin_password" ]]; do
    read -p "[WP] Password: " admin_password
done

while [[ -z "$admin_email" ]]; do
    read -p "[WP / PagSeguro] Email: " admin_email
done

# Pagseguro Settings
while [[ -z "$pagseguro_token" ]]; do
    read -p "[PagSeguro] Token: " pagseguro_token
done

wp core install --url=http://alexys.ddns.net/ \
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

# Plugin Install
declare -a plugins=("advanced-custom-fields" "jetpack" "woocommerce" 
                    "woocommerce-correios" "woocommerce-pagseguro")

WP_LANG_FLD="wp-content/languages/plugins"
WP_LANGUAGE="pt_BR"

if [ ! -d "wp-content/languages" ]; then
    mkdir "wp-content/languages";
fi

if [ ! -d "${WP_LANG_FLD}" ]; then
    mkdir "${WP_LANG_FLD}";
fi

for ((i=0;i<${#plugins[@]};i++)); do

    # Plugin Download
    wp --allow-root plugin install ${plugins[$i]} --activate

    # Plugin Translate
    if [ ! -f "${WP_LANG_FLD}/${plugins[$i]}-${WP_LANGUAGE}.mo" ]; then
        curl -o "${WP_LANG_FLD}/${plugins[$i]}-${WP_LANGUAGE}.mo" \
        "https://translate.wordpress.org/projects/wp-plugins/${plugins[$i]}/stable/pt-br/default/export-translations?format=mo"
    fi
done

## WooCommerce: Configure Params
declare -a option_name=("allow_tracking" "allowed_countries" "calc_taxes" "cart_redirect_after_add" 
                        "currency" "default_country" "default_customer_address" "dimension_unit" 
                        "enable_ajax_add_to_cart" "enable_coupons" "enable_guest_checkout" 
                        "enable_review_rating" "enable_reviews" "enable_shipping_calc" 
                        "enable_signup_and_login_from_checkout" "hide_out_of_stock_items" 
                        "hold_stock_minutes" "logout_endpoint" "prices_include_tax" "product_type" 
                        "ship_to_countries" "ship_to_destination" "shipping_cost_requires_address" 
                        "specific_allowed_countries" "specific_ship_to_countries" "store_address" 
                        "store_address_2" "store_city" "store_postcode" "tax_based_on" 
                        "weight_unit" "admin_notices")

declare -a option_value=("yes" "specific" "no" "no" "BRL" "BR:ES" "base" "cm" "yes" "no" "yes" 
                         "yes" "no" "yes" "yes" "yes" "60" "customer-logout" "no" "physical" 
                         "specific" "billing" "no" 'a:1:{i:0;s:2:\"BR\";}' 'a:1:{i:0;s:2:\"BR\";}' 
                         "R. Pres. Lima, 471" "Centro de Vila Velha" "Vila Velha" "29100330" # Company Info
                         "shipping" "kg" "a:0:{}")

for ((i=0;i<${#option_name[@]};i++)); do
    wp db query --allow-root "UPDATE wp_options
                                 SET option_value=\"${option_value[$i]}\"
                               WHERE option_name=\"woocommerce_${option_name[$i]}\""
done

## WooCommerce: Configure Shipping
wp --allow-root db query < .docker/database/woocommerce_shipping.sql

## WooCommerce: Disable alternative payments
wp --allow-root eval "update_option('woocommerce_cod_settings', array('enabled' => 'no'));"
wp --allow-root eval "update_option('woocommerce_bacs_settings', array('enabled' => 'no'));"
wp --allow-root eval "update_option('woocommerce_cheque_settings', array('enabled' => 'no'));"
wp --allow-root eval "update_option('woocommerce_paypal_settings', array('enabled' => 'no'));"

## WooCommerce: Enable Pagseguro
wp --allow-root eval "update_option('woocommerce_pagseguro_settings',
                                    array('sandbox_email' => '$admin_email', /* ----- Pagseguro ---- */
                                          'sandbox_token' => '$pagseguro_token', /* ----- Pagseguro ---- */
                                          'debug' => 'no', 'title' => 'PagSeguro', 'method' => 'lightbox',
                                          'sandbox' => 'yes', 'enabled' => 'yes', 'tc_credit' => 'yes',
                                          'tc_ticket' => 'yes', 'tc_transfer' => 'yes',
                                          'description' => 'Pay via PagSeguro', 'invoice_prefix' => 'WC-',
                                          'send_only_total' => 'no', 'tc_ticket_message' => 'yes')
                                   );"

## WooCommerce Correios: Enable Submission Methods
wp --allow-root eval "update_option('woocommerce_correios-pac_1_settings',
                                    array('debug' => 'no', 'title' => 'PAC', 'enabled' => 'yes',
                                          'own_hands' => 'no', 'service_type' => 'conventional',
                                          'extra_weight' => '0', 'declare_value' => 'yes',
                                          'minimum_width' => '11', 'receipt_notice' => 'no',
                                          'minimum_height' => '2', 'minimum_length' => '16',
                                          'origin_postcode' => '29100-330', 'additional_time' => '2',
                                          'show_delivery_time' => 'yes')
                                    );"

wp --allow-root eval "update_option('woocommerce_correios-sedex_2_settings',
                                    array('debug' => 'no', 'title' => 'SEDEX', 'enabled' => 'yes',
                                          'own_hands' => 'no', 'service_type' => 'conventional',
                                          'extra_weight' => '0', 'minimum_width' => '11',
                                          'declare_value' => 'yes', 'minimum_length' => '16',
                                          'minimum_height' => '2', 'receipt_notice' => 'no',
                                          'additional_time' => '2', 'origin_postcode' => '29100-330',
                                          'show_delivery_time' => 'yes')
                                    );"

# Fix URLs
wp --allow-root --format=json option update woocommerce_permalinks \
   '{"category_base":"\/shop\/category","product_base":"\/shop","use_verbose_page_rules": true}'

# Jetpack: Contact
wp --allow-root jetpack module activate contact-form

# Theme: Alexys
wp --allow-root theme activate alexys

# Download alexys base image
curl -L -o "wp-content/themes/alexys/images/ashim-d-silva-89336.jpg" \
           "https://unsplash.com/photos/ZmgJiztRHXE/download?force=true"

# WordPress Content: Post ######################################################
################################################################################

# Delete default post.
wp site empty --yes --allow-root

# Pages: Static
declare -a page_slug=("home" "brand" "blog" "faq")
declare -a page_name=("Home" "Nossa Marca" "Blog" "Dúvidas Frequentes")

for ((i=0;i<${#page_slug[@]};i++)); do
    wp post create "./.docker/wordpress/post-content.txt" --allow-root \
                                                          --post_type='page' \
                                                          --post_status='publish' \
                                                          --post_name="${page_slug[$i]}" \
                                                          --post_title="${page_name[$i]}"

    WP_PAGE=$(wp --allow-root db query "SELECT ID 
                                          FROM wp_posts 
                                         WHERE post_title = \"${page_name[$i]}\"" | paste -s -d',' | sed "s/^ID,//")

    if [ "${page_name[$i]}" == "Home" ]; then
        # Set default page to Home
        wp option update --allow-root show_on_front page
        wp option update --allow-root page_on_front ${WP_PAGE}
    fi
done

# Blog posts
declare -a blog=("Best Street Style Looks From New York Fashion Week Spring 2018"
                 "The Best Fashion Blogs to Follow in 2017"
                 "What to Wear to Work in Autumn"
                 "The Best of the Best Jeans for Fall and Where To Get Them"
                 "The Dad Pants Are Back and We Couldn’t Be Happier"
                 "The Ultimate Fall Boot to Go from Day to Night")

WP_TEMP=$(mktemp -d)

for ((i=0;i<${#blog[@]};i++)); do

    # Temp location
    WP_IMAG="${WP_TEMP}/${i}.jpg"

    # Download 5 ramdom images 1000x1000
    curl  -L -o ${WP_IMAG} 'https://picsum.photos/1000/1000/?random'

    POST_ID=$(wp post create "./.docker/wordpress/post-content.txt" --porcelain \
                                                                    --allow-root \
                                                                    --post_status='publish' \
                                                                    --post_title="${blog[$i]}")

    THMB_ID=$(wp media import --porcelain \
                              --allow-root \
                              --post_id=${POST_ID} \
                              --alt="${blog[$i]}" \
                              --title="${blog[$i]}" ${WP_IMAG})

  wp post meta add ${POST_ID} _thumbnail_id ${THMB_ID} --allow-root

done

# Pages: WooCommerce
declare -a woo_slug=("cart" "myaccount" "checkout" "shop" "terms")
declare -a woo_name=("Carrinho" "Minha conta" "Finalizar compra" "Shop" "Termos e Condições")

for ((i=0;i<${#woo_slug[@]};i++)); do

    wp post create "./.docker/wordpress/page-${woo_slug[$i]}.txt" --allow-root \
                                                                  --post_type='page' \
                                                                  --post_status='publish' \
                                                                  --post_name="${woo_slug[$i]}" \
                                                                  --post_title="${woo_name[$i]}"

    WP_PAGE=$(wp --allow-root db query "SELECT ID 
                                          FROM wp_posts 
                                         WHERE post_title = \"${woo_name[$i]}\"" | paste -s -d',' | sed "s/^ID,//")

    wp db query --allow-root "UPDATE wp_options 
                                 SET option_value='${WP_PAGE}'
                               WHERE option_name='woocommerce_${woo_slug[$i]}_page_id'"
done

# Slugfy
wp rewrite structure '/%postname%' --allow-root

# WooCommerce: Categories ######################################################
################################################################################

declare -a product_categories=("Bermuda" "Blusa" "Body" "Camisa" "Casaco" "Jaqueta"
                               "Legging" "Macacão" "Regata" "Shorts" "Top" "Tshirt"
                               "Blazer" "Calça" "Cardigã" "Colete" "Kaftan" "Lingerie"
                               "Moletom" "Saia" "Spencer" "Trenchcoat" "Vestido" )

for ((i=0;i<${#product_categories[@]};i++)); do
    wp wc product_cat create --name=${product_categories[$i]} --user=admin --allow-root
done

# WooCommerce: Products ########################################################
################################################################################

declare -a products=("External/Affiliate Product" "Downloadable Product" "Side Slits Sweatshirt"
                     "Side Pockets Backpack" "Oversized Sweater" "Tencel Shirt" "Yellow Sweatshirt"
                     "Oversized Denim Jacket" "White Textured Sneakers" "Black Sneakers"
                     "Short Faux Fur Coat" "Technical Pieces Sneakers" "Red Lace-up Sneakers"
                     "Tailored Joggers" "Faux Leather Biker Jacket" "Retro Flower Pattern Black Dress"
                     "The White Stripes" "Limited Edition Denim" "Black Denim Jacket")

for ((i=0;i<${#products[@]};i++)); do
    wp wc product create --stock_quantity="$(shuf -i 10-30 -n 1)"                              \
                         --regular_price="$(shuf -i 50-99 -n 1)"                               \
                         --sale_price="$(shuf -i 1-49 -n 1)"                                   \
                         --status="publish"                                                    \
                         --categories="[{\"id\":$(shuf -i 1-${#product_categories[@]} -n 1)}]" \
                         --name="${products[$i]}"                                              \
                         --user="admin"                                                        \
                         --description="$(cat ./.docker/wordpress/post-content.txt)"           \
                         --allow-root
done

# WordPress Content: Menu ######################################################
################################################################################

wp menu create "hTop" --allow-root # Header Top
wp menu create "hSub" --allow-root # Header Sub

# Menu: Item
wp --allow-root menu item add-custom htop 'Home' / --target=home
wp --allow-root menu item add-custom htop 'Produtos' / --target=shop
wp --allow-root menu item add-custom htop 'Dúvidas Frequentes' / --target=faq
wp --allow-root menu item add-custom htop 'Blog' / --target=blog

wp --allow-root menu item add-custom hsub 'Termos e Condições' / --target=terms
wp --allow-root menu item add-custom hsub 'Nossa Marca' / --target=brand
wp --allow-root menu item add-custom hsub 'Carrinho' / --target=cart

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

# Node.js resources ############################################################
################################################################################

read -p "Execute NPM? y/n [n] " npm

while [[ -z "$npm" ]]; do
    npm="n"
done

if [ "$npm" == "y" ]; then
    (cd ./wp-content/themes/alexys/node && npm run devel)
fi