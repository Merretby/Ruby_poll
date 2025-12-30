class PostsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_post, only: [:show, :edit, :update, :destroy, :publish, :unpublish]
  before_action only: :edit do
    authorize! @post, to: :update?
  end
  before_action only: :update do
    authorize! @post, to: :update?
  end
  before_action only: :destroy do
    authorize! @post, to: :destroy?
  end
  before_action only: :publish do
    authorize! @post, to: :publish?
  end
  before_action only: :unpublish do
    authorize! @post, to: :unpublish?
  end
  
  def index
    @posts = authorized_scope(Post.includes(:user).recent)
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
    publish_now = post_params[:published_at].present?
    
    result = Posts::Create.call(
      user: current_user,
      post_params: post_params.except(:published_at),
      publish_now: publish_now
    )
    
    if result.success?
      redirect_to posts_path, notice: 'Post was successfully created.'
    else
      @post = result.post
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to posts_path, notice: 'Post was successfully updated.'
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

  def publish
    result = Posts::Publish.call(post: @post, publisher: current_user)
    
    respond_to do |format|
      if result.success?
        format.turbo_stream
        format.html { redirect_to @post, notice: 'Post was successfully published.' }
      else
        format.html { redirect_to @post, alert: result.error }
      end
    end
  end

  def unpublish
    respond_to do |format|
      if @post.update(published_at: nil, publisher: nil)
        format.turbo_stream
        format.html { redirect_to @post, notice: 'Post was successfully unpublished.' }
      else
        format.html { redirect_to @post, alert: 'Failed to unpublish post.' }
      end
    end
  end

  private

  def set_post
    @post = Post.includes(:user, :comments).find_by!(slug: params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to posts_path, alert: 'Post not found.'
  end

  def post_params
    params.require(:post).permit(:title, :body, :published_at, :cover_image)
  end
end
