class AddUsersEventList < ActiveRecord::Migration
  def change
  	add_column :users, :event_list, :text
  end
end
