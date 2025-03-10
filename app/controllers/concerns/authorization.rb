module Authorization
  extend ActiveSupport::Concern

  private def authorize_dean
    unless current_person&.is_a?(Dean)
      respond_to do |format|
        flash[:alert] = "Only deans are allowed to perform this action."
        format.html { redirect_to root_path }
        format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
      end
      return false
    end
    return true
  end
end 