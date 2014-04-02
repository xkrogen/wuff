class UserAddDeviceToken < ActiveRecord::Migration
  def change
  	add_column :users, :device_tokens, :text
  	add_index :users, :device_tokens
  end
end
