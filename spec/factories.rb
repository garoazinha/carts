FactoryBot.define do
    factory :shopping_cart, class: Cart do
      total_price { 1000 }
      last_interaction_at { Date.today }
    end
  end
  