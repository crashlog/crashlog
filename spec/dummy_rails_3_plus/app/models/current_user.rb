class CurrentUser
  attr_reader :username, :full_name, :id

  def initialize(*args)
    @id = 1337
    @username = "testuser"
    @full_name = "Test User"
  end
end
