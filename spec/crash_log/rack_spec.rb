require "spec_helper"

describe CrashLog::Rack do
  before do
    CrashLog.configure do |config|
      config.api_key = 'KEY'
      config.secret = 'secret'
      config.developer_mode = true
    end
  end

  class BacktracedException < Exception
    attr_accessor :backtrace

    def initialize(opts)
      @backtrace = opts[:backtrace]
    end

    def set_backtrace(bt)
      @backtrace = bt
    end

    def message
      "Something went wrong. Did you press the red button?"
    end
  end

  def build_exception(opts = {})
    backtrace = caller
    opts = {:backtrace => backtrace}.merge(opts)
    BacktracedException.new(opts)
  end

  it "calls the upstream app with the environment" do
    environment = { 'key' => 'value' }
    app = lambda { |env| ['response', {}, env] }
    stack = CrashLog::Rack.new(app)

    response = stack.call(environment)

    expect(['response', {}, environment]).to eq(response)
  end

  it "delivers an exception raised while calling an upstream app" do
    exception = build_exception
    environment = { 'key' => 'value' }

    CrashLog.should_receive(:notify_or_ignore).with(exception, :rack_env => environment)

    app = lambda do |env|
      raise exception
    end

    begin
      stack = CrashLog::Rack.new(app)
      stack.call(environment)
    rescue Exception => raised
      expect(exception).to eq(raised)
    else
      fail "Didn't raise an exception"
    end
  end

  it "delivers an exception in rack.exception" do
    CrashLog.stub(:notify)
    exception = build_exception
    environment = { 'key' => 'value' }

    CrashLog.should_receive(:notify_or_ignore).with(exception, :rack_env => environment)

    response = [200, {}, ['okay']]
    app = lambda do |env|
      env['rack.exception'] = exception
      response
    end
    stack = CrashLog::Rack.new(app)
    actual_response = stack.call(environment)

    expect(response).to eq(actual_response)
  end

end
