require 'java'
require 'glassfish-gem.jar'
require 'glassfish-embedded-nucleus.jar'

java_import 'org.glassfish.scripting.gem.PortImpl'
java_import 'org.glassfish.scripting.gem.Options'
java_import 'org.glassfish.api.embedded.Port'
java_import 'org.jvnet.hk2.component.Habitat'

describe 'PortImpl' do
  
  describe '.new' do
    it 'instantiates object' do
      h = Habitat.new
      p = PortImpl.new(h)
      p.should be_instance_of PortImpl
    end
  end
  
  describe "#numer" do
    it "returns port numer" do
      
    end
  end
  
end