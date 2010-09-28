require 'java'
require 'glassfish-gem.jar'

java_import 'org.glassfish.scripting.gem.Options'

describe "Options" do
  describe "log level" do
    it "can translate enum string to numerical value via .ordinal" do
      Options::LogLevel::OFF.    ordinal.should == 0
      Options::LogLevel::SEVERE. ordinal.should == 1
      Options::LogLevel::WARNING.ordinal.should == 2
      Options::LogLevel::INFO.   ordinal.should == 3
      Options::LogLevel::FINE.   ordinal.should == 4
      Options::LogLevel::FINER.  ordinal.should == 5
      Options::LogLevel::FINEST. ordinal.should == 6
      Options::LogLevel::ALL.    ordinal.should == 7
    end
        
  end
end