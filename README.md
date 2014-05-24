[Prosody][1] XMPP server with full-featured and secure setup, running in a [docker][2]
container.

Features supported out of the box:

* conferences
* file transfer
* smacks and carbon modules
* PFS (Perfect Forward Secrecy) for message security

## Prerequisites

Install [docker][2].

## Building the image

In order to create your own server, create a new directory. Inside, create a _Dockerfile_ which inherits from this image. Example:

    FROM mazzolino/prosody
    CMD chown prosody /var/lib/prosody && prosodyctl start

(Note: The CMD line is needed because of a [weird behaviour in Docker][3].)

Then, create two subfolders:

    mkdir certs conf.d

Get an SSL certificate (e.g. from StartSSL) and put the cert and key into the certs folder:

    cp my-domain.crt certs/ssl.cert
    cp my-domain.key certs/ssl.key

(NOTE: The certificate file (`ssl.cert`) should contain the complete SSL certificate chain as needed.
E.g. for StartSSL, you have to concatenate your certificate, the class1 or class2 sub certificate and the CA certificate into it.)

Now you can build the final container image. Choose a name for your container image instead of `xmpp.example.com`. Also, replace `example.com` with your own domain.

    docker build -t xmpp.example.com .

## Running

Start your server like this. Replace `xmpp.example.com` with the name of the image you built in the last step. Replace `example.com` with your own domain.

    docker run -d -p 5222:5222 -p 5269:5269 -p 5280:5280 -p 5347:5347 -v .prosody:/var/lib/prosody -e "XMPP_DOMAIN=example.com" xmpp.example.com

You need to forward the above ports in your firewall to this machine.

Prosody's data will be stored in the directory _.prosody_ inside the current directory, so make sure to keep that.

## Adding users

You can add user logins like this. Replace `xmpp.example.com` with the name of your image. Also, replace `username`, `example.com` and `password` accordingly:

    docker run --rm -v .prosody:/var/lib/prosody xmpp.example.com prosodyctl register username example.com password

## Add DNS records

You need to add SRV records to your domain so your server can be connected by other clients and servers correctly. See [DNS configuration in Jabber/XMPP][4].

## Customization

Prosody's main configuration file _prosody.cfg.lua_ is not customizable from inherited images. You can add custom configuration files in the _conf.d_ subdirectory instead.

See the [configuration documentation][5] for possible values.


  [1]: https://prosody.im/
  [2]: https://www.docker.io/
  [3]: https://github.com/dotcloud/docker/issues/5147#issuecomment-43572198
  [4]: https://prosody.im/doc/dns
  [5]: https://prosody.im/doc/configure
