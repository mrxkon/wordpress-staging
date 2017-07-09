# Common gotchas

Install the `app` in the root folder of your CPanel user and let this directory
be the directory where the staging websites are created.

Be careful of the automatically detected WordPress websites. The `app` searches
for directories with a `wp-confing.php` in them, so it might make slight
mistakes there. Always make sure you give it the correct paths there.

String replacement in the database usually works nicely, but there are some
cases that the `app` cannot handle. For instance, if the original website has
moved inside the filesystem in the past and some old filesystem path entries in
the database have not been updated. The same could happen with the urls, when
moving a website from HTTP to HTTPS and forgetting to replace the old urls. In 
this case the urls in the database are in the HTTP protocol whereas the database
string replacements in the staging website occur against the HTTPS protocol.

Beware of the plugins that the `app` deactivates in the staging environment.

The `app` is unable to detect and take into account any custom `.htaccess`
modifications. 

If you are staging websites which are under the SSL protocol, ie https, then the
main directory of the staging websites should have an SSL certificate installed
in it, otherwise browsers will complain and refuse the connection to them. The 
easiest thing one can do is to add a simple, free, even self signed certificate
to this directory.