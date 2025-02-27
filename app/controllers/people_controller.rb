class PeopleController < ApplicationController
  before_action :set_person, only: [:show]

  # GET /people or /people.json
  def index
    @people = Person.all
  end

  # GET /people/1 or /people/1.json
  def show
  end

  # GET /people/new
  def new
    @person = Person.new(type: person_type)
  end

  # GET /people/1/edit
  def edit
    @person = Person.edit(type: person_type)
  end

  # POST /people or /people.json
  def create
    @person = Person.new(person_params)
    @person.type = person_type if person_type

    respond_to do |format|
      if @person.save
        format.html { redirect_to person_url(@person), notice: "#{@person.type} was successfully created." }
        format.json { render :show, status: :created, location: @person }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /people/1 or /people/1.json
  def update
    respond_to do |format|
      if @person.update(person_params)
        format.html { redirect_to person_url(@person), notice: "#{@person.type} was successfully updated." }
        format.json { render :show, status: :ok, location: @person }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1 or /people/1.json
  def destroy
    @person.destroy!

    respond_to do |format|
      format.html { redirect_to people_url, notice: "#{@person.type} was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def person_params
      params.require(:person).permit(
        :lastname, 
        :firstname, 
        :email, 
        :phone_number, 
        :type,
        :password,
        :password_confirmation,
        :iban,  # for Teacher
        :status # for Student
      )
    end

    def person_type
      params[:type] if params[:type].in?(%w[Student Teacher Dean])
    end
end
