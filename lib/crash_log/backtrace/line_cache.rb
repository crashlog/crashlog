module CrashLog
  class Backtrace
    class LineCache
      class << self
        CACHE = {}

        def getlines(path)
          CACHE[path] ||= begin
            IO.readlines(path).map { |line| line.chomp.gsub(/[']/, '\\\\\'') }
          rescue
            []
          end
        end

        def getline(path, n)
          return nil if n < 1
          getlines(path)[n-1]
        end

      end
    end
  end
end
