class PartnershipsController < ApplicationController
  before_action :set_partnership, only: [:show, :edit, :update, :destroy]

  # GET /partnerships
  # GET /partnerships.json
  def index
    #@partnerships = Partnership.all
    @participant = Participant.find_by(user_id: current_user.id)
    @partnerships = @participant.partnerships.distinct
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

  def partnership_participants
    participant = Participant.find_by(user_id: current_user.id)
    partnerships = participant.partnerships.distinct

    json_participants =  Array.new
    count = 0

    partnerships.each do |item|
      if (item.first_participant_confirmed && item.second_participant_confirmed)
        item.participants.each do |item_participant|
          if (item_participant.reference != participant.reference)
            json_participants[count] = {
                "value" => item_participant.reference,
                "text" => item_participant.user.username
            }
            count += 1
          end
        end
      end
    end

    if (count == 0)
      json_participants = ""
    end

    puts json_participants.to_s

    respond_to do |format|
      if params[:callback]
        format.js { render :json => {:participants => json_participants}, :callback => params[:callback] }
      else
        format.json { render json: {:participants => json_participants} }
      end
    end
  end

  def partnership_request

    params[:participants].each do |item|

      participant = Participant.find_by(reference: item)
      puts "/CyberCoachServer/resources/partnerships/" + current_user.username + ";" + participant.user.username + "/"
      partnership = Partnership.where('reference = ?', "/CyberCoachServer/resources/partnerships/" + current_user.username + ";" + participant.user.username + "/").first

      if (partnership == nil)
        partnership = Partnership.where('reference = ?', "/CyberCoachServer/resources/partnerships/" + participant.user.username + ";" + current_user.username + "/").first
      end

      if (partnership == nil)
        partnership = participant.partnerships.build()
        partnership.user = current_user

        if (partnership.participants.find_by(user_id: current_user.id) == nil)
          participant1= Participant.find_by(user_id: current_user.id)
          partnership.participants.concat(participant1)
        end

        if (partnership.participants.find_by(reference: item) == nil)
          participant2= Participant.find_by(reference: item)
          partnership.participants.concat(participant2)
        end

        partnership.set_current_user(current_user())
        partnership.first_participant_confirmed = true

        partnership.save
      end
    end
  end

  def partnership_accept
    partnership = Partnership.where('id = ?', params[:id]).first

    if (partnership != nil)
      partnership.set_current_user(current_user())
      partnership.second_participant_confirmed = true
      partnership.save
    end

    respond_to do |format|
      format.html { redirect_to partnerships_url }
      format.json { head :no_content }
    end
  end

  # POST /partnerships
  # POST /partnerships.json
  def create

    partnership = Partnership.new
    partnership.user = current_user

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
