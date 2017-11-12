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
            <div class="center">
                <?php if (have_posts()): ?>
                <div class="page">

                    <?php // get_header('shop'); ?>
                    <?php // do_action('woocommerce_before_main_content'); ?>

                    <?php while (have_posts()): the_post(); ?>

                        <?php if(in_array('single-product', get_body_class())): ?>
                                <?php wc_get_template_part('content', 'single-product'); ?>
                        <?php elseif(in_array('post-type-archive-product', get_body_class())): ?>
                                <?php wc_get_template_part('content', 'product'); ?>
                        <?php elseif(in_array('tax-product_cat', get_body_class())): ?>
                                <?php wc_get_template_part('content', 'product'); ?>
                        <?php else: ?>
                            <div class="content-title"><?php the_title(); ?><hr /></div>
                            <div class="content-desc"><?php the_content(); ?></div>
                        <?php endif; ?>

                    <?php endwhile; ?>

                    <?php // do_action('woocommerce_after_main_content'); ?>
                    <?php // do_action('woocommerce_sidebar'); ?>
                    <?php // get_footer('shop'); ?>

                </div>
                <?php else: ?>
                <p>Sorry, this page does not exist.</p>
                <?php endif; ?>
            </div>
        </div>
        <div class="footer">
            <?php get_footer(); ?>
        </div>
        <?php wp_footer(); ?>
    </body>
</html>