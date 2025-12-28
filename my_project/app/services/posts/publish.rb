module Posts
  class Publish < ApplicationService
    def initialize(post:, publisher:)
      @post = post
      @publisher = publisher
    end

    def call
      if @post.published?
        return Result.new(
          success: false,
          post: @post,
          error: "Post is already published"
        )
      end

      if @post.update(published_at: Time.current, publisher: @publisher)
        Result.new(success: true, post: @post)
      else
        Result.new(
          success: false,
          post: @post,
          error: @post.errors.full_messages.join(', ')
        )
      end
    end
  end
end
