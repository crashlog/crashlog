require 'spec_helper'
require 'rack/test'
require "uuid"
require "crash_log/rails/action_controller_rescue"

describe 'Rescue from within a Rails 2.x controller' do
  # class CollectingReporter
  #   attr_reader :collected

  #   def initialize
  #     @collected = []
  #   end

  #   def notify(payload)
  #     @collected << payload
  #     {:location_id => UUID.generate }
  #   end
  # end

  # def assert_caught_and_sent
  #   expect { CrashLog.sender.collected.empty? }.to be_false
  # end

  # def assert_caught_and_not_sent
  #   expect { CrashLog.sender.collected.empty? }.to be_true
  # end

  # before do
  #   CrashLog::Payload.any_instance.stub(:reporter).and_return(CollectingReporter.new)
  # end

  # def build_controller_class(&definition)
  #   ActionController::Base.any_instance.stub(:rescue_action_in_public)
  #   ActionController::Base.any_instance.stub(:rescue_action_locally)

  #   Class.new(ActionController::Base).tap do |klass|
  #     klass.__send__(:include, CrashLog::Rails::ActionControllerRescue)
  #     klass.class_eval(&definition) if definition
  #     define_constant('CrashLogTestController', klass)
  #   end
  # end

  # def process_action(opts = {}, &action)
  #   opts[:request]  ||= ActionController::TestRequest.new
  #   opts[:response] ||= ActionController::TestResponse.new
  #   klass = build_controller_class do
  #     cattr_accessor :local
  #     define_method(:index, &action)
  #     def local_request?
  #       local
  #     end
  #   end
  #   if opts[:filters]
  #     klass.filter_parameter_logging *opts[:filters]
  #   end
  #   if opts[:user_agent]
  #     if opts[:request].respond_to?(:user_agent=)
  #       opts[:request].user_agent = opts[:user_agent]
  #     else
  #       opts[:request].env["HTTP_USER_AGENT"] = opts[:user_agent]
  #     end
  #   end
  #   if opts[:port]
  #     opts[:request].port = opts[:port]
  #   end
  #   klass.local = opts[:local]
  #   controller = klass.new
  #   controller.stub(:rescue_action_in_public_without_crash_log)
  #   opts[:request].session = ActionController::TestSession.new(opts[:session] || {})
  #   # Prevents request.fullpath from crashing Rails in tests
  #   # opts[:request].env['REQUEST_URI'] = opts[:request].request_uri
  #   controller.process(:index) #, opts[:request], opts[:response])
  #   controller
  # end

  # def process_action_with_automatic_notification(args = {})
  #   process_action(args) { raise "Hello" }
  # end

  # it "delivers notices from exceptions raised in public requests" do
  #   process_action_with_automatic_notification
  #   assert_caught_and_sent
  # end

end
