require "rails_spec_helper"

describe 'Rails controller integration' do
  class CollectingReporter
    attr_reader :collected

    def initialize
      @collected = []
    end

    def notify(payload)
      @collected << payload
      {:location_id => "LOLID" }
    end

    def result
      {:location_id => "LOLID" }
    end
  end

  def assert_caught_and_sent
    CrashLog.reporter.collected.should_not be_empty
  end

  def assert_caught_and_not_sent
    expect(CrashLog.reporter.collected).to_not be_empty
  end

  def last_notice
    CrashLog.reporter.collected.last
  end

  before do
    CrashLog.reporter = CollectingReporter.new
  end

  describe 'initialization' do

  end

  describe 'controller actions' do
    include Rack::Test::Methods

    def app
      if defined?(ActionController::Dispatcher)
        # Rails 2
        ActionController::Dispatcher.new
      elsif defined?(Rails) && Rails.respond_to?(:application)
        # Rails 3
        ::Rails.application
      end
    end

    before do
      get '/broken'
      assert_caught_and_sent
    end

    it 'captures request headers' do
      # "Host"=>"example.org", "Cookie"=>""
      last_notice[:data][:request].should have_key(:headers)
      last_notice[:data][:request][:headers].should have_keys("Host", "Cookie")
    end

    it 'captures response headers' do
      # Rails 2: "Cache-Control"=>"no-cache", "Content-Type"=>"text/html; charset=utf-8", "Content-Length"=>"17534"
      last_notice[:data][:response].should have_key(:headers)
      # last_notice[:data][:response][:headers].should == {}
    end

    describe 'context' do
      let(:context) { last_notice[:context] }

      it 'captures controller' do
        expect(context[:controller]).to eq 'welcome'
      end

      it 'captures action' do
        expect(context[:action]).to eq 'broken'
      end

      it 'captures current user' do
        expect(context[:current_user]).to eq(:id=>1, :full_name=>"Johnny Quid", :email=>"user@example.com")
      end
    end
  end
end
