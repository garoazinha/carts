# frozen_string_literal: true

class CartItemSerializer < ActiveModel::Serializer
  belongs_to :product
  attribute :name
  attribute :format_price, key: :unit_price
  attribute :total_price
  attribute :quantity
  attribute :product_id, key: :id
end
