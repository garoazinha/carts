# frozen_string_literal: true

class CartsController < ApplicationController
  before_action :set_cart, only: [:create]
  before_action :find_cart, only: %i[add_item show delete_item]
  before_action :set_product, only: %i[create add_item delete_item]

  def show
    if @cart.present?
      render json: @cart
    else
      head :not_found
    end
  end

  def create
    ## Changed this implementation to not do anything in case the product is already in cart
    if @cart.add_product(@product, quantity_to_add)
      render json: @cart
    else
      render json: @cart, status: :unprocessable_entity
    end
  end

  def add_item
    if @cart.add_item(@product, quantity_to_add)
      render json: @cart
    else
      render json: @cart, status: :unprocessable_entity
    end
  end

  def delete_item
    if @cart.remove_item(@product)
      render json: @cart.reload
    else
      render json: { errors: :product_not_in_cart }, status: :unprocessable_entity
    end
  end

  private

  def set_cart
    @cart = find_cart || create_cart
  end

  def find_cart
    id = session[:current_cart_id]
    @cart = Cart.find_by(id:)
  end

  def create_cart
    cart = Cart.create
    session[:current_cart_id] = cart.id
    cart
  end

  def set_product
    @product = Product.find_by(id: product_id)
  end

  def product_id
    params.require(:product_id)
  end

  def quantity_to_add
    params.require(:quantity)
  end
end
