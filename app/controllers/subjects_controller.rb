class SubjectsController < ApplicationController
  include Authorization
  
  before_action :authenticate_person!
  before_action :authorize_dean, only: [:new, :create, :edit, :update, :destroy, :deleted, :undelete]
  before_action :set_subject, only: [:show, :edit, :update, :destroy, :teachers]
  before_action :set_deleted_subject, only: [:undelete]

  # GET /subjects/1/teachers
  def teachers
    render json: @subject.teachers.select(:id, :firstname, :lastname)
  end

  def deleted
    @subjects = Subject.with_deleted.where(isDeleted: true)
    render :deleted
  end

  def undelete
    @subject.update(isDeleted: false)
    redirect_to subjects_path, notice: "Subject was successfully restored."
  end

  # GET /subjects or /subjects.json
  def index
    @subjects = Subject.all
  end

  # GET /subjects/1 or /subjects/1.json
  def show
  end

  # GET /subjects/new
  def new
    @subject = Subject.new
  end

  # GET /subjects/1/edit
  def edit
  end

  # POST /subjects or /subjects.json
  def create
    @subject = Subject.new(subject_params)

    respond_to do |format|
      if @subject.save
        format.html { redirect_to subject_url(@subject), notice: "Subject was successfully created." }
        format.json { render :show, status: :created, location: @subject }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /subjects/1 or /subjects/1.json
  def update
    respond_to do |format|
      if @subject.update(subject_params)
        format.html { redirect_to subject_url(@subject), notice: "Subject was successfully updated." }
        format.json { render :show, status: :ok, location: @subject }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subjects/1 or /subjects/1.json
  def destroy
    @subject.soft_delete
    respond_to do |format|
      format.html { redirect_to subjects_url, notice: "Subject was successfully deleted." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subject
      @subject = Subject.find(params[:id])
    end

    def set_deleted_subject
      @subject = Subject.with_deleted.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def subject_params
      params.require(:subject).permit(:name, teacher_ids: [])
    end
end
