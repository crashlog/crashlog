Rails.application.routes.draw do

  get 'broken' => 'break#really_broken'
  get 'manual' => 'break#manual_notify'

  root :to => "break#index"
end
