class TeachersController < PeopleController
  include Authorization
  
  before_action :authenticate_person!
  before_action :authorize_dean, only: [:new, :create, :edit, :update, :destroy]

  def new
    @teacher = Teacher.new
    render 'teachers/new'
  end

  def create
    @teacher = Teacher.new(teacher_params)
    
    respond_to do |format|
      if @teacher.save
        format.html { redirect_to person_url(@teacher), notice: "Teacher was successfully created." }
        format.json { render :show, status: :created, location: @teacher }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @teacher.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @teacher = Teacher.find(params[:id])
    render 'teachers/edit'
  end

  private

  def set_person
    @teacher = Teacher.find(params[:id])
  end

  def teacher_params
    params.require(:teacher).permit(
      :lastname, 
      :firstname, 
      :email, 
      :phone_number, 
      :password,
      :password_confirmation,
      :iban
    )
  end
end 