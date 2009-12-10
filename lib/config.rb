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

require 'java'
require 'yaml'
require 'ftools'
require 'socket'

module GlassFish
  class Config
    LOG_LEVELS = (0..7)
    PID_FILE = Dir.pwd+File::SEPARATOR+"tmp"+File::SEPARATOR+"pids"+File::SEPARATOR+"glassfish"
    DEFAULT_JVM_OPTS = "-server -Xmx512m -XX:MaxPermSize=192m -XX:NewRatio=2 -XX:+DisableExplicitGC -Dhk2.file.directory.changeIntervalTimer=6000";

    def self.init_opts
      {
        :runtimes     => 1,
        :runtimes_min => 1,
        :runtimes_max => 1,
        :contextroot  => '/',
        :environment  => "development",
        :app_dir      => Dir.pwd,
        :port         => 3000,
        :address      => "0.0.0.0",
        :pid          => nil,
        :log          => nil,
        :log_console  => false,
        :log_level    => 3,
        :daemon       => false,
        :jvm_options  => nil        
      }
    end


    # Validates the configuration options. If it can will revert to default else
    # fail
    def validate! config
      # http configuration
      # port
      begin
        server = TCPServer.new config[:port]
      rescue
        STDERR.puts "#{config[:address]}:#{config[:port]}: " + $!
        #TODO: we should give an option of ephemeral port support
        exit(1)
      end
      server.close

      # daemon
      if(config[:daemon])
        os = java.lang.System.getProperty("os.name").downcase
        version = java.lang.System.getProperty("os.version")
        #check the platform, Currently daemon mode works only on linux and
        #solaris
        if(!os.include?("linux") and !os.include?("sunos"))
          Config.fail "You are running on #{java.lang.System.getProperty("os.name")}  #{version}. Currently daemon mode only works on Linux or Solaris platforms!"
        end

        # In daemon mode you can't log to console. Let's fail and let user spcifiy the log file explicitly
	      if(config[:log_console])
	        Config.fail "Daemon mode detected, console logging is disabled in daemon mode. You must provide path to log file with --log|-l option in daemon mode."
        end


        if(config[:jvm_options].nil?)
          config[:jvm_options] = DEFAULT_JVM_OPTS
        end
        if(config[:pid].nil?)
          config[:pid] = PID_FILE
	      end

        Config.absolutize config[:app_dir], config[:pid]
      end

      # log_level
      if not (0..7).include?(config[:log_level])
        STDERR.puts "Invalid log level #{config[:log_level]}. Chose a number between 0 to 7."
        Config.fail "\t0 OFF\n\t1 SEVERE \n\t2 WARNING\n\t3 INFO(default)\n\t4 FINE\n\t5 FINER\n\t6 FINEST\n\t7 ALL\n"
      end

      if config[:runtimes] > config[:runtimes_max]
        puts "Initial number of runtimes #{config[:runtimes]} is > max runtime #{config[:runtimes_max]}.\nIncreasing runtimes-max to #{config[:runtimes]}"
        config[:runtimes_max] = config[:runtimes]
      end

      # JRuby runtime
      runtimes_err = " Invalid runtime configuration, initial:#{config[:runtimes]}, min:#{config[:runtimes_min]}, max:#{config[:runtimes_max]}."
      err = false
      if(config[:runtimes] < 1 || config[:runtimes] > config[:runtimes_max] || config[:runtimes] < config[:runtimes_min])
        err = true;
        runtimes_err +=  "\n\tinitial runtime must be > 0, <= runtimes-max and >= runtimes-min."
      end
      if(config[:runtimes_min] < 1 || config[:runtimes_min] > config[:runtimes] || config[:runtimes_min] > config[:runtimes_max])
        err = true;
        runtimes_err += "\n\truntimes-min must be > 0, <=runtimes-max and <= initial_runtmes"
      end
      if(config[:runtimes_max] < 1 || config[:runtimes_max] < config[:runtimes_min] || config[:runtimes_max] < config[:runtimes])
        err=true
        runtimes_err += "\n\truntimes-max must be > 0, >=runtimes-min and >= initial_runtmes"
      end
      if(err)
        Config.fail runtimes_err
      end


      # contextroot
      # There is not much to validate here. For now we leave it as it is

      # log configuration


      # log-file
      if(config[:log].nil? or config[:log].empty?)
        config[:log] = File.join(config[:app_dir], "log", config[:environment]+".log")
      end

      if !File.exists?(config[:log]) and !config[:log_console]
        puts "Log file #{config[:log]} does not exist. Creating a new one..."
        parent = File.dirname(config[:log])
        if(!File.exists?parent)
          FileUtils.mkdir_p parent
        end
        file = File.new(config[:log], "w")
        file.close
      end


      # pid file
      #
      if(!config[:pid].nil? and !config[:daemon])
            GlassFish::Config::fail("--pid option can only be used with --daemon.")
      end

      #TODO: validate JVM options?

      # By this time we know all is good. Now lets create the domain directory
      domaindir = File.join(config[:app_dir], "tmp", ".glassfish")
      config[:domain_dir] = File.expand_path(domaindir)

      if !check_domain_dir?domaindir
        exit -1
      end
    end

    def self.fail(message)
      STDERR.puts "ERROR: #{message}"
      STDERR.puts "Type 'glassfish -h' to get help"
      Kernel.exit -1
    end

    def self.absolutize(base, path)
      if path.nil?
        return nil
      end
      p = Pathname.new path
      if(!p.absolute?)
        path = File.join(base, path)
      end
      path
    end


    private

    def check_domain_dir?(domain_dir)
      #create Glassfish domain directory if it does not exist
      unless File.exist? domain_dir
        File.makedirs(domain_dir)
        return true
      end

      config_dir = File.join(domain_dir, "config")
      unless File.exist? config_dir
        File.makedirs(config_dir)
        return true
      end

      if !File.writable_real?config_dir
        puts "ERROR: GlassFish temporary directory: #{config_dir} not writable. Please give write permission to proceed."
        return false
      end

      #glassfish gem <=0.9.5 created domain.xml, this causes latter version
      #to fail so removing this as no more needed
      if(File.exist?(config_dir) and File.exist?(File.join(config_dir, "domain.xml")))
        FileUtils.rmtree config_dir
      end
      true
    end
  end
end
