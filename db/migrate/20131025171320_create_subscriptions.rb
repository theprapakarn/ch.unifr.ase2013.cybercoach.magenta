class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.string :reference
      t.string :public_visible
      t.integer :sport_id
      t.integer :user_id
      t.integer :entry_id
      t.boolean :is_proxy
      t.datetime :subscribed_created
      t.timestamps
    end

    add_column :subscriptions, :participant_id, :integer
    add_index :subscriptions, :participant_id

    add_column :subscriptions, :partnership_id, :integer
    add_index :subscriptions, :partnership_id
  end
end
