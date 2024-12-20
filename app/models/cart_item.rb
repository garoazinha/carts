# frozen_string_literal: true

class CartItem < ApplicationRecord
  belongs_to :cart, autosave: true
  belongs_to :product

  after_commit :update_cart
  before_validation :set_default_quantity

  validates :product, :cart, presence: true
  validates_numericality_of :quantity, greater_than_or_equal_to: 0

  delegate :name, :format_price, :price, to: :product

  def total_price
    format_price * quantity
  end

  def add_item(quantity_to_add)
    update(quantity: self.quantity += quantity_to_add)
    self
  end

  def update_cart
    cart.reload.sum_total_price
  end

  private

  def set_default_quantity
    self.quantity = 0 if self.quantity.blank?
  end
end
