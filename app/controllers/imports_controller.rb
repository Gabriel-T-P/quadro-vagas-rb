class ImportsController < ApplicationController
  before_action :check_user_is_admin

  def new; end

  def create
    if params[:file].present?
      ImportService.new(params[:file]).process
      flash[:notice] = t ".process_initiated"
    else
      flash.now[:alert] = t ".file_not_present"
      return render :new, status: :unprocessable_entity
    end
    redirect_to new_import_path
  end
end
