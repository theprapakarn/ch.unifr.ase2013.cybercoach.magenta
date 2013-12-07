class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :reference
      t.string :name
      t.integer :user_id
      t.datetime :start_time
      t.datetime :end_time
      t.integer :sport
      t.integer :owner_id
      t.boolean :is_proxy
      t.string :place
      t.string :comment

      t.timestamps
    end
  end
end
