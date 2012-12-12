require 'spec_helper'
# require 'crash_log/rails'

# describe "Initializer" do

#   let(:logger) { stub("Logger") }
#   let(:other_logger) { stub("OtherLogger") }

#   let(:rails) { double('Rails') }

#   before(:each) do
#     define_constant('Rails', rails)
#   end

#   it "triggers use of Rails' logger if logger isn't set and Rails' logger exists" do
#     rails = Module.new do
#       def self.logger
#         "RAILS LOGGER"
#       end
#     end
#     define_constant("Rails", rails)
#     CrashLog::Rails.initialize
#     expect("RAILS LOGGER").to eq(CrashLog.logger)
#   end

#   describe 'auto configure logger' do
#     before do
#       Rails.stub(:logger).and_return(logger)
#       logger.stub(:error)
#       other_logger.stub(:error)
#     end


#     it 'detects presence of Rails logger' do
#       CrashLog::Rails.__send__(:initialize)
#       CrashLog.logger.should eq(logger)
#     end

#     it "allows overriding of the logger if already assigned" do
#       CrashLog.logger.should_not == logger
#       CrashLog::Rails.initialize
#       CrashLog.logger.should == logger

#       CrashLog.configure do |config|
#         config.logger = other_logger
#       end

#       CrashLog.logger.should == other_logger
#     end
#   end

# end
