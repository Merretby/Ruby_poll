class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authorize_admin!, only: [:index, :show, :new, :create, :edit, :update, :destroy]

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @user, notice: "User was successfully created." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @user, notice: "User was successfully updated." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to users_path, notice: "User was successfully deleted." }
    end
  end

  private

  def set_user
    @user = User.find(params.expect(:id))
  end

  def user_params
    params.expect(user: [:name, :email, :role])
  end

  def authorize_admin!
    unless current_user.admin?
      redirect_to root_path, alert: 'You are not authorized to access this page.'
    end
  end
end
