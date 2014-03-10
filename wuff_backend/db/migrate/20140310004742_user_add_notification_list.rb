class UserAddNotificationList < ActiveRecord::Migration
  def change
  	add_column :users, :notification_list, :text
  end
end
