require 'spec_helper'

describe CrashLog::Reporter do
  let(:uuid) { UUID.generate }

  let(:config) {
    CrashLog::Configuration.new.tap do |config|
      config.secret = 'SECRET'
      config.api_key = 'API_KEY'
      # config.adapter = test_adapter
      config.scheme = 'http'
    end
  }

  # let(:config) { stub("Configuration", {
  #   :host => "io.crashlog.io",
  #   :scheme => "https",
  #   :port => 443,
  #   :endpoint => '/notify',
  #   :announce => true,
  #   :announce_endpoint => '/announce',
  #   :dry_run => false,
  #   :api_key => 'API_TOKEN',
  #   :project_id => "PROJECT_ID",
  #   :http_read_timeout => 1,
  #   :http_open_timeout => 1
  #   }).tap do |config|
  #     config.stub(:adapter).and_return(:test, &test_adapter)
  #   end
  # }

  let(:test_adapter) {
    lambda { |stub|
      stub.post('/events') do |env|
        [201, {}, env[:request_headers]]
      end
    }
  }

  subject { CrashLog::Reporter.new(config) }

  let(:positive_response) do
    {:result_url => "https://crashlog.io/collect/#{uuid}"}
  end

  let(:announce_response) do
    {:application_name=> "CrashLog Test"}
  end

  let(:positive_response_json) { positive_response.to_json }
  let(:announce_json) { announce_response.to_json }

  let(:payload) {
    {}
  }

  before do
    CrashLog.stub(:report_for_duty!)
  end

  it 'should not be doing a dry run' do
    subject.should_not be_dry_run
  end

  describe '#notify' do
    before do
      test_connection = Faraday.new(:url => subject.url) do |builder|
        builder.adapter :test, stubs
        builder.request :hmac_authentication, 'API_KEY', 'SECRET', {:service_id => 'CrashLog'}
        builder.request :url_encoded
      end

      subject.stub(:connection).and_return(test_connection)
    end

    let!(:stubs) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post('/events') { [200, {}, positive_response_json] }
      end
    end

    after do
      #stubs.verify_stubbed_calls
    end

    it 'makes a post request' do
      response = double("Post", success?: true)
      response.stub(:body).and_return(positive_response_json)
      subject.send(:connection).should_receive(:post).once.and_return(response)
      subject.notify(payload)
    end

    it 'authenticates request with HMAC' do
      time_travel_to "2012-08-01 00:00:00 UTC"

      subject.notify(payload).should be_true

      subject.response.env[:request_headers]['Authorization'].should ==
        CrashLog::AuthHMAC.new({}, {
        :service_id => 'CrashLog',
        :signature => Faraday::Request::HMACAuthentication::CanonicalString
      }).authorization(subject.response.env, 'API_KEY', 'SECRET')
      stubs.verify_stubbed_calls
    end

    it 'sends a serialized payload to crashlog.io' do
      subject.notify(payload).should be_true

      stubs.verify_stubbed_calls
    end

    it 'captures result body' do
      subject.notify(payload).should be_true
      subject.result.should == positive_response
    end
  end

  describe '#announce' do
    let!(:stubs) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post('/announce') { [201, {}, announce_json] }
      end
    end

    before do
      test_connection = Faraday.new(:url => subject.url) do |builder|
        builder.adapter :test, stubs
      end

      subject.stub(:connection).and_return(test_connection)
    end

    it 'sends an identification payload to CrashLog'

    it 'responds with an application name' do
      subject.announce.should === 'CrashLog Test'
      stubs.verify_stubbed_calls
    end
  end

  describe 'url' do
    it 'constructs url from configuration' do
      subject.url.to_s.should == 'http://stdin.crashlog.io'
    end

    it 'sends HMACAuth header'

    #   # config.stub(:adapter).and_return(:test, &test_adapter)

    #   # .and_return(:test).and_yield do |stub|
    #   #   stub.post('/notify') do |env|
    #   #     [200, {}, env[:request_headers]]
    #   #   end
    #   # end

    #   # test_connection = Faraday.new(:url => subject.url) do |faraday|
    #   #   faraday.adapter :test do |stub|
    #   #     stub.post('/notify') do |env|
    #   #       [200, {}, env[:request_headers]]
    #   #     end
    #   #   end
    #   # end

    #   #   #faraday.request   :url_encoded
    #   #   faraday.request    :token_auth, "config.api_key"
    #   #   #faraday.response  :logger
    #   #   # faraday.token_auth config.api_key
    #   #   faraday.options[:timeout] = 1
    #   #   faraday.options[:open_timeout] = 1
    #   #   faraday.ssl[:verify] = false
    #   # end

    #   # subject.stub(:connection).and_return(test_connection)
    #   # subject.connection.adapter(:test) do |stub|
    #   #   stub.post('/notify') do |env|
    #   #     [200, {}, env[:request_headers]]
    #   #   end
    #   # end

    #   subject.notify(payload).should be_true

    #   subject.response.should == 'Token token=""'

    #   stubs.verify_stubbed_calls
    # end
  end
end
