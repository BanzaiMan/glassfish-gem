require 'glassfish.jar'

module GlassFish
  import com.sun.enterprise.glassfish.bootstrap.ASMain
  def startup(args)
    #set jruby runtime property
    java.lang.System.setProperty("jruby.runtime", args[:runtimes].to_s)
    java.lang.System.setProperty("jruby.gem.port", args[:port].to_s)

    ASMain.main([args[:app_dir], "--contextroot", args[:contextroot]].to_java(:string))
  end

  module_function :startup
end
