# frozen_string_literal: true

class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0
  has_many :cart_items
  before_validation :set_total_price, :set_last_interaction_at

  has_many :products, through: :cart_items

  enum :status, {
    active: 'active', abandoned: 'abandoned'
  }

  def sum_total_price
    sum_of_cart_items = cart_items.map(&:total_price).sum.to_d

    update(total_price: sum_of_cart_items)
    update(last_interaction_at: Time.now)
  end

  def mark_as_abandoned
    abandoned!
  end

  def remove_if_abandoned
    destroy! if abandoned?
  end

  # Missing Stuff
  # Last Interaction At
  # Enum

  private

  def set_total_price
    self.total_price = 0 if total_price.blank?
  end

  def set_last_interaction_at
    self.last_interaction_at = Time.now if last_interaction_at.blank?
  end

  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado
end
