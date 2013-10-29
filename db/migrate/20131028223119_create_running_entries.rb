class CreateRunningEntries < ActiveRecord::Migration
  def change
    create_table :running_entries do |t|
      t.string :course_length
      t.string :course_type
      t.integer :number_of_round
      t.string :track

      t.timestamps
    end
  end
end
