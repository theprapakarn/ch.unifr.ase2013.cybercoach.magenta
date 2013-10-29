class CreateSports < ActiveRecord::Migration
  def change
    create_table :sports do |t|
      t.string :reference
      t.string :name
      t.boolean :is_proxy
      t.timestamps
    end
  end
end
