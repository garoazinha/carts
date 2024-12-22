# frozen_string_literal: true

class Cart < ApplicationRecord
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }
  before_validation :set_total_price, :set_last_interaction_at

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  enum :status, {
    active: 'active', abandoned: 'abandoned'
  }

  def sum_total_price
    sum_of_cart_items = cart_items.sum(&:total_price)

    update(total_price: sum_of_cart_items, last_interaction_at: Time.zone.now)
  end

  def add_product(product, quantity)
    cart_item = fetch_cart_item(product)

    return cart_item if cart_item.persisted?

    cart_item.add_item(quantity)
    save
  end

  def add_item(product, quantity)
    cart_item = fetch_cart_item(product)

    cart_item.add_item(quantity)
    save
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
    cart_items.find_or_initialize_by(product: product)
  end

  def set_total_price
    self.total_price = 0 if total_price.blank?
  end

  def set_last_interaction_at
    self.last_interaction_at = Time.zone.now if last_interaction_at.blank?
  end
end
