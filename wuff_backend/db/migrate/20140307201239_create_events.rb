class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.text :description
      t.string :location
      t.integer :admin
      t.text :party_list

      t.timestamps
    end
  end
end
