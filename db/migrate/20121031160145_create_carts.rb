class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
      t.string :product_name
      t.integer :quantity
      t.decimal :price

      t.timestamps
    end
  end
end
