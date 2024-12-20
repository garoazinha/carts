# frozen_string_literal: true

class AddLastUpdatedAt < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :last_interaction_at, :datetime, null: false
  end
end
