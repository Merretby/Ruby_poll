module Comments
  class Create < ApplicationService

    def initialize(post:, user:, comment_params:)
      @post = post
      @user = user
      @comment_params = comment_params
    end

    def call
      comment = @post.comments.build(@comment_params.merge(user: @user))

      result = ActiveRecord::Base.transaction do
        if comment.save
          send_notifications(comment)
          Result.new(success: true, comment: comment)
        else
          raise ActiveRecord::Rollback
        end
      end || Result.new(
        success: false,
        comment: comment,
        error: comment.errors.full_messages.join(', '),
        error_code: :invalid
      )
      
      result
    end

    private

    def send_notifications(comment)
      CommentMailer.new_comment(comment, @post.user).deliver_later unless @post.user == @user
      
      previous_commenters = @post.comments.where.not(id: comment.id).includes(:user).map(&:user).uniq - [@post.user, @user]
      previous_commenters.each do |commenter|
        CommentMailer.new_comment(comment, commenter).deliver_later
      end
    end

  end
end