class AddGroupToUser < ActiveRecord::Migration
  def change
  	add_column :users, :group_list, :text
  end
end
