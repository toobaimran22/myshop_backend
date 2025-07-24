module Api
  module V1
    class OrdersController < ApplicationController
      before_action :authenticate_user!
      before_action :set_order, only: [:show, :approve]

      def index
        if @current_user.admin?
          orders = Order.all.includes(:order_items, :user)
        else
          orders = @current_user.orders.includes(:order_items, :user)
        end
        render json: orders, include: {
          user: { only: [:id, :username, :email] },
          order_items: { include: :product }
        }
      end

      def show
        authorize @order
        render json: @order, include: { order_items: { include: :product } }
      end

      def create
        cart = @current_user.carts.last
        if cart.nil? || cart.cart_items.empty?
          return render json: { error: 'Cart is empty' }, status: :unprocessable_entity
        end

        order = Order.new(
          user: @current_user,
          status: 'pending',
          total_price: 0,
          name: params[:shipping_address][:name],
          address: params[:shipping_address][:address],
          city: params[:shipping_address][:city]
        )
        cart.cart_items.each do |item|
          order.order_items.build(
            product: item.product,
            quantity: item.quantity,
            price_at_purchase: item.product.price
          )
          order.total_price += item.product.price * item.quantity
        end

        authorize order

        if order.save
          cart.cart_items.destroy_all
          render json: order, include: { order_items: { include: :product } }, status: :created
        else
          render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def approve
        authorize @order, :approve?
        if @order.pending?
          ActiveRecord::Base.transaction do
            @order.order_items.each do |item|
              product = item.product
              if product.quantity < item.quantity
                raise ActiveRecord::Rollback, "Insufficient stock for #{product.title}"
              end
              product.quantity -= item.quantity
              product.save!
            end
            @order.update!(status: 'approved')
            Product.where(quantity: 0).update_all(out_of_stock: true)
          end
          render json: @order, include: { order_items: { include: :product } }
        else
          render json: { error: 'Order already approved' }, status: :unprocessable_entity
        end
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def set_order
        @order = Order.find(params[:id])
      end
    end
  end
end 