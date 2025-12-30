class CommentsController < ApplicationController
  before_action :set_post

  def create
    result = Comments::Create.call(
      post: @post,
      user: current_user,
      comment_params: comment_params
    )

    if result.success?
      redirect_to @post, notice: "Comment added successfully."
    else
      alert_message = case result.error_code
                      when :invalid
                        "Failed to add comment: #{result.error}"
                      else
                        "Failed to add comment."
                      end
      redirect_to @post, alert: alert_message
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    redirect_to post_path(@post), notice: "Comment deleted successfully."
  end

  private

  def set_post
    @post = Post.find_by!(slug: params[:post_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to posts_path, alert: 'Post not found.'
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end