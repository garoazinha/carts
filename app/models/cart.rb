class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0
  has_many :cart_items
  before_validation :set_total_price

  has_many :products, through: :cart_items

  enum :status, {
    active: 'active', abandoned: 'abandoned'
  }

  def last_interaction_at
    updated_at
  end

  def sum_total_price
    sum_of_cart_items = cart_items.map do |cart_item|
      cart_item.total_price
    end.sum.to_d

    update(total_price: sum_of_cart_items)
  end

  def last_interaction_at=(damn)
    updated_at=(damn)
  end

  def mark_as_abandoned
    abandoned!
  end

  def remove_if_abandoned
    abandoned? ? delete : nil
  end

  # Missing Stuff
  # Last Interaction At
  # Enum

  private
    def set_total_price
      self.total_price = 0 if self.total_price.blank?
    end

  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado
end
