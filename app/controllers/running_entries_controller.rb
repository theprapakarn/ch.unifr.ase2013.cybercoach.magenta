class RunningEntriesController < ApplicationController
  before_action :set_running_entry, only: [:show, :edit, :update, :destroy]

  # GET /running_entries
  # GET /running_entries.json
  def index
    @running_entries = RunningEntry.all
  end

  # GET /running_entries/1
  # GET /running_entries/1.json
  def show
  end

  # GET /running_entries/new
  def new
    @running_entry = RunningEntry.new
  end

  # GET /running_entries/1/edit
  def edit
  end

  # POST /running_entries
  # POST /running_entries.json
  def create
    @running_entry = RunningEntry.new(running_entry_params)

    respond_to do |format|
      if @running_entry.save
        format.html { redirect_to @running_entry, notice: 'Running entry was successfully created.' }
        format.json { render action: 'show', status: :created, location: @running_entry }
      else
        format.html { render action: 'new' }
        format.json { render json: @running_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /running_entries/1
  # PATCH/PUT /running_entries/1.json
  def update
    respond_to do |format|
      if @running_entry.update(running_entry_params)
        format.html { redirect_to @running_entry, notice: 'Running entry was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @running_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /running_entries/1
  # DELETE /running_entries/1.json
  def destroy
    @running_entry.destroy
    respond_to do |format|
      format.html { redirect_to running_entries_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_running_entry
      @running_entry = RunningEntry.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def running_entry_params
      params.require(:running_entry).permit(:course_length, :course_type, :number_of_round, :track)
    end
end
