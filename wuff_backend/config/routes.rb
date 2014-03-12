WuffBackend::Application.routes.draw do
  resources :users

  post '/user/add_user', to: 'users#add_user'
  post '/user/login_user', to: 'users#login_user'
  delete '/user/logout_user', to: 'users#logout_user'
  post '/user/add_friend', to: 'users#add_friend'
  delete '/user/delete_friend', to: 'users#delete_friend'
	post '/user/get_events', to: 'users#get_events'

	post '/event/create_event', to: 'events#create_event'
end
