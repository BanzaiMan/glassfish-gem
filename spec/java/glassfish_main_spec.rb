require 'java'
require 'glassfish-gem.jar'

java_import 'org.glassfish.scripting.gem.GlassFishMain'

describe "GlassFishMain" do
  before :each do
    @gf = GlassFishMain.new
  end
  
  describe "#startGlassFishEmbedded" do
    it "" do
      
    end
  end
end
