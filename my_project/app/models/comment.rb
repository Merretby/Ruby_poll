class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :content, presence: true, length: {in: 3..500}
end
