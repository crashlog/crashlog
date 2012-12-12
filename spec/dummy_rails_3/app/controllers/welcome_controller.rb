class WelcomeController < ApplicationController

  layout :application

  def index
    render :text => "Welcome"
  end

  def broken
    header('X-Custom-Header', "BEER ME")
    @projects = []
    raise StandardError, "Broken route"
  end
end
