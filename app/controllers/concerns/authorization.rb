module Authorization
  extend ActiveSupport::Concern

  private def authorize_dean
    unless current_person&.is_a?(Dean)
      flash[:alert] = "Only deans are allowed to perform this action."
      redirect_to root_path
      return false
    end
    return true
  end
end 