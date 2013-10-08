class CreateCars < ActiveRecord::Migration
  def change
    create_table :cars do |t|
      t.string :model
      t.text :brand

      t.timestamps
    end
  end
end
