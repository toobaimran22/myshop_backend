class Product < ApplicationRecord
  belongs_to :category
  has_many :cart_items
  has_many :order_items

  validates :title, :price, :quantity, :category_id, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }

  before_save :update_out_of_stock

  private

  def update_out_of_stock
    self.out_of_stock = quantity <= 0
  end
end
