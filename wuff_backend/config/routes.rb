WuffBackend::Application.routes.draw do
  resources :users
  resources :sessions, only: [:create, :destroy]
=begin
  post '/user/add_user', to: 'users#do_add'
  post '/user/login_user', to: 'sessions#new'
  delete '/user/logout_user', to: 'sessions#destroy'
=end

end
