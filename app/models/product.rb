# frozen_string_literal: true

class Product < ApplicationRecord
  validates_presence_of :name, :price
  validates_numericality_of :price, greater_than_or_equal_to: 0

  def format_price
    price.to_f
  end
end
