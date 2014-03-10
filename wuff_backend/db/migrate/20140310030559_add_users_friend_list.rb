class AddUsersFriendList < ActiveRecord::Migration
  def change
  	add_column :users, :friend_list, :text
  end
end
