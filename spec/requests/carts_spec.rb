# frozen_string_literal: true

require 'rails_helper'
require 'pry'

RSpec.describe '/carts', type: :request do
  # pending "TODO: Escreva os testes de comportamento do controller de carrinho necessários para cobrir a sua implmentação #{__FILE__}"

  let(:product) { create(:product, name: 'Product test', price: 10.0) }
  let(:product2) { create(:product, name: 'Product fake', price: 50.0) }

  before do
    allow(Cart).to receive(:find).and_return(cart) if defined?(cart)
  end

  describe 'delete /delete_item' do
    subject { delete "/cart/#{product.id}" }

    let(:cart) { Cart.create }
    let(:expected_response) do
      {
        id: cart.id,
        products: [],
        total_price: 0.0
      }
    end

    context 'only one product in cart' do
      before { CartItem.create!(product: product, quantity: 2, cart: cart) }

      it 'returns list' do
        subject
        expect(JSON.parse(response.body, symbolize_names: true)).to eq expected_response
      end
    end

    context 'two products' do
      before do
        CartItem.create!(product: product2, cart: cart, quantity: 1)
        CartItem.create!(product: product, quantity: 2, cart: cart.reload)
      end

      let(:expected_response) do
        {
          id: Cart.last.id,
          products: [
            {
              id: product2.id,
              name: product2.name,
              quantity: 1,
              unit_price: 50.0,
              total_price: 50.0
            }
          ],
          total_price: 50.0
        }
      end

      it 'returns list' do
        subject

        expect(JSON.parse(response.body, symbolize_names: true)).to eq expected_response
      end
    end

    context 'product not in cart' do
      before { CartItem.create!(product: product2, quantity: 2, cart: cart) }

      it 'returns not found' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'create' do
    context 'there is cart' do
      subject { post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json }

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

      it 'returns success' do
        subject
        expect(response).to be_successful
      end

      it 'returns payload' do
        subject
        expect(JSON.parse(response.body, symbolize_names: true)).to eq expected_response
      end
    end

    context 'there is no cart' do
      subject { post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json }

      let(:expected_response) do
        {
          id: Cart.last.id,
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

      it 'returns success' do
        subject
        expect(response).to be_successful
        expect(JSON.parse(response.body, symbolize_names: true)).to eq expected_response
      end
    end

    context 'invalid quantity' do
      subject { post '/cart', params: { product_id: product.id, quantity: -12 }, as: :json }

      let(:cart) { Cart.create }

      it 'fails to add' do
        subject
        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context 'product does not exist' do
      subject { post '/cart', params: { product_id: 1111111333, quantity: 2 }, as: :json }

      let(:cart) { Cart.create }

      it 'fails to add' do
        subject
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'show' do
    context 'there is cart' do
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
