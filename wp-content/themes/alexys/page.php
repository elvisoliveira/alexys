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
                        <li>Facebook</li>
                        <li>Twitter</li>
                        <li>Instagram</li>
                    </ul>
                </div>
                <div class="search"><?php get_search_form(); ?></div>
            </div>
        </div>
        <div class="header">
            <?php get_header(); ?>
        </div>
        <div class="content">
            <?php if (have_posts()): ?>
                <div class="page">
                    <?php while (have_posts()): ?>
                        <?php the_post(); ?>
                        <div class="content-title"><?php the_title(); ?><hr /></div>
                        <div class="content-desc"><?php the_content(); ?></div>
                    <?php endwhile; ?>
                </div>
            <?php else: ?>
                <p>Sorry, this page does not exist.</p>
            <?php endif; ?>
        </div>
        <div class="footer">
            <?php get_footer(); ?>
        </div>
        <?php wp_footer(); ?>
    </body>
</html>