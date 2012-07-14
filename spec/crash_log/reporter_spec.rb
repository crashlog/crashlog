require 'spec_helper'

describe CrashLog::Reporter do
  let(:uuid) { UUID.generate }

  let(:config) { stub("Configuration", {
    :host => "io.crashlog.io",
    :scheme => "https",
    :port => 443,
    :endpoint => '/notify',
    :announce => true,
    :announce_endpoint => '/announce'
    })
  }
  subject { CrashLog::Reporter.new(config) }

  let(:positive_response) do
    {:result_url => "https://crashlog.io/collect/#{uuid}"}
  end

  let(:announce_response) do
    {:application => "CrashLog Test"}
  end

  let(:positive_response_json) { positive_response.to_json }
  let(:announce_json) { announce_response.to_json }

  let(:payload) {
    {}
  }

  before do
    CrashLog.stub(:report_for_duty!)
  end

  describe '#notify' do
    before do
      test_connection = Faraday.new(:url => subject.url) do |builder|
        builder.adapter :test, stubs
      end

      subject.stub(:connection).and_return(test_connection)
    end


    let!(:stubs) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post('/notify') { [200, {}, positive_response_json] }
      end
    end

    after do
      stubs.verify_stubbed_calls
    end
    it 'sends a serialized payload to crashlog.io' do
      subject.notify(payload).should be_true
    end

    it 'captures result body' do
      subject.notify(payload).should be_true
      subject.result.should == positive_response
    end
  end

  describe '#announce' do
    let!(:stubs) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post('/announce') { [200, {}, announce_json] }
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
      subject.url.to_s.should == 'https://io.crashlog.io'
    end
  end
end
