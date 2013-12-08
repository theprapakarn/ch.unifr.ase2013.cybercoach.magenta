class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.string :reference
      t.string :public_visible
      t.integer :user_id
      t.integer :subscription_id
      t.boolean :is_proxy
      t.timestamps
    end
  end
end
