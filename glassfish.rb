require 'glassfish-10.0-SNAPSHOT.jar'

module GlassFish
  import com.sun.enterprise.glassfish.bootstrap.ASMain
  def startup(args)
    #OSGi is default but GlassFish nucleus does not have all the dependencies for OSGi and
    #hence it fails. For now running it in HK2
    java.lang.System.setProperty("GlassFish_Platform", "HK2");

    #set jruby runtime property
    java.lang.System.setProperty("jruby.runtime", args[:runtimes].to_s)

    ASMain.main([args[:app_dir], "--contextroot", args[:contextroot]].to_java(:string))
  end

  module_function :startup
end
