class BreakController < ApplicationController
  def index
    render :text => "Works fine here"
  end

  def really_broken
    raise RuntimeError, "You hit the broken route"
  end

  def manual_notify
    raise RuntimeError, "Manual exception"
  rescue => e
    notify_crashlog(e)
  end

  def current_user
    CurrentUser.new
  end
end
