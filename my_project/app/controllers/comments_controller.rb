class CommentsController < ApplicationController
  before_action :set_post

  def create
    @comment = @post.comments.build(comment_params)

    if @comment.save
      redirect_to @post, notice: "Comment added successfully."
    else
      redirect_to @post, alert: "Failed to add comment."
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
    params.require(:comment).permit(:content, :user_id)
  end
end