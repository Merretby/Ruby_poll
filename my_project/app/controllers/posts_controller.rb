class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  def index
    @posts = Post.includes(:user).recent
    @posts = @posts.published if params[:status] == 'published'
    @posts = @posts.drafts if params[:status] == 'drafts'
    @posts = @posts.by_author(params[:author_id]) if params[:author_id].present?
    @posts = @posts.search(params[:q]) if params[:q].present?
  end

  def show
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to posts_path, notice: 'Post was successfully created.' }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to posts_path, notice: 'Post was successfully updated.' }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to posts_path, notice: 'Post was successfully deleted.' }
    end
  end

  private

  def set_post
    @post = Post.includes(:user, :comments).find_by!(slug: params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to posts_path, alert: 'Post not found.'
  end

  def post_params
    params.require(:post).permit(:title, :body, :published_at, :user_id)
  end
end
