if ENV['COV']
  require 'simplecov'
  SimpleCov.start
end

require 'delorean'
require 'json_spec'
require 'uuid'
require "crash_log"

# require File.expand_path("../dummy/config/environment.rb",  __FILE__)

Dir[File.expand_path("../support/*.rb", __FILE__)].each { |file| require file }

RSpec.configure do |config|
  config.mock_with :rspec

  config.before do
  end
end
