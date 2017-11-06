<div class="brand">
    <a href="<?php print get_home_url(); ?>">
        <img src="<?php print get_template_directory_uri(); ?>/images/brandicon.png" />
    </a>
</div>
<div class="menu">
    <div class="header-top">
        <ul>
            <?php foreach (wp_get_nav_menu_items('htop') as $item): ?>
            <li><a href="<?php print get_home_url(); ?>/<?php print $item->target; ?>"><?php print $item->title; ?></a></li>
            <?php endforeach; ?>
        </ul>
    </div>
    <div class="header-sub">
        <ul>
            <?php foreach (wp_get_nav_menu_items('hsub') as $item): ?>
            <li><a href="<?php print get_home_url(); ?>/<?php print $item->target; ?>"><?php print $item->title; ?></a></li>
            <?php endforeach; ?>
        </ul>
    </div>
</div>