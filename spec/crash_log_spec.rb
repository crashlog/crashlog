require 'spec_helper'

describe CrashLog do
  def set_public_env
    CrashLog.configure { |config| config.stage = 'production' }
  end

  def set_development_env
    CrashLog.configure { |config| config.stage = 'development' }
  end

  let(:raised_error) do
    begin
      raise RuntimeError, "This broke"
    rescue RuntimeError => e
      e
    end
  end

  after do
    CrashLog.instance_variable_set("@configuration", nil)
  end

  let(:user) do
    stub('User', :email => 'user@example.com')
  end

  describe '.notify' do
    it 'does not send if not live' do
      CrashLog::Reporter.any_instance.should_receive(:notify).never

      CrashLog.stub(:live?).and_return(false)
      CrashLog.notify(raised_error)
    end

    it 'handles being passed an exception object' do
      CrashLog::Reporter.any_instance.should_receive(:notify).once

      CrashLog.stub(:live?).and_return(true)
      CrashLog.notify(raised_error)
    end

    it 'handles being passed an exception object and context' do
      payload = {}

      CrashLog::Reporter.any_instance.stub(:notify)
        #should_receive(:notify).with(payload).once
      CrashLog.stub(:live?).and_return(true)

      context = {:current_user => user}
      CrashLog.notify(raised_error, context)
    end

    it 'handles being passed a hash'
    it 'handles being passed a string'
  end

  describe '.logger' do
    it 'detects Rails.logger'
    it 'defaults to STDOUT'
  end

  describe '.configuration' do
    after do
      CrashLog.instance_variable_set("@configuration", nil)
    end

    it 'handles being configured with a block' do
      logger = stub("Logger")
      logger.stub(:error)

      CrashLog.configuration.logger.should be_nil
      CrashLog.configure do |config|
        config.logger = logger
      end
      CrashLog.configuration.logger.should == logger
    end

    it 'handles directly configuring attributes' do
      logger = stub("Logger")
      CrashLog.configuration.logger.should be_nil
      CrashLog.configuration.logger = logger
      CrashLog.configuration.logger.should == logger
    end

    it 'accepts api_key' do
      key = stub("THIS IS AN API KEY")
      CrashLog.configuration.api_key.should be_nil
      CrashLog.configuration.api_key = key
      CrashLog.configuration.api_key.should == key
    end
  end

  describe '.ready' do
    it 'logs an ready message' do
      CrashLog::Reporter.any_instance.stub(:announce).and_return("Test Application")
      logger = stub('Logger')
      logger.should_receive(:info).
        with("** [CrashLog] Initialized and ready to handle exceptions for Test Application")

      CrashLog.stub(:logger).and_return(logger)
      CrashLog.report_for_duty!
    end
  end

  describe '.live?' do
    it 'is live if current stage is included in release stages' do
      CrashLog.configure do |c|
        c.release_stages = ['test']
        c.stage = 'test'
      end

      CrashLog.should be_live
    end

    it 'is not live if current stage is not included in release stages' do
      CrashLog.configure do |c|
        c.release_stages = ['production']
        c.stage = 'test'
      end

      CrashLog.should_not be_live
    end

    it 'handles irregular stage names' do
      CrashLog.configure do |c|
        c.release_stages = ['test']
        c.stage = 'Test'
      end

      CrashLog.configuration.stage.should === 'test'
      CrashLog.should be_live
    end
  end

  describe '#ignored?' do
    it 'returns true if current exception is on ignored list' do
      CrashLog.ignored?(RuntimeError.new).should be_false
    end

    it 'ignores ActiveRecord::RecordNotFound' do
      # load_dummy_app
      unless defined?(ActiveRecord)
        module ActiveRecord
          class RecordNotFound < RuntimeError
          end
        end
      end

      CrashLog.ignored?(ActiveRecord::RecordNotFound).should be_true
    end
  end
end
