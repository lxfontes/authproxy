# OAuth 2 Reverse Proxy

Secure administration panels via a single authentication point.
It handles multiple domains and multiple backends at once, taking care of forwarding proper HTTP headers (X-Forwarded-For / Proto) and introducing `X-Forwarded-User`.
Also supports Google Apps domains.


# Setting up



## A more complex deployment
Separate public site from administration via domain names. Ex: www.mysite.com (public) admin.mysite.com (private).

                          +---------------+         
                          |               |         
    admin.mysite.com      |               |         
                +---------+    client     |         
                |         |               |         
                |         |               |         
                |         +-------+-------+         
                |                 |                 
                |                 |                 
        +-------v-------+         |                 
        |               |         |                 
        |               |         |                 
        |  authproxy    |         |   www.mysite.com
        |               |         |                 
        |               |         |                 
        +-------+-------+         |                 
                |                 |                 
                |                 |                 
                |         +-------v-------+         
                |         |               |         
                |         |               |         
                +---------+    site       |         
                          |               |         
                          |               |         
                          +---------------+         

This way you can either:
- Create 2 DNS entries, one for public (pointing to backends) and one for private (pointing to authproxy).
- Chain requests from a load-balancer, splitting public/private sites based on HTTP Host header.


### Rails

Use hostname constraint in your routes.

    match '/admin' => 'secret_stuff#index', :constraints => { :subdomain => 'admin' }


# About headers...
node's http-proxy library downcase all headers prior forwarding. This works fine with most frameworks/http servers, but it is worth mentioning ;)


# Authors

[@lxfontes](https://github.com/lxfontes)

# Credits
Inspired by bitly's [google-auth-proxy](https://github.com/bitly/google_auth_proxy) and [doorman](https://github.com/movableink/doorman).

# License
MIT
