require 'spec_helper'

describe CrashLog::Reporter do
  let(:uuid) { UUID.generate }

  let(:config) { stub("Configuration") }
  subject { CrashLog::Reporter.new(config) }

  let!(:stubs) do
    Faraday::Adapter::Test::Stubs.new do |stub|
      stub.post('/notify') { [200, {}, positive_response_json] }
    end
  end

  let(:positive_response) do
    {:result_url => "https://crashlog.io/collect/#{uuid}"}
  end

  let(:positive_response_json) { positive_response.to_json }

  before do
    test_connection = Faraday.new(:url => subject.url) do |builder|
      builder.adapter :test, stubs
    end

    subject.stub(:connection).and_return(test_connection)
  end

  after do
    stubs.verify_stubbed_calls
  end

  let(:payload) {
    {}
  }

  describe '#notify' do
    it 'sends a serialized payload to crashlog.io' do
      subject.notify(payload).should be_true
    end

    it 'captures result body' do
      subject.notify(payload).should be_true
      subject.result.should == positive_response
    end
  end
end
