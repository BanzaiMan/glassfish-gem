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

  describe "GrizzlyConfig" do
    before :each do
      @gc = Options::GrizzlyConfig.new nil
    end

    it "contains expected default values" do
      @gc.chunkingEnabled.should         == true
      @gc.requestTimeout.should          == 30
      @gc.sendBufferSize.should          == 8192
      @gc.maxKeepaliveConnections.should == 256
      @gc.keepaliveTimeout.should        == 30
    end

    describe "::ThreadPool" do
      it "contains expected default values" do
        tp = @gc.threadPool
        tp.should be_an_instance_of Options::GrizzlyConfig::ThreadPool
        tp.idleThreadTimeoutSeconds.should == 900
        tp.maxQueueSize.should             == 4096
        tp.maxThreadPoolSize.should        == 5
        tp.minThreadPoolSize.should        == 2
      end
    end
  end
end