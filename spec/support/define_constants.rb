module DefinesConstants
  def setup_constants
    @defined_constants = []
  end

  def teardown_constants
    @defined_constants.each do |constant|
      Object.__send__(:remove_const, constant)
    end
  end

  def define_constant(name, value)
    Object.const_set(name, value)
    @defined_constants << name
  end
end
