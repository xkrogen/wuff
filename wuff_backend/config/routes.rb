WuffBackend::Application.routes.draw do
  resources :users

  post '/user/add_user', to: 'users#add_user'
  post '/user/login_user', to: 'users#login_user'
  delete '/user/logout_user', to: 'users#logout_user'
  post '/user/add_friend', to: 'users#add_friend'
  delete '/user/delete_friend', to: 'users#delete_friend'
	get '/user/get_events', to: 'users#get_events'
	get '/user/has_notifications', to: 'users#has_notifications?'
	get '/user/get_notifications', to: 'users#get_notifications'
	delete '/user/clear_notifications', to: 'users#clear_notifications'

	post '/event/update_user_status', to: 'events#update_user_status'
	post '/event/invite_users', to: 'events#invite_users'
	post '/event/create_event', to: 'events#create_event'
	post '/event/view', to: 'events#view'
end
