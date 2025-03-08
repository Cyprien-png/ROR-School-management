class ExaminationsController < ApplicationController
  include Authorization
  
  before_action :authenticate_person!
  before_action :authorize_dean_or_teacher, except: [:index, :show]
  before_action :set_examination, only: %i[ show edit update destroy ]

  # GET /examinations/available_dates/:lecture_id
  def available_dates
    lecture = Lecture.includes(:trimesters).find(params[:lecture_id])
    
    # Get all dates within the trimesters that match the lecture's weekday
    available_dates = []
    lecture_wday = Date::DAYNAMES.map(&:downcase).index(lecture.week_day)
    
    lecture.trimesters.each do |trimester|
      current_date = trimester.start_date
      
      while current_date <= trimester.end_date
        # If the current date is the same weekday as the lecture
        if current_date.wday == lecture_wday
          available_dates << current_date
        end
        current_date += 1.day
      end
    end
    
    render json: available_dates
  end

  # GET /examinations or /examinations.json
  def index
    @examinations = Examination.includes(lecture: [:subject, :school_class, :teacher]).all
  end

  # GET /examinations/1 or /examinations/1.json
  def show
  end

  # GET /examinations/new
  def new
    @examination = Examination.new
  end

  # GET /examinations/1/edit
  def edit
  end

  # POST /examinations or /examinations.json
  def create
    @examination = Examination.new(examination_params)

    respond_to do |format|
      if @examination.save
        format.html { redirect_to examination_url(@examination), notice: "Examination was successfully created." }
        format.json { render :show, status: :created, location: @examination }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @examination.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /examinations/1 or /examinations/1.json
  def update
    respond_to do |format|
      if @examination.update(examination_params)
        format.html { redirect_to examination_url(@examination), notice: "Examination was successfully updated." }
        format.json { render :show, status: :ok, location: @examination }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @examination.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /examinations/1 or /examinations/1.json
  def destroy
    @examination.destroy!

    respond_to do |format|
      format.html { redirect_to examinations_url, notice: "Examination was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_examination
      @examination = Examination.includes(lecture: [:subject, :school_class, :teacher]).find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def examination_params
      params.require(:examination).permit(:title, :date, :lecture_id)
    end

    def authorize_dean_or_teacher
      unless current_person.is_a?(Dean) || current_person.is_a?(Teacher)
        redirect_to root_path, alert: "You are not authorized to perform this action."
      end
    end
end
