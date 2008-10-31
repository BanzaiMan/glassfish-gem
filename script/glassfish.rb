require 'glassfish.jar'

module GlassFish
  class Server
    import com.sun.enterprise.glassfish.bootstrap.ASMain    
    def startup(args)
      #set jruby runtime property
      java.lang.System.setProperty("jruby.runtime", args[:runtimes].to_s)
      java.lang.System.setProperty("jruby.runtime.min", args[:runtimes_min].to_s)
      java.lang.System.setProperty("jruby.runtime.max", args[:runtimes_max].to_s)
      java.lang.System.setProperty("rails.env", args[:environment])
      java.lang.System.setProperty("jruby.gem.port", args[:port].to_s)

      ASMain.main([args[:app_dir], "--contextroot", args[:contextroot]].to_java(:string))
    end
  end
end
