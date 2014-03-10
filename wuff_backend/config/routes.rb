WuffBackend::Application.routes.draw do
  resources :users

  post '/user/add_user', to: 'users#add_user'
  post '/user/login_user', to: 'users#login_user'
  delete '/user/logout_user', to: 'users#logout_user'

end
