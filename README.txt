= GlassFish v3 server for Rack based web frameworks (Rails, Merb, ...)

GlassFish gem is a lightweight and robust deployment solution for
Ruby on Rails applications deployed on JRuby runtime. It is based
on GlassFish v3 application server.

GlassFish v3 is a Java based application server that allows deployment, 
administration and monitoring of JavaEE as well as dynamic languages based web 
frameworks such as Ruby On Rails, Grails etc.

GlassFish gem is based on GlassFish v3 nucleus. GlassFish v3 nucleus is the core
module of GlassFish v3.

For more information on GlassFish v3 application server see 
https://glassfish.dev.java.net/v3.

== Requires JDK 6
Get JDK 6 from here[http://java.sun.com/javase/downloads/index.jsp]

== Supported Rack based frameworks

* Rails
* Merb
* Sinatra (coming up...)

== Getting Started

1. Install the gem: <tt>gem install glassfish</tt>.
2. Run glassfish in the top directory of your Rails or Merb application: 
<tt>glassfish</tt>.

== Usage

GlassFish gem's +glassfish+ command autodetects the application you trying to 
run on it. Internally it uses Grizzly handler to plugin to Rack interface of 
the application frameworks such as Rails or Merb.

    $ glassfish

That's all you need to run your application.

    $glassfish -h

    Synopsis
    --------
    glassfish: GlassFish v3 server for rails, merb, sintra applications


    Usage:
    ------
    glassfish [OPTION] APPLICATION_PATH

    -h, --help:             show help

    -c, --contextroot PATH: change the context root (default: '/')

    -p, --port PORT:        change server port (default: 3000)

    -e, --environment ENV:  change rails environment (default: development)

    -n --runtimes NUMBER:   Number of JRuby runtimes to crete initially

    --runtimes-min NUMBER:  Minimum JRuby runtimes to crete

    --runtimes-max NUMBER:  Maximum number of JRuby runtimes to crete

    APPLICATION_PATH (optional): Path to the application to be run (default:
    current).

== Configuration

=== Rails applications

Rails applications are detected automatically and configured appropriately.

Some key points:

* Rails version < 2.2 is single threaded, for improved scaling you can  
  configure the JRuby runtime pool using <tt>--runtimes, --runtimes-min or 
  --runtimes-max</tt> options.
* Multi-thread-safe execution (as introduced in Rails 2.2 or for Merb) is 
  detected and runtime pooling is disabled.

=== Merb applications

Merb applications are detected automatically.

=== Other Rack-based applications

TBD

=== Configuration TODOs

* Document how to create JDBC resources and conection pools

== Known Issues

* Running <tt>glassfish</tt> in a directory that is neither a Rails or Merb
  application does not report a meaningful error.
  See this issue[https://glassfish.dev.java.net/issues/show_bug.cgi?id=6744]


== Source

You can get the GlassFish source using svn, in any of the following ways:

svn co https://svn.dev.java.net/svn/glassfish-scripting/trunk/rails/v3/gem

== License

GlassFish v3 gem is provided with CDDL 1.0 and GPL 2.0 dual license. For 
details see https://glassfish.dev.java.net/public/CDDL+GPL.html.
