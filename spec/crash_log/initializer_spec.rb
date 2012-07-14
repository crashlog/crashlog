require 'spec_helper'

describe "Initializer" do

  let(:logger) { stub("Logger") }
  let(:other_logger) { stub("OtherLogger") }

  describe 'auto configure logger' do
    before do
      unless defined?(Rails)
        module Rails
        end
      end
      Rails.stub(:logger).and_return(logger)
      logger.stub(:error)
      other_logger.stub(:error)
    end


    it 'detects presence of Rails logger' do
      CrashLog::Rails.initialize
      CrashLog.logger.should be(logger)
    end

    it "allows overriding of the logger if already assigned" do
      unless defined?(Rails)
        module Rails
        end
      end

      Rails.stub(:logger).and_return(logger)

      CrashLog.logger.should_not == logger
      CrashLog::Rails.initialize
      CrashLog.logger.should == logger

      CrashLog.configure do |config|
        config.logger = other_logger
      end

      CrashLog.logger.should == other_logger
    end
  end

end
