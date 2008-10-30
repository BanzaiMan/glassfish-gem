require 'admin-cli.jar'
require 'java'

module GlassFish
  class ASAdmin
    import com.sun.enterprise.admin.cli.AsadminMain
    AsadminMain.main(ARGV.to_java :String)
  end
end
