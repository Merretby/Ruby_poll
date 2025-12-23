class User < ApplicationRecord
    has_many :posts, dependent: :restrict_with_error
    has_many :comments, dependent: :restrict_with_error

    validates :name, presence: true
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :role, presence: true, inclusion: { in: %w[admin member] }

    after_initialize :set_default_role, if: :new_record?

    def author_name
        name
    end

    private

    def set_default_role
        self.role ||= "member"
    end
end