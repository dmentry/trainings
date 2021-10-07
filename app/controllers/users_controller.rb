class UsersController < ApplicationController
  before_action :set_user, except: :index
  before_action :authenticate_user!

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: "Данные были успешно обновлены."
    else
      render :edit
    end
  end

  def destroy
    @user.destroy

    redirect_to users_url, notice: "Пользователь был удален."
  end

  def achivements
    if current_user.exercises.count <= 1
      redirect_to trainings_url, alert: "У вас еще недостаточно данных для статистики."
    else
      @exercise_name_vocs = StatisticsHelper.user_profile_stat(current_user)
    end
  end

  def take_money
  end

  def process_money_out
    @rubles = current_user.money.round
    current_user.money = 0.0
    current_user.save!

    redirect_to @user, notice: "Пиастры были успешно конверитрованы в рубли и выведены."
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
