class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def check_user_is_admin
    redirect_to root_path, notice: I18n.t("negated_access") unless Current.user.admin?
  end
end
