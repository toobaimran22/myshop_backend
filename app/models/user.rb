class User < ApplicationRecord
  has_secure_password

  enum :role, { user: 0, admin: 1 }

  validates :email, presence: true, uniqueness: true
  validates :role, presence: true
  validates :active, inclusion: { in: [true, false] }
  validates :username, presence: true, uniqueness: true

  has_many :orders
  has_many :carts
end
