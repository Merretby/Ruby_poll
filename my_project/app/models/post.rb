class Post < ApplicationRecord
    include ActionView::RecordIdentifier
    
    belongs_to :user
    belongs_to :publisher, class_name: 'User', optional: true
    has_many :comments, dependent: :destroy
    has_one_attached :cover_image

    validates :title, presence: true, length: {in: 5..120}
    validates :body, presence: true
    validates :slug, uniqueness: { scope: :user_id }
    validate :acceptable_cover_image

    before_validation :generate_slug
    after_update_commit :broadcast_status_update, if: :saved_change_to_published_at?

    scope :published, -> {where.not(published_at: nil).where('published_at <= ?', Time.current)}
    scope :drafts, -> {where(published_at: nil).or(where('published_at > ?', Time.current))}
    scope :recent, -> {order(published_at: :desc)}
    scope :by_author, ->(user_id) {where(user_id: user_id)}
    scope :search, ->(query) {where('title LIKE ? OR body LIKE ?', "%#{query}%", "%#{query}%")}

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

    def acceptable_cover_image
        return unless cover_image.attached?

        unless cover_image.byte_size <= 5.megabytes
            errors.add(:cover_image, "is too big. Maximum size is 5MB.")
        end
        acceptable_types = ["image/jpeg", "image/png", "image/gif"]
        unless acceptable_types.include?(cover_image.content_type)
            errors.add(:cover_image, "must be a JPEG, PNG, or GIF.")
        end
    end

    def generate_slug
        base_slug = title.parameterize
        self.slug = base_slug

        count = 1
        while Post.where(slug: slug, user_id: user_id).where.not(id: id).exists?
            self.slug = "#{base_slug}-#{count}"
            count += 1
        end
    end

    def broadcast_status_update
        broadcast_replace_to "posts",
            target: "#{dom_id(self, :status)}",
            partial: "posts/status",
            locals: { post: self }
    end
end
