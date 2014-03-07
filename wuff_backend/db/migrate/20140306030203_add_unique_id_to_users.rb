class AddUniqueIdToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :unique_id, :string
  	add_index :users, :unique_id, unique: true
  end
end
