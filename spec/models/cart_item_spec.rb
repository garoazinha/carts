# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartItem, type: :model do
  context 'when validating' do
    it 'validates numericality of quantity' do
      cart_item = described_class.new(quantity: -1)
      expect(cart_item.valid?).to be_falsey
      expect(cart_item.errors[:quantity]).to include('must be greater than or equal to 0')
    end

    it 'validates presence of cart' do
      cart_item = described_class.new
      expect(cart_item.valid?).to be_falsey
      expect(cart_item.errors[:cart]).to include('must exist')
    end

    it 'validates presence of product' do
      cart_item = described_class.new
      expect(cart_item.valid?).to be_falsey
      expect(cart_item.errors[:product]).to include('must exist')
    end
  end

  context 'when adding items' do
    let(:shopping_cart) { create(:shopping_cart) }
    let(:product) { create(:product, price: 10.0) }

    it 'changes cart total price' do
      cart_item = described_class.new(cart: shopping_cart, product:, quantity: 2)

      expect { cart_item.save }.to change { shopping_cart.total_price }.to(20.0)
    end
  end

  describe 'add_item' do
    let(:shopping_cart) { create(:shopping_cart) }
    let(:product) { create(:product, price: 10.0) }

    it 'changes quantity' do
      cart_item = described_class.create(cart: shopping_cart, product:, quantity: 1)

      expect { cart_item.add_item(2) }.to change { cart_item.quantity }.by(2)
    end
  end
end
