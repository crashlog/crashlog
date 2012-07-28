class BreakController < ApplicationController
  def index
    render :text => "Works fine here"
  end

  def really_broken
    raise RuntimeError, "You hit the broken route"
  end
end
