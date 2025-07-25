module Api
  module V1
    class ProductsController < ApplicationController
      before_action :set_product, only: [:show, :update, :destroy]
      before_action :authenticate_admin!, only: [:create, :update, :destroy]

      def index
        products = Product.all
        products = products.where(out_of_stock: false) unless @current_user&.admin?
        products = products.joins(:category).where('categories.name ILIKE ?', "%#{params[:category_name]}%") if params[:category_name].present?
        products = products.where('title ILIKE ?', "%#{params[:title]}%") if params[:title].present?
        products = products.where('price >= ?', params[:min_price]) if params[:min_price].present?
        products = products.where('price <= ?', params[:max_price]) if params[:max_price].present?
        products = products.order(created_at: :desc)
        products = products.page(params[:page]).per(params[:per_page] || 12)
        render json: {
          products: products.map { |product| product_json(product) },
          total_pages: products.total_pages,
          current_page: products.current_page
        }
      end

      def show
        authorize @product
        render json: product_json(@product)
      end

      def create
        @product = Product.new(product_params)
        if params[:image]
          @product.image.attach(params[:image])
        end
        if @product.save
          render json: product_json(@product), status: :created
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        authorize @product
        if params[:image]
          @product.image.attach(params[:image])
        end
        if @product.update(product_params)
          render json: @product
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @product
        @product.destroy
        head :no_content
      end

      private

      def set_product
        @product = Product.find(params[:id])
      end

      def product_json(product)
        product.as_json(only: [:id, :title, :description, :price, :quantity, :out_of_stock, :category_id]).merge(
          image_url: product.image.attached? ? url_for(product.image) : nil
        )
      end

      def product_params
        params.permit(:title, :description, :price, :quantity, :category_id)
      end
    end
  end
end 