<?php while (have_posts()): the_post(); ?>
    <div class="header">
        <div class="center"><?php the_title(); ?></div>
    </div>
    <div class="center">
        <?php the_content(); ?>
    </div>
<?php endwhile; ?>