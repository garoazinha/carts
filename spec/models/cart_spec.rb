# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include('must be greater than or equal to 0')
    end
  end

  describe 'mark_as_abandoned' do
    let(:shopping_cart) { create(:shopping_cart) }

    it 'marks the shopping cart as abandoned if inactive for a certain time' do
      shopping_cart.update(last_interaction_at: 3.hours.ago)
      expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned? }.from(false).to(true)
    end
  end

  describe 'remove_if_abandoned' do
    let(:shopping_cart) { create(:shopping_cart, last_interaction_at: 7.days.ago) }

    it 'removes the shopping cart if abandoned for a certain time' do
      shopping_cart.mark_as_abandoned
      expect { shopping_cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
    end
  end

  describe 'add_item' do
    let(:shopping_cart) { create(:shopping_cart) }
    let(:product) { create(:product, price: 10.0) }

    it 'adds product to cart' do
      expect { shopping_cart.add_item(product, 2) }.to change { shopping_cart.products.count }.by(1)
    end

    it 'updates total price' do
      expect { shopping_cart.add_item(product, 2) }.to change { shopping_cart.total_price }.to(20.0)
    end

    context 'product already in cart' do
      before { shopping_cart.add_product(product, 1) }

      it 'updates total price' do
        expect { shopping_cart.add_item(product, 2) }.to change { shopping_cart.total_price }.to(30.0)
      end
    end
  end

  describe 'add_product' do
    let(:shopping_cart) { create(:shopping_cart) }
    let(:product) { create(:product, price: 10.0) }

    it 'adds a product' do
      expect { shopping_cart.add_product(product, 2) }.to change { shopping_cart.total_price }.to(20.0)
    end
    
    context 'product was already in cart' do
      before { shopping_cart.add_product(product, 1) }

      it 'doesnt change cart' do
        expect { shopping_cart.add_product(product, 2) }.not_to change { shopping_cart.total_price }
      end
    end

    context 'product does not exist' do
      it 'doesnt change cart' do
        expect { shopping_cart.add_product(nil, 2) }.not_to change { shopping_cart.total_price }
      end
    end
  end
end
