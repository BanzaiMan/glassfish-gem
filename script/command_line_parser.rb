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
require 'java'

#
# Parses command line options
#
class CommandLineParser
  PID_FILE    = Dir.pwd+File::SEPARATOR+"tmp"+File::SEPARATOR+"pids"+File::SEPARATOR+"glassfish.pid"

  def init_opts
    @@config ||= {
            :runtimes     => 1,
            :runtimes_min => 1,
            :runtimes_max => 1,
            :contextroot  => '/',
            :environment  => "development",
            :app_dir      => Dir.pwd,
            :port         => 3000,
            :pid          => PID_FILE,
            :log          => nil,
            :log_level    => 1,
            :daemon       => false,            
    }
  end

  def parse
    config = init_opts
    opts = GetoptLong.new(
            [ '--port', '-p', GetoptLong::REQUIRED_ARGUMENT ],
            [ '--environment', '-e', GetoptLong::REQUIRED_ARGUMENT ],
            [ '--contextroot', '-c', GetoptLong::REQUIRED_ARGUMENT ],
            [ '--daemon', '-d', GetoptLong::NO_ARGUMENT ],
            [ '--pid', '-P', GetoptLong::REQUIRED_ARGUMENT ],
            [ '--log', '-l', GetoptLong::REQUIRED_ARGUMENT ],
            [ '--log-level', GetoptLong::REQUIRED_ARGUMENT ],
            [ '--runtimes', '-n', GetoptLong::REQUIRED_ARGUMENT ],
            [ '--runtimes-min', GetoptLong::REQUIRED_ARGUMENT ],
            [ '--runtimes-max', GetoptLong::REQUIRED_ARGUMENT ],
            [ '--version', '-v', GetoptLong::NO_ARGUMENT ],
            [ '--help', '-h', GetoptLong::NO_ARGUMENT ]
    )

    opts.each do |opt, arg|
      case opt
      when '--version'
        require 'version'
        puts "GlassFish gem version: #{GlassFish::VERSION::STRING}\nhttp://glassfishgem.rubyforge.org"
        exit(0)
      when '--help'
        RDoc::usage
      when '--contextroot'
        config[:contextroot] = arg
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
        os = java.lang.System.getProperty("os.name").downcase
        version = java.lang.System.getProperty("os.version")
        #check the platform, Currently daemon mode works only on linux and solaris
        if(os.include?("linux") or os.include?("solaris"))
          config[:daemon] = true
        else
          fail "You are running on #{java.lang.System.getProperty("os.name")} #{version}. Currently daemon mode only works on Linux or Solaris platforms!"
        end
      when '--pid'
        if(!ARGV.include?'-d' and !ARGV.include?'--daemon')
          fail("--pid option can only be used with --daemon.")
        end
        if not File.exists?(arg)
          puts "PID file #{arg} does not exist. Creating a new one..."
          f = FileUtils.touch arg
        end
        config[:pid] = File.expand_path arg
      when '--log'
        if not File.exists?(arg)
          puts "Log file #{arg} does not exist. Creating a new one..."
          FileUtils.touch arg
        end
        config[:log] = File.expand_path arg
      when '--log-level'
        if (arg.eql?"0" or arg.eql?"1" or arg.eql?"2" or arg.eql?"3" or arg.eql?"4" or arg.eql?"5" or arg.eql?"6" or arg.eql?"7")
          config[:log_level] = arg.to_i
        else
          STDERR.puts "Invalid --log-level #{arg}. Chose a number between 0 to 7."
          fail "\t0 OFF\n\t1 INFO (default)\n\t2 WARNING\n\t3 SEVERE\n\t4 FINE\n\t5 FINER\n\t6 FINEST\n\t7 ALL\n"
        end

      end
    end

    if(config[:log] == nil)
        config[:log] = File.join(config[:app_dir], "log", config[:environment]+".log")
    end

    domaindir = File.join(config[:app_dir], "tmp", ".glassfish")
    config[:domain_dir] = File.expand_path(domaindir)

    if !setup_temp_domain?File.join(domaindir, "config")
      puts "ERROR: Failed to create GlassFish domain directory: #{domaindir}"
      exit -1
    end
    

    config[:app_dir] = ARGV.shift unless ARGV.empty?

    config
  end

  private

  def setup_temp_domain? config_dir
    if !File.exist? config_dir
      FileUtils.mkdir_p config_dir
    end
    if !same_version?config_dir
      return check_domain_dir? config_dir
    end
    true
  end

  #
  #Create a domain directory and copy the domain.xml and logging.properties there.
  #This will take care of infamous bug that causes people to run glassfish gem as sudo
  #if jruby is installed as root
  #
  def check_domain_dir?(config_dir)
    if !File.writable_real?config_dir
      return false;
    end
    src = File.dirname(__FILE__)+File::SEPARATOR+".."+File::SEPARATOR+"domains"+File::SEPARATOR+"domain1"+File::SEPARATOR+"config"
    File.cp(File.join(src,"domain.xml"), config_dir)
    File.cp(File.join(src,"logging.properties"), config_dir)
  end

  #
  #Returns true if there is glasfish_gem_version.yml file and has the same version as the glassfish gem. Otherwise
  #creates a new file and returns false so that rest of the stuff can be created
  #
  def same_version?(config_dir)
    f = File.join(config_dir, 'glassfish_gem_version.yml')
    if !File.exist? f
      src = File.join(File.dirname(__FILE__), "..", "domains", "domain1", "config", "glassfish_gem_version.yml")
      File.cp src, config_dir
      return false
    end
    file = File.open(f)
    data = YAML::load(file)
    if not data.key?'glassfish'
      return false; #this is probably corrupted, return false so that a new one can be placed
    end
    version = data['glassfish'].fetch('version', nil)
    if(version == nil)
      return false
    end
    return version.eql?GlassFish::VERSION::STRING
  end

  def fail(message)
    STDERR.puts "ERROR: #{message}"
    STDERR.puts "Type 'glassfish -h' to get help"
    Kernel.exit -1
  end

  class OS

    # universal-darwin9.0 shows up for RUBY_PLATFORM on os X leopard with the bundled ruby.
    # Installing ruby in different manners may give a different result, so beware.
    # Examine the ruby platform yourself. If you see other values please comment
    # in the snippet on dzone and I will add them.

    def is_mac?
      RUBY_PLATFORM.downcase.include?("darwin")
    end

    def is_windows?
       RUBY_PLATFORM.downcase.include?("mswin")
    end

    def is_linux?
       RUBY_PLATFORM.downcase.include?("linux")
    end

    def is_solaris?
       RUBY_PLATFORM.downcase.include?("solaris")
    end

  end


end
