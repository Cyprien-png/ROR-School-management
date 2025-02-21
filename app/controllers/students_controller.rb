class StudentsController < PeopleController
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
    @student = Student.find(params[:id])
    render 'students/edit'
  end

  private

  def set_person
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