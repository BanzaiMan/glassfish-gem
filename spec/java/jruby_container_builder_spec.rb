# require 'java'
# require 'glassfish-gem.jar'
# require 'glassfish-embedded-nucleus.jar'


# java_import 'org.glassfish.scripting.gem.JRubyContainerBuilder'
# java_import 'org.glassfish.scripting.gem.JRubyContainer'
# java_import 'org.glassfish.api.embedded.Server'

describe "JRubyContainerBuilder" do
  ## this class implements the ContainerBuilder interface
  ## anything worth testing (it responds to #create, and
  ## that #create resturns a ContainerBuilder) is guaranteed by javac.
end
