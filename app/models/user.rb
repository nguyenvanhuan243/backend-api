class User < ApplicationRecord
  validates :email, presence: true
  validates :password, presence: true
  validates :email, uniqueness: true
end
