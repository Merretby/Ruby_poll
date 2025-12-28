module Posts
  class Create < ApplicationService
    def initialize(user:, post_params:, publish_now: false)
      @user = user
      @post_params = post_params
      @publish_now = publish_now
    end

    def call
      post = @user.posts.build(@post_params)

      if @publish_now
        post.published_at = Time.current
      end

      if post.save
        Result.new(success: true, post: post)
      else
        Result.new(success: false, post: post, error: post.errors.full_messages.join(', '))
      end
    end
  end
end
