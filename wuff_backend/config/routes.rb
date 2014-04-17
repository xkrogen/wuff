WuffBackend::Application.routes.draw do
  resources :users

	post '/user/add_user', to: 'users#add_user'
	post '/user/login_user', to: 'users#login_user'
	delete '/user/logout_user', to: 'users#logout_user'
	post '/user/auth_facebook', to: 'users#auth_facebook'
	post '/user/get_profile_pic', to: 'users#get_profile_pic'
	post '/user/add_friend', to: 'users#add_friend'
	delete '/user/delete_friend', to: 'users#delete_friend'
	get '/user/get_events', to: 'users#get_events'
	get '/user/get_groups', to: 'users#get_groups'	
	get '/user/get_friends', to: 'users#get_friends'		
	get '/user/has_notifications', to: 'users#has_notifications?'
	get '/user/get_notifications', to: 'users#get_notifications'
	delete '/user/clear_notifications', to: 'users#clear_notifications'
	post '/user/get_all_users', to: 'users#get_all_users'

	post '/event/update_user_status', to: 'events#update_user_status'
	post '/event/invite_users', to: 'events#invite_users'
	post '/event/create_event', to: 'events#create_event'
	post '/event/view', to: 'events#view'
	delete '/event/remove_user', to: 'events#remove_user'
	delete '/event/cancel_event', to: 'events#cancel_event'
	post '/event/edit_event', to: 'events#edit_event'

	post '/group/add_users', to: 'groups#add_users'
	post '/group/create_group', to: 'groups#create_group'
	post '/group/view', to: 'groups#view'
	delete '/group/remove_user', to: 'groups#remove_user'
	delete '/group/delete_group', to: 'groups#delete_group'
	post '/group/edit_group', to: 'groups#edit_group'
end
