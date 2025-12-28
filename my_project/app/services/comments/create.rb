module Comments
  class Create < ApplicationService
    SPAM_KEYWORDS = %w[
      viagra
      casino
      lottery
      pills
      crypto
      click-here
      winner
      congratulations
    ].freeze

    def initialize(post:, user:, comment_params:)
      @post = post
      @user = user
      @comment_params = comment_params
    end

    def call
      comment = @post.comments.build(@comment_params.merge(user: @user))

      # Check for spam
      if spam_detected?(comment.content)
        return Result.new(
          success: false,
          comment: comment,
          error: "Comment blocked: spam detected",
          error_code: :spam_blocked
        )
      end

      # Validate and save with transaction
      ActiveRecord::Base.transaction do
        if comment.save
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
    end

    private

    def spam_detected?(content)
      return false if content.blank?
      
      normalized_content = content.downcase
      SPAM_KEYWORDS.any? { |keyword| normalized_content.include?(keyword) }
    end
  end
end
