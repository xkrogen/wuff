WuffBackend::Application.routes.draw do
  resources :users

  post '/user/add_user', to: 'users#do_add'
  post '/user/login_user', to: 'users#do_login'
  delete '/user/logout_user', to: 'users#do_logout'

end
