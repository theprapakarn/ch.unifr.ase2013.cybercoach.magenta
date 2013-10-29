class CreatePartnerships < ActiveRecord::Migration
  def change
    create_table :partnerships do |t|
      t.string :reference
      t.string :public_visible
      t.integer :first_participant_id
      t.integer :second_participant_id
      t.boolean :first_participant_confirmed
      t.boolean :second_participant_confirmed
      t.datetime :date_created
      t.boolean :is_proxy
      t.timestamps
    end
  end
end
