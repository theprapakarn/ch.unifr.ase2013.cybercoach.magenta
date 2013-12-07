require 'rubygems'
require 'google/calendar'


class ActivitiesController < ApplicationController
  before_action :set_activity, only: [:show, :edit, :update, :destroy]

  # GET /activities
  # GET /activities.json
  def index
    @activities = Activity.all
  end

  # GET /activities/1
  # GET /activities/1.json
  def show
  end

  # GET /activities/new
  def new
    @activity = Activity.new
  end

  # GET /activities/1/edit
  def edit
  end

  # POST /activities
  # POST /activities.json
  def create
    @activity = Activity.new(activity_params)

    respond_to do |format|
      if @activity.save
        format.html { redirect_to @activity, notice: 'Activity was successfully created.' }
        format.json { render action: 'show', status: :created, location: @activity }
      else
        format.html { render action: 'new' }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /activities/1
  # PATCH/PUT /activities/1.json
  def update
    respond_to do |format|
      if @activity.update(activity_params)
        format.html { redirect_to @activity, notice: 'Activity was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /activities/1
  # DELETE /activities/1.json
  def destroy
    @activity.destroy
    respond_to do |format|
      format.html { redirect_to activities_url }
      format.json { head :no_content }
    end
  end

  def running
  end

  def running_all
    get_suggestions

    @activities = Activity.all
    @body = [@activities.length]
    count = 0

    @activities.each do |item|
      entries_Count = item.entries.count
      if (entries_Count == 0)
        puts "Activity Entry Count = 0"
      else
        puts "Activity Entry Count = 1"

        if (entries_Count > 0)
          count_participant = 0
          json_participants = Array.new

          entries = Entry.where('activity_id = ?', "#{ item.id }")
          entries.each do |entry|
            if entry.subscription.partnership != nil
              puts "Many Participants:" + entry.subscription.partnership.participants[1].user.username

              json_participants[count] = {
                  "value" => entry.subscription.partnership.participants[1].reference,
                  "Text" => entry.subscription.partnership.participants[1].user.username
              }
            end
            count_participant += 1
          end
        else
          json_participants = ""
        end
      end

      entry = EntriesHelper.fetch(item.entries[0])

      @body[count] = {
          "Reference" => item.reference,
          "Title" => item.name,
          "StartTime" => item.start_time,
          "EndTime" => item.end_time,
          "Comment" => entry.get_property("comment"),
          "Location" => entry.get_property("entrylocation"),
          "Participants" => json_participants,
          "IsAllDay" => false,
          "Info" => {
              "Status" => "Busy",
              "From" => "CyberCoach"
          }
      }
      count += 1
    end

    cal = Google::Calendar.new(:username => current_user.email,
                               :password => 'Bern2013',
                               :app_name => 'firmy')

    if (cal.events)
      cal.events.each do |item|
        if (Activity.find_by(reference: item.id) == nil)
          @body[count] = {
              "Reference" => item.id,
              "Title" => item.title,
              "StartTime" => item.start_time,
              "EndTime" => item.end_time,
              "Info" => {
                  "Status" => "Busy",
                  "From" => "Google"
              }
          }
          count += 1
        end
      end
    end

    get_suggestions.each do |item|
      @body[count] = item
      count += 1
    end

    puts @body.to_json

    respond_to do |format|
      if params[:callback]
        format.js { render :json => {:running => @body}, :callback => params[:callback] }
      else
        format.json { render json: {:running => @body} }
      end
    end
  end

  def running_new
    @activity = Activity.new
    @activity.name = params[:running][:Title]
    @activity.start_time = params[:running][:StartTime]
    @activity.end_time = params[:running][:EndTime]

    @activity.entries = Array.new

    if (params[:running][:Participants] == nil || !params[:running][:Participants].instance_of?(Array))

      subscription = Subscription.find_by(reference: "/CyberCoachServer/resources/users/" + current_user.username.downcase + "/Running/")
      if (subscription == nil)
        subscription = Subscription.new
        subscription.user = current_user
        subscription.participant = Participant.find_by(user_id: current_user.id)

        sport = Sport.new
        sport.reference = "/CyberCoachServer/resources/sports/Running"
        sport.name = "Running"
        sport.is_proxy = true

        subscription.public_visible = 2
        subscription.sport = sport

        subscription.save
      else
        subscription = SubscriptionsHelper.fetch(subscription)
      end
      entry = Entry.new
      entry.activity = @activity
      entry.subscription = subscription
      entry.user = current_user
      entry.set_property("entrylocation", params[:running][:Location])
      entry.set_property("comment", params[:running][:Comment])
      entry.set_property("publicvisible", 2)
      entry.public_visible = 2
      entry.save
    else
      params[:running][:Participants].each do |item|
        partnership = Partnership.where('reference = ?', "/CyberCoachServer/resources/partnerships/" + current_user.username + ";" + item[:text] + "/").first
        if (partnership == nil)
          partnership = Partnership.new
          partnership.user = current_user

          if (partnership.participants.find_by(user_id: current_user.id) == nil)
            participant1= Participant.find_by(user_id: current_user.id)
            partnership.participants.concat(participant1)
          end

          if (partnership.participants.find_by(reference: item[:value]) == nil)
            participant2= Participant.find_by(reference: item[:value])
            partnership.participants.concat(participant2)
          end

          partnership.save
        end

        subscription = Subscription.find_by(reference: partnership.reference + "/Running/")
        if (subscription == nil)
          subscription = Subscription.new
          subscription.user = current_user
          subscription.partnership = Partnership.find_by(reference: partnership.reference)

          sport = Sport.new
          sport.reference = "/CyberCoachServer/resources/sports/Running"
          sport.name = "Running"
          sport.is_proxy = true

          subscription.public_visible = 2
          subscription.sport = sport
          subscription.partnership.save
          subscription.save
        else
          subscription = SubscriptionsHelper.fetch(subscription)
        end
        entry = Entry.new
        entry.activity = @activity
        entry.subscription = subscription
        entry.user = current_user
        entry.set_property("entrylocation", params[:running][:Location])
        entry.set_property("comment", params[:running][:Comment])
        entry.set_property("publicvisible", 2)
        entry.public_visible = 2
        entry.save
      end
    end

    cal = Google::Calendar.new(:username => current_user.email,
                               :password => 'Bern2013',
                               :app_name => 'firmy')

    event = cal.create_event do |e|
      e.title = @activity.name
      e.start_time = @activity.start_time
      e.end_time = @activity.end_time
    end

    @activity.reference = event.id

    @activity.save
  end

  def running_update
    @activity = Activity.where('reference = ?', "#{params[:running][:Reference]}").first

    if (params[:running][:Participants] == nil || !params[:running][:Participants].instance_of?(Array))

      subscription = Subscription.find_by(reference: "/CyberCoachServer/resources/users/" + current_user.username.downcase + "/Running/")
      if (subscription == nil)
        subscription = Subscription.new
        subscription.user = current_user
        subscription.participant = Participant.find_by(user_id: current_user.id)

        sport = Sport.new
        sport.reference = "/CyberCoachServer/resources/sports/Running"
        sport.name = "Running"
        sport.is_proxy = true

        subscription.public_visible = 2
        subscription.sport = sport

        subscription.save
      else
        subscription = SubscriptionsHelper.fetch(subscription)
      end
      @activity.entries[0].set_property("entrylocation", params[:running][:Location])
      @activity.entries[0].set_property("comment", params[:running][:Comment])
      @activity.entries[0].set_property("publicvisible", 2)
      @activity.entries[0].public_visible = 2
      @activity.entries[0].save
    else
      params[:running][:Participants].each do |item|
        partnership = Partnership.where('reference = ?', "/CyberCoachServer/resources/partnerships/" + current_user.username + ";" + item[:text] + "/").first
        if (partnership == nil)
          partnership = Partnership.new
          partnership.user = current_user

          if (partnership.participants.find_by(user_id: current_user.id) == nil)
            participant1 = Participant.find_by(user_id: current_user.id)
            partnership.participants.concat(participant1)
          end

          if (partnership.participants.find_by(reference: item[:value]) == nil)
            participant2 = Participant.find_by(reference: item[:value])
            partnership.participants.concat(participant2)
          end

          partnership.save
        end

        subscription = Subscription.find_by(reference: partnership.reference + "/Running/")
        if (subscription == nil)
          subscription = Subscription.new
          subscription.user = current_user
          subscription.partnership = Partnership.find_by(reference: partnership.reference)

          sport = Sport.new
          sport.reference = "/CyberCoachServer/resources/sports/Running"
          sport.name = "Running"
          sport.is_proxy = true
          sport.save

          subscription.public_visible = 2
          subscription.sport = sport
          subscription.partnership.save
          subscription.save
        else
          subscription = SubscriptionsHelper.fetch(subscription)
        end
        isFound = false
        @activity.entries.each do |entry|
          if (entry.subscription.reference = subscription.reference)
            entry.set_property("entrylocation", params[:running][:Location])
            entry.set_property("comment", params[:running][:Comment])
            entry.set_property("publicvisible", 2)
            entry.public_visible = 2
            entry.save

            isFound = true
          end
        end

        if (!isFound)
          entry = Entry.new
          entry.activity = @activity
          entry.subscription = subscription
          entry.user = current_user

          entry.set_property("entrylocation", params[:running][:Location])
          entry.set_property("comment", params[:running][:Comment])
          entry.set_property("publicvisible", 2)
          entry.public_visible = 2
          entry.save
        end
      end
    end

    cal = Google::Calendar.new(:username => current_user.email,
                               :password => 'Bern2013',
                               :app_name => 'firmy')


    event = cal.find_or_create_event_by_id(@activity.reference) do |e|
      e.title = @activity.name
      e.start_time = @activity.start_time
      e.end_time = @activity.end_time
    end

    current_participant = Participant.find_by(user_id: current_user.id)
    partnerships = current_participant.partnerships.distinct

    partnerships.each do |item|
      if (item.first_participant_confirmed && item.second_participant_confirmed)
        item.participants.each do |item_participant|
          if (item_participant.reference != participant.reference)

            @activity = Activity.new
            @activity.name = params[:running][:Title]
            @activity.start_time = params[:running][:StartTime]
            @activity.end_time = params[:running][:EndTime]

            @activity.entries = Array.new


            cal_participant = Google::Calendar.new(:username => item_participant.user.email,
                                       :password => 'Bern2013',
                                       :app_name => 'firmy')

            cal_participant.find_or_create_event_by_id(@activity.reference) do |e|
              e.title = @activity.name
              e.start_time = @activity.start_time
              e.end_time = @activity.end_time
            end
          end
        end
      end
      count += 1
    end

    @activity.save
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_activity
    @activity = Activity.find(params[:id])
  end

# Never trust parameters from the scary internet, only allow the white list through.
  def activity_params
    params.require(:activity).permit(:reference, :name, :user_id, :start_time, :end_time, :sport, :owner, :entry, :is_proxy)
  end

  def get_suggestions
    weather_json = get_weather("Bern", "CH")

    puts weather_json.to_s

    count = 0

    @suggestions_json = [weather_json["cnt"]]

    weather_json["list"].each do |item|
      title = item["weather"][0]["main"].to_s + " @ " + item["temp"]["day"].to_s + "C"
      status = ""
      if (item["weather"][0]["main"] == "Clear")
        if (item["temp"]["day"] > 15.0)
          status = "Perfect"
        end
        if (item["temp"]["day"] > 10.0)
          status = "Good"
        end
        if (item["temp"]["day"] > 5.0)
          status = "Quite Bad"
        else
          status = "Bad"
        end
      else
        status = "Bad"
      end

      @suggestions_json[count] = {
          "Reference" => item["dt"],
          "Title" => title,
          "StartTime" => Time.at(item["dt"]).to_datetime,
          "EndTime" => Time.at(item["dt"]).to_datetime,
          "IsAllDay" => true,
          "Info" => {
              "Morning" => item["temp"]["morn"].to_s,
              "Noon" => item["temp"]["day"].to_s,
              "Evening" => item["temp"]["eve"].to_s,
              "Description" => item["weather"][0]["description"].to_s,
              "Status" => status,
              "From" => "Suggestion"
          }
      }
      count += 1
    end

    @suggestions_json
  end

  def get_weather(region, country)
    uri = URI.parse("http://api.openweathermap.org")

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new("/data/2.5/forecast/daily?q=" + region + "," + country.downcase + "&mode=json&units=metric")
    request["Accept"] = "application/json"

    response = http.request(request)
    @parsed_json = ActiveSupport::JSON.decode(response.body)

    @parsed_json
  end
end
