require 'pry'
class CartsController < ApplicationController
  before_action :set_cart
  before_action :set_product

  def show
    if @cart.present?
      render json: @cart
    else
      head :not_found
    end
  end

  def create
    if @product
      @cart.cart_items.build(product: @product, quantity: params[:quantity])
    end

    if @cart.save
      render json: @cart
    else
      render json: @cart.errors, status: :unprocessable_entity
    end
  end

  def add_item
    hey = CartItem.find_or_initialize_by(cart: @cart, product: @product)
    if hey.quantity.present?
      hey.quantity += params[:quantity]
    else
      hey.quantity = 1
    end
    hey.save!
  end

  def delete_item
    # binding.pry
    hey = CartItem.find_by(cart: @cart, product: @product)
    if hey
      hey.destroy!
      
      render json: @cart.reload
    else
      head :not_found
    end
  end

  private
    def set_cart
      id = session[:current_cart_id]
      @cart = if id
        Cart.find(id)
      else
        cart = Cart.create
      end

      session[:current_cart_id] = @cart.id
    end

    def set_product
      @product = Product.find(params[:product_id]) if params[:product_id]
    end

    def permitted_params
      params.permit!
    end
end
