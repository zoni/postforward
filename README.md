Postforward
===========

*Postfix SRS forwarding agent.*


About
-----

Postforward is a mail forwarding utility which aims to compliment the
[Postfix Sender Rewriting Scheme daemon (PostSRSd)](https://github.com/roehling/postsrsd).

The downside of using PostSRSd is that all mail is naively rewritten, even
when no forwarding is actually performed. Such rewritten Return-Path
addresses may confuse sieve scripts and other mail filtering software.

This is where Postforward comes in. Instead of rewriting all incoming mail
regardless of final destination, mail systems may be configured to pipe
mail into Postforward only when forwarding needs to happen, leaving
non-forwarded mail unaltered by PostSRSd. Postforward will rewrite
envelope addresses for piped mail using PostSRSd itself and re-inject
these messages back into the queue, destined for the forwarding
recipient(s).


Project status
--------------

This software is actively maintained but considered feature-complete. No
changes or new features are planned except as required to fix any
potential issues that may come up in the future.


Installation
------------

I no longer provide pre-compiled binaries for small-time projects of mine
so you will have to build from sources yourself. If you have an up-to-date
[Go toolchain](https://golang.org/dl/) installed on your system this is as
simple as:

```sh
go get -d github.com/zoni/postforward
cd ~/go/src/github.com/zoni/postforward
make
```

This will create a binary called `postforward` which may be installed on
the target server(s). Go applications are statically linked by default so
no additional dependencies are needed.


Configuration
-------------

Postforward relies on mail being delivered via stdin so this implies
delivery using Postfix's `local(8)` or `pipe(8)` delivery agents. One such
method may be achieved by configuring a pipe forward in `/etc/aliases`:

```
forwarder: "|/usr/local/bin/postforward someuser@another.host.tld"
```

*(Note: when running PostSRSd on a different host or port, use the
`--srs-addr` flag to set the correct address here.)*

In `main.cf`, configure `recipient_canonical_maps` and
`recipient_canonical_classes` as
[recommended by PostSRSd](https://github.com/roehling/postsrsd#configuration)
but *do not* set `sender_canonical_maps` or `sender_canonical_classes`.

-----------------------------------------------------------------------------

Note that in case of process errors, postfix bounces emails with the full
process argument string in the DSN message which could leak internal
information such as the forwarding address. This is default postfix
behavior for the local and pipe delivery agents.

If this is undesirable,
[local_delivery_status_filter](http://www.postfix.org/postconf.5.html#local_delivery_status_filter)
may be configured with a PCRE map such as the following to hide this
information (omit the `$2` in the final entry to also strip command
output):

```
/^(2\S+ deliver(s|ed) to file).+/    $1
/^(2\S+ deliver(s|ed) to command).+/ $1
/^(\S+ Command died with status \d+):.*(\. Command output:.*)/ $1$2
```


Performance
-----------

Using Postforward introduces additional overhead caused by forking of
processes which wouldn't happen with direct use of PostSRSd. Unless you
are forwarding very large volumes of mail this extra overhead is likely
negligible in relation to the total processing cost of a complete email
transaction.

Postforward takes care not to buffer entire messages in memory and is
therefor safe to use on very large emails.  Only message headers are
buffered in memory for processing, body content is streamed directly into
sendmail.


License
-------

2-Clause BSD. See [LICENSE.txt](LICENSE.txt) for the full license text.
