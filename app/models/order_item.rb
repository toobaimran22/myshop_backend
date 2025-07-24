class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }
  validates :price_at_purchase, numericality: { greater_than_or_equal_to: 0 }
end
