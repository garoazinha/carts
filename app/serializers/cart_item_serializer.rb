# frozen_string_literal: true

class CartItemSerializer < ActiveModel::Serializer
  belongs_to :product
  attribute :name
  attribute :format_price, key: :unit_price, if: -> { object.product.present? }
  attribute :total_price, if: -> { object.product.present? }
  attribute :quantity
  attribute :product_id, key: :id
  attribute :errors, if: -> { object.errors.any? }
end
