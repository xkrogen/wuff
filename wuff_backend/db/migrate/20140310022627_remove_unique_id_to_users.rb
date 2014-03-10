class RemoveUniqueIdToUsers < ActiveRecord::Migration
  def change
  	remove_column :users, :unique_id
  end
end
