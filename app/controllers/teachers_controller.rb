class TeachersController < PeopleController
  include Authorization
  
  before_action :authenticate_person!
  before_action :authorize_dean, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_teacher, only: [:edit, :update, :destroy, :school_classes]

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
    render 'teachers/edit'
  end

  def update
    respond_to do |format|
      if @teacher.update(teacher_params)
        format.html { redirect_to person_url(@teacher), notice: "Teacher was successfully updated." }
        format.json { render :show, status: :ok, location: @teacher }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @teacher.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @teacher.soft_delete
    respond_to do |format|
      format.html { redirect_to people_url, notice: "Teacher was successfully deleted." }
      format.json { head :no_content }
    end
  end

  def school_classes
    @classes = @teacher.school_classes
    render json: @classes
  end

  private

  def set_teacher
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
      :iban,
      subject_ids: []
    )
  end
end 