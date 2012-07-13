module CrashLog
  class Backtrace
    class Line

      # Backtrace line parsing regexp
      # (optionnally allowing leading X: for windows support)
      INPUT_FORMAT = %r{^((?:[a-zA-Z]:)?[^:]+):(\d+)(?::in `([^']+)')?$}

      # The file portion of the line (such as app/models/user.rb)
      attr_reader :file

      # The line number portion of the line
      attr_reader :number

      # The method of the line (such as index)
      attr_reader :method

      # Parses a single line of a given backtrace
      # @param [String] unparsed_line The raw line from +caller+ or some
      # backtrace.
      # @return [Line] The parsed backtrace line
      def self.parse(unparsed_line)
        _, file, number, method = unparsed_line.match(INPUT_FORMAT).to_a
        new(file, number, method)
      end

      def initialize(file, number, method)
        self.file   = file
        self.number = number.to_i
        self.method = method
      end

      # Reconstructs the line in a readable fashion
      def to_s
        "#{file}:#{number}:in `#{method}'"
      end

      def ==(other)
        to_s == other.to_s
      end

      def inspect
        "<Line:#{to_s}>"
      end

      def to_hash
        as_json
      end

      def as_json
        {}.tap do |hash|
          hash[:number] = number
          hash[:method] = method
          hash[:file] = file
        end
      end

    private

      attr_writer :file, :number, :method

    end
  end
end
