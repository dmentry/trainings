class ApplicationController < ActionController::Base
  # переключение локалей
    # before_action :switch_locale
  # передача параметра текущей локали через запросы
  # def default_url_options
  #   {locale: I18n.locale}
  # end

  # Позволяем использовать возможности пандита во всех контроллерах
  # include Pundit
  
  # Обработать ошибку авторизации
  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # private

  # def switch_locale(&action)
  #   locale = params[:locale] || I18n.default_locale
  #   I18n.locale = locale
  # end

  # def user_not_authorized
  #   # Перенаправляем юзера откуда пришел (или в корень сайта) с сообщением об ошибке
  #   flash[:alert] = 'Только для админа!'

  #   redirect_to(request.referrer || root_path)
  # end

  # Настройка для работы Девайза, когда юзер правит профиль
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :password, :password_confirmation, :remember_me])
    devise_parameter_sanitizer.permit(:account_update, keys: [:password, :password_confirmation, :current_password])
  end
end
