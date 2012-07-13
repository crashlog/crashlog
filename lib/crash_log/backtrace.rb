module CrashLog
  class Backtrace

    autoload :Line, 'crash_log/backtrace/line'

    # holder for an Array of Backtrace::Line instances
    attr_reader :lines

    def self.parse(ruby_backtrace, opts = {})
      ruby_lines = split_multiline_backtrace(ruby_backtrace)

      filters = opts[:filters] || []
      filtered_lines = ruby_lines.to_a.map do |line|
        filters.inject(line) do |line, proc|
          proc.call(line)
        end
      end.compact

      lines = filtered_lines.collect do |unparsed_line|
        Line.parse(unparsed_line)
      end

      instance = new(lines)
    end

    def initialize(lines)
      self.lines = lines
    end

    def inspect
      "<Backtrace: " + lines.map { |line| line.inspect }.join(", ") + ">"
    end

    def ==(other)
      if other.respond_to?(:lines)
        lines == other.lines
      else
        false
      end
    end

    def to_a
      lines.map do |line|
        line.to_hash
      end
    end

    private

    attr_writer :lines

    def self.split_multiline_backtrace(backtrace)
      if backtrace.to_a.size == 1
        backtrace.to_a.first.split(/\n\s*/)
      else
        backtrace
      end
    end
  end
end
