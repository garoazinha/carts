# frozen_string_literal: true

class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0
  before_validation :set_total_price, :set_last_interaction_at

  has_many :cart_items
  has_many :products, through: :cart_items

  enum :status, {
    active: 'active', abandoned: 'abandoned'
  }

  def sum_total_price
    sum_of_cart_items = cart_items.sum(&:total_price)

    update(total_price: sum_of_cart_items, last_interaction_at: Time.now)
  end

  def add_item(product, quantity)
    cart_item = fetch_cart_item(product)

    cart_item.add_item(quantity)
  end

  def remove_item(product)
    return if products.exclude?(product)

    cart_item = fetch_cart_item(product)
    cart_item.destroy!
  end

  def mark_as_abandoned
    abandoned!
  end

  def remove_if_abandoned
    destroy! if abandoned?
  end

  private

  def fetch_cart_item(product)
    cart_items.find_or_initialize_by(product_id: product&.id)
  end

  def set_total_price
    self.total_price = 0 if total_price.blank?
  end

  def set_last_interaction_at
    self.last_interaction_at = Time.now if last_interaction_at.blank?
  end
end
