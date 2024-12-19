class AddCartItemTable < ActiveRecord::Migration[7.1]
  def change
    create_table :cart_items do |t|
      t.integer :quantity
      t.belongs_to :cart
      t.belongs_to :product

      t.timestamps
    end
  end
end
