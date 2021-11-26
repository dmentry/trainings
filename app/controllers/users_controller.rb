class UsersController < ApplicationController
  # before_action :set_user, only: %i[ show edit update destroy ]
  before_action :set_user, except: %i[ index ]
  before_action :authenticate_user!
  before_action :user_admin?, only: %i[index]

  def index
    @users = User.all
  end

  def show
  end

  def edit
  end

  def update
    unless current_user.name == 'guest'
      if @user.update(user_params)
        redirect_to @user, notice: "Данные были успешно обновлены."
      else
        render :edit
      end
    else
      redirect_to @user, alarm: "Вам такое нельзя."
    end
  end

  def destroy
    unless current_user.name == 'guest'
      @user.destroy
        redirect_to users_url, notice: "Пользователь был удален."
    else
      redirect_to @user, alarm: "Вам такое нельзя."
    end
  end

  def achivements
  end

  private

  def set_user
    @user = User.find(params[:id])
    # @user = current_user
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
