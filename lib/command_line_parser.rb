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

require 'rdoc_usage'
require 'getoptlong'
require 'pathname'
require 'config'
require 'java'

#
# Parses command line options
#
module GlassFish
  class CommandLineParser
    attr_accessor :config


    def parse

      check_java

      @config = Config.init_opts

      opts = GetoptLong.new(
      [ '--port', '-p', GetoptLong::REQUIRED_ARGUMENT ],
      [ '--address', '-a', GetoptLong::REQUIRED_ARGUMENT ],
      [ '--environment', '-e', GetoptLong::REQUIRED_ARGUMENT ],
      [ '--contextroot', '-c', GetoptLong::REQUIRED_ARGUMENT ],
      [ '--config', GetoptLong::REQUIRED_ARGUMENT ],
      [ '--daemon', '-d', GetoptLong::NO_ARGUMENT ],
      [ '--pid', '-P', GetoptLong::REQUIRED_ARGUMENT ],
      [ '--log', '-l', GetoptLong::OPTIONAL_ARGUMENT ],
      [ '--log-level', GetoptLong::REQUIRED_ARGUMENT ],
      [ '--runtimes', '-n', GetoptLong::REQUIRED_ARGUMENT ],
      [ '--runtimes-min', GetoptLong::REQUIRED_ARGUMENT ],
      [ '--runtimes-max', GetoptLong::REQUIRED_ARGUMENT ],
      [ '--version', '-v', GetoptLong::NO_ARGUMENT ],
      [ '--help', '-h', GetoptLong::NO_ARGUMENT ]
      )

      config_file = File.join(config[:app_dir], "config", "glassfish.yml")
      opts.each do |opt, arg|
        case opt
        when '--version'
          require 'version'
          puts "#{GlassFish::FULLVERSION}"
          exit(0)
        when '--help'
          RDoc::usage
        when '--contextroot'
          config[:contextroot] = arg
        when '--address'
          config[:address] = arg
        when '--port'
          config[:port] = arg.to_i
        when '--environment'
          config[:environment] = arg
        when '--runtimes'
          config[:runtimes] = arg.to_i
        when '--runtimes-min'
          config[:runtimes_min] = arg.to_i
        when '--runtimes-max'
          config[:runtimes_max] = arg.to_i
        when '--daemon'
          config[:daemon] = true
        when '--pid'
          config[:pid] = File.expand_path arg
        when '--log'
          #if user just mentioned 'glassfish -l', it means he wants to log the messages on console
          if(arg.nil? or arg.empty?)
            config[:log_console] = true
          else
            config[:log] = File.expand_path arg
          end
        when '--log-level'
          config[:log_level] = arg.to_i
        when '--config'
          config_file = arg
        end
      end


      config[:app_dir] = ARGV.shift unless ARGV.empty?

      #Read the config file from config/glasfish.yml
      config_file = Config::absolutize config[:app_dir],config_file
      read_glassfish_config(config_file, config)

      config

    end

    private

    # Read glassfish config file from config/glassfish.yml. CLI options will
    # override the glassfish.yml configurations
    def read_glassfish_config(cfile, config)

      #If there is no config file we return
      if(!File::exists?(cfile))
        return config
      end

      puts "Parsing config file: #{cfile}"
      data = YAML::load(File::open(cfile))

      data.each do |opt, arg|
        case opt
        when 'http'
          val = arg['port']
          config[:port] = val.to_i unless val.nil?

          val = arg['address']
          config[:address] = val unless val.nil?

          val = arg['contextroot']
          config[:contextroot] = val unless val.nil?


          config[:grizzly_config] = arg['grizzly'] unless arg['grizzly'].nil?

        when 'log'
          val = arg['log-file']
          unless val.nil?
            config[:log] = Config::absolutize config[:app_dir], val
          end

          val = arg['log-level']
          config[:log_level] = val.to_i unless val.nil?
        when 'jruby-runtime-pool'
          config[:runtimes] = arg['initial'] unless arg['initial'].nil?
          config[:runtimes_min] = arg['min'] unless arg['min'].nil?
          config[:runtimes_max] = arg['max'] unless arg['max'].nil?
        when 'daemon'
          config[:daemon] = arg['enable'] unless arg['enable'].nil?
          if(!arg['pid'].nil?)
            if(!config[:daemon])
              Config::fail("glassfish.yml has\n daemon:\n\tpid: #{arg['pid']}\nThe pid option can only be used when daemon is set enable: true.")
            else
              config[:pid] = File.expand_path arg['pid']
            end
          end

          #CLI option are overriden by glassfish.yml settings
          if(!data['daemon'].nil? and (data['daemon'] or config[:daemon]))
            config[:jvm_options] = arg['jvm-options'] unless  arg['jvm-options'].nil?
          else
            STDERR.puts "Ignoring JVM options #{arg}. JVM options can only be passed in daemon mode. To use these, enable daemon mode"
          end
        when 'environment'
          config[:environment] = arg unless arg.nil?
        end
      end
    end

    def check_java
      begin
          java.lang.Class.forName("javax.xml.ws.Service")
      rescue
          #It is not Java6, fail
          STDERR.puts "ERROR: You are running, Java version: "+java.lang.System.getProperty("java.version")+"."
          STDERR.puts "ERROR: GlassFish gem needs Java ver. 6.0 or higher!"
          puts "Please install JDK 6 from: http://java.sun.com/javase/downloads/index.jsp"
          exit(1);
      end
    end

  end
end
