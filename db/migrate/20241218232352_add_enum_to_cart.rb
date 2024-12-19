class AddEnumToCart < ActiveRecord::Migration[7.1]
  def change
    create_enum :cart_status, ["active", "abandoned"]

    add_column :carts, :status, :enum, enum_type: :cart_status, default: "active", null: false
  end
end
