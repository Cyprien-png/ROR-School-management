module Authorization
  extend ActiveSupport::Concern

  private def authorize_dean
    unless current_person.is_a?(Dean)
      flash[:alert] = "Only deans can manage school classes."
      redirect_to root_path
    end
  end
end 