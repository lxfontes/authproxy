# OAuth 2 Reverse Proxy

Secure administration panels via a single authentication point using Google as OAuth provider.  
It handles multiple domains and multiple backends at once, taking care of forwarding proper HTTP headers (X-Forwarded-For / Proto) and introducing `X-Forwarded-User`.  
Also supports Google Apps domains.


# Setting up

Follow these [steps](https://developers.google.com/accounts/docs/OAuth2) to get a 'Project' setup.  
Set the 'Authorized Redirect URI' to `http://<secured_domain>/authproxy/google/return`

Save the 'Client ID' and 'Client Secret', they will be required to setup the proxy. The configuration looks like:

	[server]
	bind_ip = "0.0.0.0"
	bind_port = 80
	# change this
	cookie_secret = "monstah"
	# google apps domain, or leave it blank
	auth_domain = "mysite.com"

	[domains]
	  [domains.example1]
	  host = "admin.mysite.com"
	  upstream = ["internal1.mysite.com", "internal2.mysite.com:8080"]
	  client_id = "__clientID__"
	  client_secret = "TWWWWz-EWWWWlxfX"

	  # multiple domains
	  [domains.example2]
	  host = "admin.secondsite.com"
	  upstream = ["internal3.mysite.com"]
	  client_id = "__clientID__"
	  client_secret = "TWWWWz-EWWWWlxfX"


Authproxy takes over the following routes; these _will not_ be proxied to your application:

*Login* `http://<secured_domain>/authproxy/google`  
*Callback URL* `http://<secured_domain>/authproxy/return`  
*User Check* `http://<secured_domain>/authproxy/user`

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
