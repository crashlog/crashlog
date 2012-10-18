module DefinesConstants
  def setup_constants
    @defined_constants = []
    @old_constants = []
  end

  def teardown_constants
    @defined_constants.each do |constant|
      Object.__send__(:remove_const, constant)
      @old_constants.each do |old|
        Object.const_set(old[:name], old[:constant])
      end
    end
  end

  def define_constant(name, value)
    begin
      if old_constant = Object.const_get(name)
        @old_constants << {:name => name, :constant => old_constant}
      end
    rescue NameError
    end

    Object.const_set(name, value)
    @defined_constants << name
  end
end
