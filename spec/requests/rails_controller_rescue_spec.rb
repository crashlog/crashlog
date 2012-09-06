require 'spec_helper'
require 'rack/test'

describe 'Rescue from within a Rails 3.x controller' do
  include RSpec::Rails::RequestExampleGroup
  include Rack::Test::Methods

  describe 'dummy app' do
    it 'should response nicely to index' do
      get '/'
      last_response.should be_ok
      last_response.body.should == 'Works fine here'
    end
  end

  it 'should intercept error and notify crashlog' do
    CrashLog.should_receive(:notify).with(kind_of(RuntimeError)).once

    begin
      get '/broken'
      last_response.status.should == 500
      last_response.body.should match /We're sorry, but something went wrong/
    rescue
    end

  end

  it 'should capture current user'
  it 'should capture crash log custom data'

  it 'should raise error again after notifying' do
    ENV['RAILS_ENV']='production'

    logger = stub("Logger")
    ActionDispatch::DebugExceptions.any_instance.stub(:logger).and_return(logger)
    logger.should_receive(:fatal).once

    begin
      get '/broken'
      last_response.status.should == 500
    rescue
    end
  end

  it 'should be able to defer reporting to another thread'
end
