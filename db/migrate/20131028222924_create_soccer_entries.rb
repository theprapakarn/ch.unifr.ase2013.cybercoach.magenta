class CreateSoccerEntries < ActiveRecord::Migration
  def change
    create_table :soccer_entries do |t|

      t.timestamps
    end
  end
end
