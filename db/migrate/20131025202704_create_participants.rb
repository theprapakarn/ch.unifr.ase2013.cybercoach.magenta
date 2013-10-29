class CreateParticipants < ActiveRecord::Migration
  def change
    create_table :participants do |t|
      t.string :reference
      t.string :public_visible
      t.integer :user_id
      t.string :first_name
      t.string :last_name
      t.boolean :is_proxy
      t.datetime :date_created
      t.timestamps
    end
  end
end
