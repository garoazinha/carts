class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product
  after_commit :update_cart
  validates :product, :cart, presence: true
  delegate :name, :format_price, :price, to: :product

  def total_price
    format_price * quantity
  end

  def update_cart
    require 'pry'

    self.cart.reload.sum_total_price
  end
end