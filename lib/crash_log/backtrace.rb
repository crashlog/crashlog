module CrashLog
  class Backtrace

    require_relative 'backtrace/line'
    require_relative 'backtrace/line_cache'

    # holder for an Array of Backtrace::Line instances
    attr_reader :lines

    def self.parse(ruby_backtrace, opts = {})
      ruby_lines = split_multiline_backtrace(ruby_backtrace)

      lines = ruby_lines.to_a.map do |unparsed_line|
        Line.parse(unparsed_line)
      end

      filters = opts[:filters] || []

      lines.each do |line|
        filters.each do |filter|
          line.apply_filter(filter)
        end
      end

      lines = lines.reject do |line|
        line.marked_for_deletion?
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
      if Array(backtrace).size == 1
        Array(backtrace).first.split(/\n\s*/)
      else
        backtrace
      end
    end
  end
end
