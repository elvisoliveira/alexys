<?php

// Generated Post Types
foreach (glob(dirname(__FILE__) . '/post-types/*.php') as $filename)
{
    include_once($filename);
}

function my_search_form($html)
{
    return str_replace('Pesquisar', 'Buscar', $html);
}

add_filter('get_search_form', 'my_search_form');