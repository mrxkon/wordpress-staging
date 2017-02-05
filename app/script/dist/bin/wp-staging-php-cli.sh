#!/bin/bash



# 
# Detect the PHP CLI version (vs the CGI version)
# 

function detect_php_cli()
{

    WHERE_IS_PHP=`whereis php`

    for PHP in $WHERE_IS_PHP ; do

        local RES=`$PHP -r 'echo "Test";' 2> /dev/null`

        if [ "$RES" = "Test" ] ; then
            echo $PHP
            break
        fi

    done
    
}