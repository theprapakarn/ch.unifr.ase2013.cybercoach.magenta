class CreateBids < ActiveRecord::Migration
  def change
    create_table :bids do |t|
      t.decimal :price
      t.integer :user_id
      t.references :car

      t.timestamps
    end

    add_index :bids, :car_id
  end
end
