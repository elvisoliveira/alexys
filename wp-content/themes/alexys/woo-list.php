<ul class="center">
    <?php while (have_posts()): the_post(); ?>
        <?php wc_get_template_part('content', 'product'); ?>
    <?php endwhile; ?>
</ul>