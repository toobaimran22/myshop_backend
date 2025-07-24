module Api
  module V1
    class CartsController < ApplicationController
      before_action :authenticate_user!

      def show
        cart = @current_user.carts.last || @current_user.carts.create
        authorize cart
        render json: cart, include: { cart_items: { include: :product } }
      end

      def add_item
        Rails.logger.info "Current user: #{@current_user.inspect}"
        cart = @current_user.carts.last || @current_user.carts.create
        
        authorize cart
        product = Product.find(params[:product_id])
        item = cart.cart_items.find_or_initialize_by(product: product)
        item.quantity = (item.quantity || 0) + params[:quantity].to_i
        if item.save
          render json: cart, include: { cart_items: { include: :product } }
        else
          render json: { errors: item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update_item
        cart = @current_user.carts.last
        authorize cart
        item = cart.cart_items.find_by(product_id: params[:product_id])
        if item&.update(quantity: params[:quantity])
          render json: cart, include: { cart_items: { include: :product } }
        else
          render json: { errors: item&.errors&.full_messages || ['Item not found'] }, status: :unprocessable_entity
        end
      end

      def remove_item
        cart = @current_user.carts.last
        authorize cart
        item = cart.cart_items.find_by(product_id: params[:product_id])
        if item&.destroy
          render json: cart, include: { cart_items: { include: :product } }
        else
          render json: { errors: ['Item not found'] }, status: :not_found
        end
      end
    end
  end
end 