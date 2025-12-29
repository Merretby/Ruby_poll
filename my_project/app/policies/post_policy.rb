class PostPolicy < ApplicationPolicy
  def show?
    is_published = record.published_at.present? && record.published_at <= Time.current
    return true if is_published
    
    return false unless user.present?
    user.admin? || record.user_id == user.id
  end

  def edit?
    user.admin? || record.user_id == user.id
  end

  def update?
    user.admin? || record.user_id == user.id
  end

  def destroy?
    user.admin?
  end

  def publish?
    user.admin? || record.user_id == user.id
  end

  def unpublish?
    user.admin? || record.user_id == user.id
  end

  relation_scope do |relation|
    next relation if user&.admin?
    
    if user.present?
      relation.where('published_at IS NOT NULL AND published_at <= ?', Time.current)
              .or(relation.where(user_id: user.id))
    else
      relation.where('published_at IS NOT NULL AND published_at <= ?', Time.current)
    end
  end
end
