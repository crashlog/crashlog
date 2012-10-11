require 'spec_helper'
require 'rack/test'
require 'uuid'

describe 'Rescue from within a Rails 3.x controller' do
  include RSpec::Rails::RequestExampleGroup
  include Rack::Test::Methods

  class CollectingReporter
    attr_reader :collected

    def initialize
      @collected = []
    end

    def result
      {:location_id => UUID.generate }
    end

    def notify(payload)
      @collected << payload
      true
    end
  end

  def assert_caught_and_sent
    CrashLog.reporter.collected.should_not be_empty
  end

  def assert_caught_and_not_sent
    expect { CrashLog.reporter.collected.empty? }.to be_true
  end

  def last_notice
    CrashLog.reporter.collected.last
  end

  before do
    CrashLog.reporter = CollectingReporter.new
    CrashLog.configuration.root = File.expand_path("../..", __FILE__)
  end

  it 'is testing tails 3.x' do
    Rails.version.should =~ /^3\.2\./
  end

  describe 'dummy app' do
    it 'should response nicely to index' do
      get '/'
      last_response.should be_ok
      last_response.body.should == 'Works fine here'
    end
  end

  let(:action) { get '/broken' }

  it 'collects payloads' do
    CrashLog.notify(RuntimeError.new("TEST"))
    assert_caught_and_sent
  end

  it 'should intercept error and notify crashlog' do
    get '/broken'
    last_response.status.should == 500
    last_response.body.should match /We're sorry, but something went wrong/

    assert_caught_and_sent
  end

  it 'captures standard backtrace attributes' do
    action

    last_notice.to_json.should have_json_path('notifier/name')
    last_notice.to_json.should have_json_path('backtrace/0/number')
    last_notice.to_json.should have_json_path('backtrace/0/method')
    last_notice.to_json.should have_json_path('backtrace/0/file')
    last_notice.to_json.should have_json_path('backtrace/0/context_line')
    last_notice.to_json.should have_json_path('backtrace/0/pre_context/1')
    last_notice.to_json.should have_json_path('backtrace/0/pre_context/2')
    last_notice.to_json.should have_json_path('backtrace/0/pre_context/3')
    last_notice.to_json.should have_json_path('backtrace/0/pre_context/4')
    last_notice.to_json.should have_json_path('environment/system/hostname')
    last_notice.to_json.should have_json_path('environment/system/application_root')
  end

  it 'captures current user' do
    # ActionController::Base.any_instance.stub(:crash_log_context).and_return({current_user: {id: 1}})

    action

    # last_notice.should == ''
    last_notice.to_json.should have_json_path('context/current_user')
  end

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
