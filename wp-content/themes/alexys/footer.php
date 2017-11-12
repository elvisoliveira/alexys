<div class="center">
    <div class="over">
        <dl class="info">
            <dt>Informações</dt>
            <dd>
                <ul>
                    <?php foreach (wp_get_nav_menu_items('htop') as $item): ?>
                    <li><a href="<?php print get_home_url(); ?>/<?php print $item->target; ?>"><?php print $item->title; ?></a></li>
                    <?php endforeach; ?>
                </ul>
                <ul>
                    <?php foreach (wp_get_nav_menu_items('hsub') as $item): ?>
                    <li><a href="<?php print get_home_url(); ?>/<?php print $item->target; ?>"><?php print $item->title; ?></a></li>
                    <?php endforeach; ?>
                </ul>
            </dd>
        </dl>
        <dl class="blog">
            <dt>Blog</dt>
            <dd>
                <?php $custom_query = new WP_Query(array('post_type' => 'post', 'posts_per_page' => 4)); ?>
                <ul>
                    <?php while($custom_query->have_posts()): $custom_query->the_post(); ?>
                    <li <?php post_class(); ?> id="post-<?php the_ID(); ?>">
                        <div class="date"><?php print get_the_date('d'); ?><span class="month"><?php print substr(get_the_date('F'), 0, 3); ?></span></div>
                        <div class="title"><a href="<?php the_permalink(); ?>"><?php the_title(); ?></a></div>
                        <?php // the_content(); ?>
                    </li>
                    <?php endwhile; ?>
                </ul>
                <?php wp_reset_postdata(); ?>
            </dd>
        </dl>
        <dl class="tags">
            <dt>Tags</dt>
            <dd>
                <ul>
                    <?php foreach (get_terms(array('taxonomy' => 'product_cat')) as $terms): ?>
                    <li><a href="/shop/category/<?php print $terms->slug; ?>"><?php print $terms->name; ?></a></li>
                    <?php endforeach; ?>
                </ul>
            </dd>
        </dl>
        <dl class="snet">
            <dt>Connect</dt>
            <dd>
                <ul>
                    <li class="facebook">
                        <a href="#">Facebook</a>
                    </li>
                    <li class="pinterest">
                        <a href="#">Pinterest</a>
                    </li>
                    <li class="twitter">
                        <a href="#">Twitter</a>
                    </li>
                    <li class="instagram">
                        <a href="#">Instagram</a>
                     </li>
                </ul>
            </dd>
        </dl>
    </div>
    <div class="under">
        <div class="credit-card">
            <ul>
                <li class="visa"><a href="#">Visa</a></li>
                <li class="paypal"><a href="#">PayPal</a></li>
                <li class="mastercard"><a href="#">MasterCard</a></li>
                <li class="discobery"><a href="#">Discobery</a></li>
            </ul>
        </div>
        <div class="credits">
            <a href="http://oxdigital.com.br/">
                <img alt="OX Digital" src="<?php echo get_template_directory_uri(); ?>/images/oxdigital.gif" />
            </a>
        </div>
    </div>
</div>
<?php wp_footer(); ?>