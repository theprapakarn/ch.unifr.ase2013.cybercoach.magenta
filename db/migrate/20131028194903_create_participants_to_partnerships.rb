class CreateParticipantsToPartnerships < ActiveRecord::Migration
  def change
    create_table :participants_to_partnerships do |t|
      t.integer :participant_id
      t.integer :partnership_id

      t.timestamps
    end
  end
end
