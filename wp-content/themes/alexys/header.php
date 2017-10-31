<div class="header-top">
    <?php foreach (wp_get_nav_menu_items('htop') as $item): ?>
        <ul>
            <li><a href="<?php print get_home_url(); ?>/<?php print $item->target; ?>"><?php print $item->title; ?></a></li>
        </ul>
    <?php endforeach; ?>
</div>
<div class="header-sub">
    <?php foreach (wp_get_nav_menu_items('hsub') as $item): ?>
        <ul>
            <li><a href="<?php print get_home_url(); ?>/<?php print $item->target; ?>"><?php print $item->title; ?></a></li>
        </ul>
    <?php endforeach; ?>
</div>