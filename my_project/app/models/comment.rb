class Comment < ApplicationRecord
  belongs_to :post, counter_cache: true
  belongs_to :user

  validates :content, presence: true, length: {in: 3..500}
end
