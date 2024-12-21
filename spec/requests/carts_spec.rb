# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/carts', type: :request do
  let(:product) { create(:product, name: 'Product test', price: 10.0) }
  let(:product2) { create(:product, name: 'Product fake', price: 50.0) }

  before do
    allow(Cart).to receive(:find_by).and_return(cart) if defined?(cart)
  end

  describe 'DELETE /:product_id' do
    subject { delete "/cart/#{product.id}" }

    let(:cart) { Cart.create }

    context 'when only one product in cart' do
      before { CartItem.create!(product: product, quantity: 2, cart: cart) }

      it 'cart becomes empty' do
        expect { subject }.to change { cart.reload.products.size }.to be_zero
      end

      it 'total_price is zero' do
        expect { subject }.to change { cart.reload.total_price }.to(0.0)
      end
    end

    context 'when there are two products in cart' do
      before do
        CartItem.create!(product: product2, cart: cart, quantity: 1)
        CartItem.create!(product: product, quantity: 2, cart: cart.reload)
      end

      it 'deletes one but keeps one' do
        expect { subject }.to change { cart.reload.products.size }.by(-1)
      end
    end

    context 'when product not in cart' do
      before { CartItem.create!(product: product2, quantity: 2, cart: cart) }

      it 'returns unprocessable entity' do
        subject

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'create' do
    context 'when there is cart' do
      subject { post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json }

      let(:cart) { Cart.create }

      it 'returns success' do
        subject

        expect(response).to be_successful
      end

      it 'adds product to cart' do
        expect { subject }.to change { cart.reload.products.size }.by(1)
      end

      it 'adds product to cart' do
        expect { subject }.to change { cart.reload.products.size }.by(1)
      end
    end

    context 'when there is no cart' do
      subject { post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json }

      it 'creates one cart returns success' do
        expect { subject }.to change(Cart, :count).by(1)

        expect(response).to be_successful
      end
    end

    context 'when invalid quantity is given' do
      subject { post '/cart', params: { product_id: product.id, quantity: -12 }, as: :json }

      let(:cart) { Cart.create }

      it 'fails to add' do
        subject

        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context 'when product does not exist' do
      subject { post '/cart', params: { product_id: 1_111_111_333, quantity: 2 }, as: :json }

      let(:cart) { Cart.create }

      it 'fails to add' do
        subject

        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'show' do
    context 'when there is cart' do
      subject { get '/cart' }

      let(:cart) { Cart.create }
      let(:expected_response) do
        {
          id: cart.id,
          products: [
            {
              id: product.id,
              name: product.name,
              quantity: 2,
              unit_price: 10.0,
              total_price: 20.0
            }
          ],
          total_price: 20.0
        }
      end

      before { CartItem.create!(product: product, quantity: 2, cart: cart) }

      it 'returns success' do
        subject

        expect(response).to be_successful
      end

      it 'returns payload' do
        subject

        expect(JSON.parse(response.body, symbolize_names: true)).to eq expected_response
      end
    end
  end

  describe 'POST /add_items' do
    let(:cart) { Cart.create }
    let(:product) { create(:product, name: 'Product test', price: 10.0) }
    let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

    context 'when the product already is in the cart' do
      subject do
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end

    context 'when product is not in cart' do
      subject do
        post '/cart/add_items', params: { product_id: product2.id, quantity: 1 }, as: :json
      end

      it 'updates the amount of products in cart' do
        expect { subject }.to change { cart.reload.products.size }.by(1)
      end
    end
  end
end
