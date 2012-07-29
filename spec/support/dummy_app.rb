def load_dummy_app
  stubs = Faraday::Adapter::Test::Stubs.new do |stub|
    stub.post('/announce') { [200, {}, {}.to_json] }
  end

  test_connection = Faraday.new(:url => 'https://stdin.crashlog.io') do |builder|
    builder.adapter :test, stubs
  end

  CrashLog::Reporter.any_instance.stub(:connection).and_return(test_connection)

  require File.expand_path("../../dummy/config/environment.rb",  __FILE__)
end
