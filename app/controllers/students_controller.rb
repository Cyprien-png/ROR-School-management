class StudentsController < PeopleController
  include Authorization
  
  before_action :authenticate_person!
  before_action :authorize_dean, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_student, only: [:edit, :update]

  def new
    @student = Student.new
    render 'students/new'
  end

  def create
    @student = Student.new(student_params)
    
    respond_to do |format|
      if @student.save
        format.html { redirect_to person_url(@student), notice: "Student was successfully created." }
        format.json { render :show, status: :created, location: @student }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    render 'students/edit'
  end

  def update
    respond_to do |format|
      if @student.update(student_params)
        format.html { redirect_to person_url(@student), notice: "Student was successfully updated." }
        format.json { render :show, status: :ok, location: @student }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_student
    @student = Student.find(params[:id])
  end

  def student_params
    params.require(:student).permit(
      :lastname, 
      :firstname, 
      :email, 
      :phone_number, 
      :password,
      :password_confirmation,
      :status
    )
  end
end 