class UsersController < ApplicationController
  before_action :set_user, except: %i[index]
  before_action :authenticate_user!
  before_action :user_admin?, only: %i[index admin_login_as_user]

  def index
    @users = User.all

    data = []

    @users.each do |user|
      user_operator = IpFinderHelper.ip_address(user.current_sign_in_ip)

      user_data = if user_operator.empty?
                    '-'
                  else  
                    "#{user_operator[:country]}, #{user_operator[:regionName]}, #{user_operator[:city]}, #{user_operator[:isp]}"
                  end

      td = if user.current_sign_in_at.present?
             user.current_sign_in_at
           else
             Time.new(1, 1, 1, 1, 0, 0, 0)
           end

      data << [user, td, user_data]
    end

    @data = data.sort_by{ |h| h.second }.reverse
  end

  def show
  end

  def edit
  end

  def update
    (redirect_to @user, alarm: "Вам такое нельзя." and return) if current_user.name == 'guest'

    if @user.update(user_params)
      redirect_to @user, notice: "Данные были успешно обновлены."
    else
      render :edit
    end
  end

  def destroy
    (redirect_to @user, alarm: "Вам такое нельзя." and return) if current_user.name == 'guest'

    @user.destroy

    redirect_to users_url, notice: "Пользователь был удален."
  end

  def achivements
  end

  def admin_login_as_user
    user = User.find(params[:id])

    sign_in(:user, user, { :bypass => true })

    redirect_to root_path
  end

  private

  def set_user
    current_user.admin ? @user = User.find(params[:id]) : @user = current_user
  end

  def user_params
    params.require(:user).permit(:name, :email, :avatar)
  end
end
