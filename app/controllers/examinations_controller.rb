class ExaminationsController < ApplicationController
  before_action :set_examination, only: %i[ show edit update destroy ]

  # GET /examinations or /examinations.json
  def index
    @examinations = Examination.all
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
        format.html { redirect_to @examination, notice: "Examination was successfully created." }
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
        format.html { redirect_to @examination, notice: "Examination was successfully updated." }
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
      format.html { redirect_to examinations_path, status: :see_other, notice: "Examination was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_examination
      @examination = Examination.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def examination_params
      params.expect(examination: [ :title, :date ])
    end
end
