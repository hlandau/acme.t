# ACME Client Utilities

acmetool is an easy-to-use command line tool for automatically acquiring
certificates from ACME servers (such as Let's Encrypt). Designed to flexibly
integrate into your webserver setup to enable automatic verification. Unlike
the official Let's Encrypt client, this doesn't modify your web server
configuration.

You can perform verifications using port 80 or 443 (if you don't yet have a
server running on one of them); via webroot; by configuring your webserver to
proxy requests for `/.well-known/acme-challenge/` to a special port (402) which
acmetool can listen on; or by configuring your webserver not to listen on port
80, and instead running acmetool's built in HTTPS redirector (and challenge
responder) on port 80.

You can run acmetool on a cron job to renew certificates automatically.  The
preferred certificate for a given hostname is always at
`/var/lib/acme/live/HOSTNAME/{cert,chain,fullchain,privkey}`. You can configure
acmetool to reload your webserver automatically when it renews a certificate.

acmetool is intended to be "magic-free". All of acmetool's state is stored in a
simple, comprehensible directory of flat files. [The schema for this directory
is documented.](https://github.com/hlandau/acme.t/blob/master/SCHEMA.md)

acmetool is intended to work like "make". The state directory expresses target
domain names, and whenever acmetool is invoked, it ensures that valid
certificates are available to meet those names. Certificates which will expire
soon are renewed. acmetool is thus idempotent and minimises the use of state.

## Getting Started

You will need Go installed.

    $ git clone https://github.com/hlandau/acme.t
    $ cd acme.t
    $ make && sudo make install
    $ sudo acmetool quickstart
    $ sudo acmetool want example.com www.example.com

## Introduction

- A command line tool for acquiring certificates using a certificate storage
  repository to automatically determine what certificates need to be requested.

- Acquiring a certificate is as simple as this:

  `# acmetool want example.com`

  If successfully acquired, the certificate will be placed in
  `/var/lib/acme/live/example.com/{cert,chain,fullchain,privkey}`.

  Running `acmetool --batch` as root on a cronjob will allow it to
  automatically reacquire certificates before they expire. The certificate data
  in `/var/lib/acme/live/example.com` will be updated automatically with the
  new certificate. acmetool can optionally invoke a shell script after having
  changed certificates if you need to reload a webserver.

- Works with Let's Encrypt.

- acmetool is designed to work like `make`. A filesystem-based certificate
  repository expresses target domain names, and whenever acmetool is invoked,
  it ensures that valid certificates are available to meet those names.
  Certificates which will expire soon are renewed. The certificate matching
  each target is symlinked into `/var/lib/acme/live/DOMAIN`, so the right
  certificate for a given domain is always at `/var/lib/acme/live/DOMAIN`.

  acmetool is thus idempotent and it minimises the use of state. All state is
  explicitly kept in the certificate repository. There are essentially no
  proprietary file formats or configuration or state files; only a repository
  of certificates, a repository of ACME account keys and a set of targets.  On
  each invocation, ACME figures out which certificates satisfy which targets
  and obtains certificates as necessary.

  [Details on the state directory format.](https://github.com/hlandau/acme/blob/master/SCHEMA.md)

- Contains an ACME client library which can be used independently. [![GoDoc](https://godoc.org/github.com/hlandau/acme/acmeapi?status.svg)](https://godoc.org/github.com/hlandau/acme/acmeapi)

## Licence

    © 2015 Hugo Landau <hlandau@devever.net>    MIT License

