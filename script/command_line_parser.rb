require 'rdoc_usage'
require 'getoptlong'
class CommandLineParser
  def init_opts
    @@config ||= {
            :runtimes     => '1',
            :runtimes_min => '1',
            :runtimes_max => '1',
            :contextroot  => '/',
            :environment  => "development",
            :app_dir      => Dir.pwd,
            :port         => 3000
    }
  end

  def parse
    config = init_opts
    opts = GetoptLong.new(
            [ '--port', '-p', GetoptLong::REQUIRED_ARGUMENT ],
            [ '--environment', '-e', GetoptLong::REQUIRED_ARGUMENT ],
            [ '--contextroot', '-c', GetoptLong::REQUIRED_ARGUMENT ],
            [ '--runtimes', '-n', GetoptLong::REQUIRED_ARGUMENT ],
            [ '--runtimes_min', GetoptLong::REQUIRED_ARGUMENT ],
            [ '--runtimes_max', GetoptLong::REQUIRED_ARGUMENT ],
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
        config[:runtimes] = arg
      when '--runtimes-min'
        config[:runtimes_min] = arg
      when '--runtimes-max'
        config[:runtimes_min] = arg
      end
    end    
    config[:app_dir] = ARGV.shift unless ARGV.empty?
    config
  end
end
