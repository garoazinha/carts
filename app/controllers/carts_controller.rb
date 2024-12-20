# frozen_string_literal: true

require 'pry'
class CartsController < ApplicationController
  before_action :set_cart
  before_action :set_product, only: %i[create add_item delete_item]

  def show
    if @cart.present?
      render json: @cart
    else
      head :not_found
    end
  end

  def create
    CartItem.create(product: @product, quantity: quantity_to_add, cart: @cart)

    if @cart.save
      render json: @cart
    else
      render json: @cart.errors, status: :unprocessable_entity
    end
  end

  def add_item
    cart_item = CartItem.find_or_initialize_by(cart: @cart, product: @product)

    cart_item.add_item(quantity_to_add)

    render json: @cart.reload
  end

  def delete_item
    cart_item = CartItem.find_by(cart: @cart, product: @product)

    if cart_item
      cart_item.destroy!

      render json: @cart.reload
    else
      render json: @cart.errors, status: :unprocessable_entity
    end
  end

  private

  def set_cart
    id = session[:current_cart_id]
    @cart = Cart.find(id)
  rescue ActiveRecord::RecordNotFound
    @cart = create_cart
  end

  def create_cart
    cart = Cart.create
    session[:current_cart_id] = cart.id
    cart
  end

  def set_product
    @product = Product.find(product_id)
  end

  def product_id
    params.require(:product_id)
  end

  def quantity_to_add
    params.require(:quantity)
  end
end
