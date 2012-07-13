class Hash
  def has_keys?(*keys)
    keys.all? do |key|
      has_key?(key)
    end
  end
end
