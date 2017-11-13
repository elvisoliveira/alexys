<!DOCTYPE html>
<html lang="en">
    <head>
        <title><?php wp_title('-', true, 'right'); ?><?php bloginfo('name'); ?></title>
        <!-- Search Engines -->
        <meta charset="<?php bloginfo('charset'); ?>">
        <meta name="robots" content="index, follow" />
        <meta name="author" content="http://github.com/elvisoliveira" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="pingback" href="<?php bloginfo('pingback_url'); ?>">
        <link rel="stylesheet" type="text/css" media="all" href="<?php bloginfo('stylesheet_url'); ?>" />
        <!-- WordPress Head -->
        <?php wp_head(); ?>
    </head>
    <body <?php body_class(); ?>>
        <div class="topper">
            <div class="center">
                <div class="social">
                    <ul>
                        <li class="twitter"><a href="#">Twitter</a></li>
                        <li class="facebook"><a href="#">Facebook</a></li>
                        <li class="pinterest"><a href="#">Pinterest</a></li>
                        <li class="instagram"><a href="#">Instagram</a></li>
                    </ul>
                </div>
                <div class="search"><?php get_search_form(); ?></div>
            </div>
        </div>
        <div class="header">
            <div class="center">
                <?php get_header(); ?>
            </div>
        </div>
        <div class="content">

                <?php if (have_posts()): ?>

                    <?php // get_header('shop'); ?>
                    <?php // do_action('woocommerce_before_main_content'); ?>

                    <?php if(in_array('single-product', get_body_class())): ?>
                        <?php get_template_part('woo-product'); ?>
                    <?php elseif(in_array('post-type-archive-product', get_body_class())): ?>
                        <?php get_template_part('woo-list'); ?>
                    <?php elseif(in_array('tax-product_cat', get_body_class())): ?>
                        <?php get_template_part('woo-list'); ?>
                    <?php elseif(in_array('search-results', get_body_class())): ?>
                        <?php get_template_part('woo-search'); ?>
                    <?php else: ?>
                        <?php get_template_part('woo-page'); ?>
                    <?php endif; ?>

                    <?php // do_action('woocommerce_after_main_content'); ?>
                    <?php // do_action('woocommerce_sidebar'); ?>
                    <?php // get_footer('shop'); ?>

                <?php else: ?>
                <div class="center">
                    <p>Sorry, this page does not exist.</p>
                </div>
                <?php endif; ?>

        </div>
        <div class="footer">
            <?php get_footer(); ?>
        </div>
        <?php wp_footer(); ?>
    </body>
</html>