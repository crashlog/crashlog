require 'spec_helper'
require 'rack/test'

describe 'Rescue from within a rack app' do
  include Rack::Test::Methods

  before do
    CrashLog.configure do |config|
      config.api_key = 'project-api-key'
      config.dry_run = true
    end
  end

  def app
    Rack::Builder.app do
      use CrashLog::Rack
      run lambda { |env| raise "Fully Racked" }
    end
  end

  it 'should capture exception within rack app' do
    CrashLog.should_receive(:notify).with(kind_of(RuntimeError), kind_of(Hash)).once

    lambda {
      get '/'
    }.should raise_error
  end

end
