class Post < ApplicationRecord
    belongs_to :user
    has_many :comments, dependent: :destroy

    validates :title, presence: true, length: {in: 5..120}
    validates :body, presence: true
    validates :slug, uniqueness: { scope: :user_id }

    before_validation :generate_slug

    def published?
        published_at.present?
    end

    def publish!
        update!(published_at: Time.current)
    end

    def to_param
        slug
    end

    private

    def generate_slug
        base_slug = title.parameterize
        self.slug = base_slug

        count = 1
        while Post.where(slug: slug, user_id: user_id).where.not(id: id).exists?
            self.slug = "#{base_slug}-#{count}"
            count += 1
        end
    end
end
