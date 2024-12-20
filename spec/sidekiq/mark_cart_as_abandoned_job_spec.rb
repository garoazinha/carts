# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  describe 'perform' do
    before do
      create_list(:shopping_cart, 2) do |cart, i|
        cart.last_interaction_at = (3 + i).hours.ago

        cart.save!
      end

      create_list(:shopping_cart, 2) do |cart, i|
        cart.last_interaction_at = (6 + i).days.ago

        cart.save!
      end
    end

    subject { described_class.new.perform }

    it 'removes old carts' do
      expect { subject }.to change { Cart.count }.by(-1)
    end

    it 'marks carts as abandoned' do
      expect { subject }.to change { Cart.abandoned.count }.by(3)
    end
  end
end
