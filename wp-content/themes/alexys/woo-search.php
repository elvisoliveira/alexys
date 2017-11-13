<div class="header">
    <div class="center">Busca</div>
</div>
<div class="center">
    <ul>
    <?php while (have_posts()): the_post(); ?>
    <?php wc_get_template_part('content', 'product'); ?>
    <?php endwhile; ?>
    </ul>
</div>