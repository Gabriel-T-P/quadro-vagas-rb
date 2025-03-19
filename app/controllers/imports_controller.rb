class ImportsController < ApplicationController
  before_action :check_user_is_admin

  def new
    if params[:import_id].present?
      @import_id = params[:import_id]
      set_status_and_errors(@import_id)
    end
  end

  def create
    if params[:file].present?
      import_service = ImportService.new(params[:file])
      import_service.process
      set_status_and_errors(import_service.import_id)
      redirect_to new_import_path(import_id: import_service.import_id), notice: t(".process_initiated")
    else
      render :new, alert: t(".file_not_present"), status: :unprocessable_entity
    end
  end

  # def create
  #   respond_to do |format|
  #     if params[:file].present?
  #       import_service = ImportService.new(params[:file])
  #       import_service.process
  #       set_status_and_errors(import_service.import_id)

  #       format.html do
  #         redirect_to new_import_path(import_id: import_service.import_id), notice: t(".process_initiated")
  #       end

  #       format.turbo_stream do
  #         render turbo_stream: turbo_stream.replace(
  #           "import_status",
  #           partial: "import_status",
  #           locals: { status: @status, errors: @errors }
  #         )
  #       end
  #     else
  #       format.html { render :new, alert: t(".file_not_present"), status: :unprocessable_entity }
  #     end
  #   end
  # end

  private

  def set_status_and_errors(import_id)
    @status = REDIS.hgetall(import_id)
    @status.transform_values!(&:to_i)
    @errors = REDIS.lrange("#{import_id}:errors", 0, -1)
  end
end
