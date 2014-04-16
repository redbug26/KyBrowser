KyBrowser
=========

Sample webbrowser to show to external developers how to use the *KyPass
x-callback-url.*



x-callback-url
--------------

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
x-kypass://x-callback-url/open
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Launch KyPass



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
x-kypass://x-callback-url/search?
    x-success={x-success-url}&
    x-error={x-success-url}&
    url={url}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Search about a url in KyPass.

**Parameters**

-   x-sucess: url called after user select an entry in the search box. KyPass
    send the username:password encrypted with the challenge in the GET parameter
    'result'

-   x-error: url called if user cancel the search box

-   url: search string to be search in the database



Copyright
---------

KyBrowser is based on iPhone-Inline-Web-Browser by Jon Chui
(https://github.com/jonchui/iPhone-Inline-Web-Browser)
