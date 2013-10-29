class PartnershipsController < ApplicationController
  before_action :set_partnership, only: [:show, :edit, :update, :destroy]

  # GET /partnerships
  # GET /partnerships.json
  def index
    @partnerships = Partnership.all
  end

  # GET /partnerships/1
  # GET /partnerships/1.json
  def show
  end

  # GET /partnerships/new
  def new
    @partnership = Partnership.new
  end

  # GET /partnerships/1/edit
  def edit
  end

  # POST /partnerships
  # POST /partnerships.json
  def create

    partnership = Partnership.new

    if (partnership.participants.find_by(reference: params[:first_participant_id]) == nil)
      participant1= Participant.find_by(reference: params[:first_participant_id])
      partnership.participants.concat(participant1)
    end

    if (partnership.participants.find_by(reference: params[:second_participant_id]) == nil)
      participant2= Participant.find_by(reference: params[:second_participant_id])
      partnership.participants.concat(participant2)
    end

    #partnership.first_participant = Participant.find_by(reference: params[:first_participant_id])
    #partnership.second_participant = Participant.find_by(reference: params[:second_participant_id])

    partnership.save
    @partnership = partnership

=begin
    respond_to do |format|
      if partnership.save
        format.html { redirect_to @partnership, notice: 'Partnership was successfully created.' }
        format.json { render action: 'show', status: :created, location: @partnership }
      else
        format.html { render action: 'new' }
        format.json { render json: @partnership.errors, status: :unprocessable_entity }
      end
    end
=end
  end

  # PATCH/PUT /partnerships/1
  # PATCH/PUT /partnerships/1.json
  def update
    respond_to do |format|
      if @partnership.update(partnership_params)
        format.html { redirect_to @partnership, notice: 'Partnership was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @partnership.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /partnerships/1
  # DELETE /partnerships/1.json
  def destroy
    @partnership.destroy
    respond_to do |format|
      format.html { redirect_to partnerships_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_partnership
    @partnership = Partnership.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def partnership_params
    params.require(:partnership).permit(:first_user_id, :second_user_id)
  end
end
