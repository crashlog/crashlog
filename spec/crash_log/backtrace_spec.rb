require 'spec_helper'

describe CrashLog::Backtrace do
  let(:raised_error) do
    begin
      raise RuntimeError, "This broke"
    rescue RuntimeError => e
      e
    end
  end

  describe '.parse' do
    it 'accepts a standed caller array' do
      CrashLog::Backtrace.parse(caller).to_a.size.should == caller.size
    end

    it 'accepts a ruby exception backtrace' do
      CrashLog::Backtrace.parse(raised_error.backtrace).to_a.size.should ==
          raised_error.backtrace.size
    end
  end

  describe '.split_multiline_backtrace' do
    it 'splits multiple lines into an array' do
      CrashLog::Backtrace.send(:split_multiline_backtrace, "line.rb:1\nline.rb:2").size.should == 2
    end
  end

  describe 'comparisson' do
    it 'matches backtraces on lines' do
      backtrace_1 = CrashLog::Backtrace.parse(caller)
      backtrace_2 = CrashLog::Backtrace.parse(caller)

      backtrace_1.should == backtrace_2
    end

    it 'fails to match different backtraces' do
      backtrace_1 = CrashLog::Backtrace.parse(caller)
      backtrace_2 = CrashLog::Backtrace.parse(raised_error.backtrace)
      backtrace_1.should_not == backtrace_2
    end
  end

  describe 'lines' do
    it 'are converted into a parsed Line object' do
      CrashLog::Backtrace.parse(raised_error.backtrace).lines.first.should be_a(CrashLog::Backtrace::Line)
    end

    it 'responds to to_hash' do
      CrashLog::Backtrace.parse(raised_error.backtrace).lines.first.to_hash.should have_keys(:number, :method, :file)
    end

    it 'captures line context' do
      line = CrashLog::Backtrace.parse(raised_error.backtrace).lines.first
      line.context_line.should match /raise RuntimeError/
    end

    it 'captures pre_context' do
      line = CrashLog::Backtrace.parse(raised_error.backtrace).lines.first
      line.pre_context.should == [
        "require \\'spec_helper\\'",
        "",
        "describe CrashLog::Backtrace do",
        "  let(:raised_error) do",
        "    begin"
      ]
    end

    it 'captures pre_context' do
      line = CrashLog::Backtrace.parse(raised_error.backtrace).lines.first
      line.post_context.should == [
        "    rescue RuntimeError => e",
        "      e",
        "    end",
        "  end",
        ""
      ]
    end

    it 'does not filter context file path' do
      CrashLog.configuration.project_root = File.expand_path('../../', __FILE__)
      filters = CrashLog.configuration.backtrace_filters
      backtrace = CrashLog::Backtrace.parse(raised_error.backtrace, :filters => filters)
      line = backtrace.lines.first

      line.file.should match /\[PROJECT_ROOT\]/
      line.context_line.should match /raise RuntimeError/
    end
  end

  describe 'filters' do
    it 'should replace project root with [PROJECT_ROOT]' do
      CrashLog.configuration.project_root = File.expand_path('../../', __FILE__)
      filters = CrashLog.configuration.backtrace_filters
      backtrace = CrashLog::Backtrace.parse(raised_error.backtrace, :filters => filters)

      backtrace.lines.first.file.should match /\[PROJECT_ROOT\]/
      backtrace.lines.first.file.should == '[PROJECT_ROOT]/crash_log/backtrace_spec.rb'
    end

    it 'should not replace project root if it is not set' do
      CrashLog.configuration.project_root = nil

      filter = CrashLog::Configuration::DEFAULT_BACKTRACE_FILTERS
      backtrace = CrashLog::Backtrace.parse(raised_error.backtrace, :filters => filter)

      backtrace.lines.first.file.should_not match /\[PROJECT_ROOT\]/
    end
  end
end
