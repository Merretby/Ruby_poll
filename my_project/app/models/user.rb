class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
    has_many :posts, dependent: :restrict_with_error
    has_many :comments, dependent: :restrict_with_error

    validates :name, presence: true
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :role, presence: true, inclusion: { in: %w[admin member] }

    after_initialize :set_default_role, if: :new_record?

    def author_name
        name
    end

    def admin?
        role == "admin"
    end

    private

    def set_default_role
        self.role ||= "member"
    end
end