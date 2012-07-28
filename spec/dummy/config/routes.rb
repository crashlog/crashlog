Rails.application.routes.draw do

  get 'broken' => 'break#really_broken'

  root :to => "break#index"
end
