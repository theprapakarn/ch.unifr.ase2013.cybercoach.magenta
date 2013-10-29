class SoccerEntriesController < ApplicationController
  before_action :set_soccer_entry, only: [:show, :edit, :update, :destroy]

  # GET /soccer_entries
  # GET /soccer_entries.json
  def index
    @soccer_entries = SoccerEntry.all
  end

  # GET /soccer_entries/1
  # GET /soccer_entries/1.json
  def show
  end

  # GET /soccer_entries/new
  def new
    @soccer_entry = SoccerEntry.new
  end

  # GET /soccer_entries/1/edit
  def edit
  end

  # POST /soccer_entries
  # POST /soccer_entries.json
  def create
    @soccer_entry = SoccerEntry.new(soccer_entry_params)

    respond_to do |format|
      if @soccer_entry.save
        format.html { redirect_to @soccer_entry, notice: 'Soccer entry was successfully created.' }
        format.json { render action: 'show', status: :created, location: @soccer_entry }
      else
        format.html { render action: 'new' }
        format.json { render json: @soccer_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /soccer_entries/1
  # PATCH/PUT /soccer_entries/1.json
  def update
    respond_to do |format|
      if @soccer_entry.update(soccer_entry_params)
        format.html { redirect_to @soccer_entry, notice: 'Soccer entry was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @soccer_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /soccer_entries/1
  # DELETE /soccer_entries/1.json
  def destroy
    @soccer_entry.destroy
    respond_to do |format|
      format.html { redirect_to soccer_entries_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_soccer_entry
      @soccer_entry = SoccerEntry.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def soccer_entry_params
      params[:soccer_entry]
    end
end
