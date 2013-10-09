class AddPriceToCars < ActiveRecord::Migration
  def change
    add_column :cars, :price, :decimal
  end
end
