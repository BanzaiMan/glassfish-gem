# Glassfish gem

## Introduction

GlassFish gem is a lightweight and robust deployment solution for
Ruby on Rails applications deployed on JRuby runtime. It is based
on GlassFish v3 application server.

GlassFish v3 is a Java based application server that allows deployment, 
administration and monitoring of JavaEE as well as dynamic languages based web 
frameworks such as Ruby On Rails, Grails etc.

GlassFish gem is based on GlassFish v3 nucleus. GlassFish v3 nucleus is the core module of GlassFish v3.

For more information on GlassFish v3 application server see [GlassFish project page](https://glassfish.dev.java.net/).

## Requirement
[JDK 6](http://java.sun.com/javase/downloads/index.jsp) is required.

## Supported Rack-based frameworks

* Rails
* Merb
* Sinatra

## Getting Started

1. Install the gem:

    gem install glassfish

2. Run glassfish in the top directory of your Rails or Merb application:

    a. `jruby -S glassfish`

    b. For applications that use Bundler:

        jruby -S bundle exec glassfish

## Usage

GlassFish gem's `glassfish` command autodetects the application you trying to
run on it. Internally it uses Grizzly handler to plug into Rack interface of
the application frameworks such as Rails, Merb or Sinatra.

    $ glassfish

That's all you need to run your application.

    $ glassfish -h

To run your rackup script

    $ rackup -s Glassfish

or
    $ glassfish


## Synopsis
	
	glassfish: GlassFish v3 server for Rack based frameworks such as: Rails,
	Merb, Sinatra...

    Usage:
    glassfish [OPTION] APPLICATION_PATH

    -h, --help:             show help

    -c, --contextroot PATH: change the context root (default: '/')

    -p, --port PORT:        change server port (default: 3000)

    -a, --address HOST:     bind to HOST address (default: 0.0.0.0)

    -e, --environment ENV:  change rails environment (default: development)

    -n --runtimes NUMBER:   Number of JRuby runtimes to create initially

    --runtimes-min NUMBER:  Minimum JRuby runtimes to create

    --runtimes-max NUMBER:  Maximum number of JRuby runtimes to create

    -d, --daemon:           Run GlassFish as daemon. Currently works with
                            Linux and Solaris OS.

    -P, --pid FILE:         PID file where PID will be written. Applicable
                            when used with -d option. The default pid file
                            is tmp/pids/glassfish-<PID>.pid

    -l, --log FILE:         Log file, where the server log messages will go.
                            By default the server logs go to
                            log/development.log file. To see the logs on
                            console run with -l option without any argument.

    --log-level LEVEL:      Log level 0 to 7, or equivalent name as string.
                            Default is 3 (or INFO).
                            0 (OFF), 1 (SEVERE), 2 (WARNING), 3 (INFO),
                            4 (FINE), 5 (FINER), 6 (FINEST), 7 (ALL).

    --config FILE:          Configuration file location. Use glassfish.yml
                            as template. Generate it using 'gfrake config'
                            command.

    APPLICATION_PATH (optional): Path to the application to be run (default:
    current).

    For further configuration, run GlassFish rake command 'gfrake -T'

## Configuration

	$ jruby -S gfrake -T
	
	rake clean    # Clean GlassFish generated temporary files (tmp/.glassfish)
	rake config   # Generate a configuration file to customize GlassFish gem
	rake version  # Display version of GlassFish gem
	
* Note: Although help screen shows `rake` command, you need to use `gfrake` instead.

* `gfrake config` will place `glassfish.yml` in the application's config directory.
`glassfish.yml` contains default options. Use it as template.
You can also use `--config` option with the `glassfish` command

## Application auto-detection

Rails, Merb and Sinatra applications are detected automatically and configured appropriately.
You can provide a rack-up script `*.ru` in to the application directory to plug in any other framework.

Some key points:

* Rails version < 2.2 is single threaded, for improved scaling you can  
  configure the JRuby runtime pool using `--runtimes`, `--runtimes-min` or
  `--runtimes-max` options.
* Multi-thread-safe execution (as introduced in Rails 2.2 or for Merb) is 
  detected and runtime pooling is disabled. You would still need to tell Rails 
  to enable multi-threading by commenting out the following line from 
  `config/environments/production.rb`.
  
  `#config.threadsafe!`
  
  Or you can simply call `config.threadsafe!` form any Rails initialization
  script.

=== Known Issues

* Running `glassfish` in a directory that is neither a Rails or Merb
  application does not report a meaningful error.
  See [this issue](https://glassfish.dev.java.net/issues/show_bug.cgi?id=6744).


=== Source

=== License

GlassFish v3 gem is provided with [CDDL 1.0 and GPL 2.0 dual license](https://glassfish.dev.java.net/public/CDDL+GPL.html).
