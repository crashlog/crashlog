class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user
    User.new({:id => 1, :email => 'user@example.com', :full_name => "Johnny Quid"})
  end
end
