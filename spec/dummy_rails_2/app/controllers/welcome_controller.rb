class WelcomeController < ApplicationController

  layout :application

  def index
    render :text => "Welcome"
  end

  def broken
    @projects = []
    raise StandardError, "Broken route"
  end
end
