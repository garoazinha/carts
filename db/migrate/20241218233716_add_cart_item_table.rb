# frozen_string_literal: true

class AddCartItemTable < ActiveRecord::Migration[7.1]
  def change
    create_table :cart_items do |t|
      t.integer :quantity, default: 0
      t.belongs_to :cart
      t.belongs_to :product
      t.index %i[cart_id product_id], unique: true

      t.timestamps
    end
  end
end
