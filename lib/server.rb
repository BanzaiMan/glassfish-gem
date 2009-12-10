#--
#DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
#Copyright 1997-2007 Sun Microsystems, Inc. All rights reserved.
#
#The contents of this file are subject to the terms of either the GNU
#General Public License Version 2 only ("GPL") or the Common Development
#and Distribution License("CDDL") (collectively, the "License").  You
#may not use this file except in compliance with the License. You can obtain
#a copy of the License at https://glassfish.dev.java.net/public/CDDL+GPL.html
#or glassfish/bootstrap/legal/LICENSE.txt.  See the License for the specific
#language governing permissions and limitations under the License.
#
#When distributing the software, include this License Header Notice in each
#file and include the License file at glassfish/bootstrap/legal/LICENSE.txt.
#Sun designates this particular file as subject to the "Classpath" exception
#as provided by Sun in the GPL Version 2 section of the License file that
#accompanied this code.  If applicable, add the following below the License
#Header, with the fields enclosed by brackets [] replaced by your own
#identifying information: "Portions Copyrighted [year]
#[name of copyright owner]"
#
#Contributor(s):
#
#If you wish your version of this file to be governed by only the CDDL or
#only the GPL Version 2, indicate your decision by adding "[Contributor]
#elects to include this software in this distribution under the [CDDL or GPL
#Version 2] license."  If you don't indicate a single choice of license, a
#recipient has the option to distribute your version of this file under
#either the CDDL, the GPL Version 2 or to extend the choice of license to
#its licensees as provided above.  However, if you add GPL Version 2 code
#and therefore, elected the GPL Version 2 license, then the option applies
#only if the new code is made subject to such option by the copyright
#holder.
#++

#
# Invokes and runs GlassFish
#

#Loads all the jars
$LOAD_PATH << "#{File.dirname(__FILE__)}/../lib/java"

require 'java'
require 'glassfish-gem.jar'
require 'akuma.jar'
require 'yaml'
require 'ftools'
require 'version'
require 'config'

module GlassFish
  class Server
    import "org.glassfish.scripting.gem.GlassFishMain"
    import "org.glassfish.scripting.gem.Options"

    java.lang.System.setProperty("addtional.load.path", "#{File.dirname(__FILE__)}/../lib")

    attr_accessor :opts

    def initialize(args, &block)

      unless args[:log_level].nil?
        if args[:log_level] > 4
          puts "Arguments: "
          args.each do |k, v|
            puts "\t#{k}=>#{v}"
          end
        end

        if args[:log_level] > 3
          debug = true
        end

      end

      java.lang.System.getProperties().put("jruby.runtime", JRuby.runtime) unless args[:daemon]

      @opts = Options.new
      @opts.runtimes = args[:runtimes]
      @opts.runtimes_min = args[:runtimes_min]
      @opts.runtimes_max = args[:runtimes_max]
      @opts.environment = args[:environment]
      @opts.port = args[:port]
      @opts.address = args[:address]
      @opts.contextRoot = args[:contextroot]
      @opts.appDir = args[:app_dir]
      @opts.daemon = args[:daemon]
      @opts.pid = args[:pid]
      @opts.log = args[:log]
      @opts.log_console = args[:log_console]
      @opts.domainDir = args[:domain_dir]
      @opts.log_level = args[:log_level]
      @opts.jvm_opts = args[:jvm_options]


      unless args[:grizzly_config].nil?
        args[:grizzly_config].each do |key, val|
          case key
            when "chunking-enabled"
              @opts.grizzlyConfig.chunkingEnabled = val unless val.nil?
            when "request-timeout"
              @opts.grizzlyConfig.requestTimeout = val unless val.nil?
            when "send-buffer-size"
              @opts.grizzlyConfig.sendBufferSize = val unless val.nil?
            when "max-keepalive-connextions"
              @opts.grizzlyConfig.maxKeepaliveConnections = val unless val.nil?
            when "keepalive-timeout"
              @opts.grizzlyConfig.keepaliveTimeout = val unless val.nil?
            when "thread-pool"
              unless val.nil?
                val.each do |k, v|
                  case k
                    when "idle-thread-timeout-seconds"
                      @opts.grizzlyConfig.threadPool.idleThreadTimeoutSeconds = v unless v.nil?
                    when "max-queue-size"
                      @opts.grizzlyConfig.threadPool.maxQueueSize = v unless v.nil?
                    when "max-thread-pool-size"
                      @opts.grizzlyConfig.threadPool.maxThreadPoolSize = v unless v.nil?
                    when "min-thread-pool-size"
                      @opts.grizzlyConfig.threadPool.minThreadPoolSize = v unless v.nil?
                  end
                end
              end
          end
        end
      end

      #Create the app using Rack builder
      if(block)
        app = Rack::Builder.new(&block).to_app
        app = Rack::CommonLogger.new(@app) if debug
        if app.nil?
          app = block
        end
        @opts.app = app;

        java.lang.System.getProperties().put("glassfish.rackupApp", app)
      end
    end

    def self.start(args, &block)
      #Validate the command line options
      args = GlassFish::Config.init_opts.merge! args
      Config.new.validate! args
      new(args, &block).start!
    end

    def start
      GlassFishMain.start @opts
    end
    alias :start! :start

    def stop
      GlassFishMain.start @opts
    end

    def name
      "GlassFish v3 server"
    end

    alias :to_s :name
  end
end