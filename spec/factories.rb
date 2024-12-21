# frozen_string_literal: true

FactoryBot.define do
  factory :shopping_cart, class: Cart do
    total_price { 1000 }
    last_interaction_at { Time.zone.today }
  end

  factory :product do
    name { 'Test Product' }
    price { 15.0 }
  end

  factory :cart_item do
  end
end
