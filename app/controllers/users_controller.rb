class UsersController < ApplicationController
  # before_action :set_user, only: %i[ show edit update destroy ]
  before_action :set_user, except: :index
  before_action :authenticate_user!

  def index
    @users = User.all
  end

  # GET /users/1
  def show
  end

  # GET /users/1/edit
  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: "Данные были успешно обновлены."
    else
      render :edit
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy
      redirect_to users_url, notice: "Пользователь был удален."
  end

  private

  def set_user
    # @user = User.find(params[:id])
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
