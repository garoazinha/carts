require 'rails_helper'
require 'pry'

RSpec.describe "/carts", type: :request do
  pending "TODO: Escreva os testes de comportamento do controller de carrinho necessários para cobrir a sua implmentação #{__FILE__}"

  describe 'delete' do
    let(:cart) { Cart.create }
    let(:product) { Product.create(name: 'Product test', price: 10.0) }
    let(:product_2) { Product.create(name: 'Product fake', price: 50.0) }
    
    subject { delete "/cart/#{product.id}" }

    let(:expected_response) {
      {
        id: Cart.last.id,
        products: [],
        total_price: 0.0
      }
    }

    context 'only one product in cart' do
      before { CartItem.create!(product: product, quantity: 2, cart: cart ) }

      it 'returns list' do
        subject
        expect(JSON.parse(response.body, symbolize_names: true)).to eq expected_response
      end
    end

    context 'two products' do
      before do
        CartItem.create!(product: product_2, cart: cart, quantity: 1)
        CartItem.create!(product: product, quantity: 2, cart: cart.reload )
      end

      let(:expected_response) {
        {
          id: Cart.last.id,
          products: [
            {
              id: product_2.id,
              name: product_2.name,
              quantity: 1,
              unit_price: 50.0,
              total_price: 50.0,
            },
          ],
          total_price: 50.0
        }
      }

      it 'returns list' do
        subject

        expect(JSON.parse(response.body, symbolize_names: true)).to eq expected_response
      end
    end

    context 'product not in cart' do

      before { CartItem.create!(product: product_2, quantity: 2, cart: cart ) }

      it 'returns not found' do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end
  end
  
  describe "POST" do
    context 'there is cart' do
      let(:cart) { Cart.create }
      # TODO change to factory
      let(:product) { Product.create(name: 'Product test', price: 10.0) }

      subject { post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json }

      let(:expected_response) {
        {
          id: cart.id, 
          products: [
            {
              id: product.id,
              name: product.name,
              quantity: 2,
              unit_price: 10.0,
              total_price: 20.0,
            },
          ],
          total_price: 20.0
        }
      }

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
      let(:product) { Product.create(name: 'Product test', price: 10.0) }

      subject { post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json }

      let(:expected_response) {
        {
          id: Cart.last.id, 
          products: [
            {
              id: product.id,
              name: product.name,
              quantity: 2,
              unit_price: 10.0,
              total_price: 20.0,
            },
          ],
          total_price: 20.0
        }
      }

      it 'returns success' do
        subject
        expect(response).to be_successful
        expect(JSON.parse(response.body, symbolize_names: true)).to eq expected_response
      end
    end
  end

  describe "Show" do
    context 'there is cart' do
      let(:cart) { Cart.create }
      # TODO change to factory
      let(:product) { Product.create(name: 'Product test', price: 10.0) }
      let(:product_2) { Product.create(name: 'Product fake', price: 20.0) }
      before { CartItem.create!(product: product, quantity: 2, cart: cart ) }

      subject { get '/cart' }

      let(:expected_response) {
        {
          id: cart.id, 
          products: [
            {
              id: product.id,
              name: product.name,
              quantity: 2,
              unit_price: 10.0,
              total_price: 20.0,
            },
          ],
          total_price: 20.0
        }
      }

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
  
  before do
    post '/cart'
    allow(Cart).to receive(:find).and_return(cart) if defined?(cart)
  end

  describe "POST /add_items" do
    let(:cart) { Cart.create }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
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
  end
end
