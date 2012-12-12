require 'spec_helper'
require 'json_spec'

describe CrashLog::Payload do
  include JsonSpec

  let(:configuration) do
    CrashLog.configure do |config|
      config.api_key = 'API_KEY'
      config.secret = 'SECRET'
    end
  end

  subject { CrashLog::Payload.build(raised_error, configuration) }

  let(:raised_error) do
    begin
      raise RuntimeError, "This broke"
    rescue RuntimeError => e
      e
    end
  end

  describe '#add_context' do
    it 'has stage set from payload' do
      data = {:stage=>"production"}
      subject.context.should == data
    end

    it 'merges in new user data' do
      data = {:stage=>"production", :email=>"user@example.com"}
      subject.add_context(data)
      subject.context.should == data
    end
  end

  describe '#add_session_data' do
    it 'is empty by default' do
      subject.data[:session].should be_nil
    end

    it 'allows merging in data' do
      pending
      data = {:path => '/problematic/path'}
      subject.add_session_data(data)
      subject.data[:session].should == data
    end

    it 'allows adding more data' do
      pending
      data_1 = {:path => '/problematic/path'}
      data_2 = {:count => 42}
      subject.add_session_data(data_1)
      subject.add_session_data(data_2)

      subject.data[:session][:path].should == data_1[:path]
      subject.data[:session][:count].should == data_2[:count]
    end
  end

  describe 'private.unwrap_exception' do
    it 'unwraps exception objects' do
      subject.__send__(:unwrap_exception, raised_error).should == raised_error
    end
  end

  describe '#body' do

    describe 'notifier' do
      it 'has name' do
        subject.body.to_json.should have_json_path('notifier/name')
      end

      it 'has version' do
        subject.body.to_json.should have_json_path('notifier/version')
      end
    end

    describe 'event' do

      it 'has type' do
        subject.body.to_json.should have_json_path('event/type')
      end

      it 'has message' do
        subject.body.to_json.should have_json_path('event/message')
      end

      it 'has timestamp' do
        subject.body.to_json.should have_json_path('event/timestamp')
      end
    end

    it 'has backtrace' do
      subject.body.to_json.should have_json_path('backtrace/0')
    end

    describe 'environment' do
      it 'should have system information' do
        subject.body.to_json.should have_json_path('environment/system/hostname')
      end

      it 'has system ruby version' do
        subject.body.to_json.should have_json_path('environment/system/ruby_version')
      end

      it 'has system username' do
        subject.body.to_json.should have_json_path('environment/system/username')
      end

      it 'has system environment' do
        subject.body.to_json.should have_json_path('environment/system/environment')
      end
    end

    describe 'backtrace' do
      it 'has line number' do
        subject.body.to_json.should have_json_path('backtrace/0/number')
      end

      it 'has integer as line number' do
        subject.body.to_json.should have_json_type(Integer).at_path('backtrace/0/number')
      end

      it 'has filename' do
        subject.body.to_json.should have_json_path('backtrace/0/file')
      end

      it 'has method' do
        subject.body.to_json.should have_json_path('backtrace/0/method')
      end
    end

    describe 'context' do
      it 'has stage' do
        subject.body.to_json.should have_json_path('context/stage')
      end
    end

    describe 'data' do
      it 'adds data to data interface' do
        subject.add_data(:something_awesome => 'Indeed')
        subject.body.to_json.should have_json_path('data/something_awesome')
      end
    end
  end
end
