<?php

// Generated Post Types
foreach (glob(dirname(__FILE__) . '/post-types/*.php') as $filename)
{
    include_once($filename);
}
