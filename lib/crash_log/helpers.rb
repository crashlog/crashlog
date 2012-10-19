module CrashLog
  module Helpers

    MAX_STRING_LENGTH = 4096

    def self.cleanup_obj(obj, filters = nil)
      # Borrowed from Bugsnag
      return nil unless obj

      if obj.is_a?(Hash)
        clean_hash = {}
        obj.each do |k,v|
          if filters && filters.any? {|f| k.to_s.include?(f.to_s)}
            clean_hash[k] = "[FILTERED]"
          else
            clean_obj = cleanup_obj(v, filters)
            clean_hash[k] = clean_obj unless clean_obj.nil?
          end
        end
        clean_hash
      elsif obj.is_a?(Array) || obj.is_a?(Set)
        obj.map { |el| cleanup_obj(el, filters) }.compact
      elsif obj.is_a?(Integer) || obj.is_a?(Float)
        obj
      else
        obj.to_s unless obj.to_s =~ /#<.*>/
      end
    end

    def self.reduce_hash_size(hash)
      # Borrowed from Bugsnag
      return hash unless hash.respond_to?(:inject)

      hash.inject({}) do |h, (k,v)|
        if v.is_a?(Hash)
          h[k] = reduce_hash_size(v)
        elsif v.is_a?(Array) || v.is_a?(Set)
          h[k] = v.map {|el| reduce_hash_size(el) }
        else
          h[k] = v.to_s.slice(0, MAX_STRING_LENGTH) + "[TRUNCATED]"
        end

        h
      end
    end
  end
end
