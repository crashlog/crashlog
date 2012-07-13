require 'spec_helper'
require 'json_spec'

describe CrashLog::Payload do
  include JsonSpec

  let(:configuration) do
    stub('configuration').tap do |config|
      config.stub(:[])
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

  describe '#add_user_data' do
    it 'user_data should be empty' do
      subject.user_data.should be_empty
    end

    it 'merges in new user data' do
      data = {:email => "user@example.com"}
      subject.add_user_data(data)
      subject.user_data.should == data
    end

    it 'allows settings key values' do
      subject.add_user_data('email', 'user@example.com')
      subject.user_data.should == {:email => 'user@example.com'}
    end
  end

  describe '#add_session_data' do
    it 'is empty by default' do
      subject.session.should be_empty
    end

    it 'allows merging in data' do
      data = {:path => '/problematic/path'}
      subject.add_session_data(data)
      subject.session.should == data
    end

    it 'allows adding more data' do
      data_1 = {:path => '/problematic/path'}
      data_2 = {:count => 42}
      subject.add_session_data(data_1)
      subject.add_session_data(data_2)

      subject.session[:path].should == data_1[:path]
      subject.session[:count].should == data_2[:count]
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

    describe 'exception' do

      it 'has class_name' do
        subject.body.to_json.should have_json_path('exception/class_name')
      end

      it 'has message' do
        subject.body.to_json.should have_json_path('exception/message')
      end

      describe 'backtrace' do
        it 'has line number' do
          subject.body.to_json.should have_json_path('exception/backtrace/0/number')
        end

        it 'has integer as line number' do
          subject.body.to_json.should have_json_type(Integer).at_path('exception/backtrace/0/number')
        end

        it 'has filename' do
          subject.body.to_json.should have_json_path('exception/backtrace/0/file')
        end

        it 'has method' do
          subject.body.to_json.should have_json_path('exception/backtrace/0/method')
        end
      end

      it 'has backtrace' do
        subject.body.to_json.should have_json_path('exception/backtrace/0')
      end

      it 'has timestamp' do
        subject.body.to_json.should have_json_path('exception/timestamp')
      end
    end

    describe 'session' do

    end

    describe 'user_data' do
      it 'has first key provided by user' do
        subject.add_user_data({:email => "user@example.com"})
        subject.body.to_json.should have_json_path('user_data/email')
      end
    end
  end
end
