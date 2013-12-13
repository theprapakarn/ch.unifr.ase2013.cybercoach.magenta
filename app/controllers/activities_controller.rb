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

  def activities_all
    get_suggestions

    @activities = Activity.where('user_id = ?', current_user.id)
    @body = [@activities.length]
    activity_count = 0

    cal = Google::Calendar.new(:username => current_user.email,
                               :password => 'Bern2013',
                               :app_name => 'firmy')


    #First is to convert activities of current user to json body.
    #
    #

    @activities.each do |item|
      exist_event_on_google = cal.find_event_by_id(item.reference)

      if (exist_event_on_google == nil)
        item.delete()
      else

        #Update the activity if outcoming updated on google.
        #
        #
        update_tree_activities(item,
                               exist_event_on_google.title,
                               exist_event_on_google.start_time,
                               exist_event_on_google.end_time)

        #Get participants who are involved with the activity.
        #
        #

        count_participant = 0
        json_participants = Array.new
        hash_participants = Hash.new()

        ref_activities = Activity.where('reference_activity_id = ?', "#{ item.id }")

        if (ref_activities.count == 0)
          if (item.reference_activity_id != nil && item.reference_activity_id != "")
            ref_activities = Activity.where('reference_activity_id = ?', "#{ item.reference_activity_id }")

            ref_activities.each do |ref_item|
              hash_participants[ref_item.entry.subscription.partnership.participants[0].reference] = ref_item.entry.subscription.partnership.participants[0].user.username
              hash_participants[ref_item.entry.subscription.partnership.participants[1].reference] = ref_item.entry.subscription.partnership.participants[1].user.username
            end
          end
        else
          ref_activities.each do |ref_item|
            hash_participants[ref_item.entry.subscription.partnership.participants[0].reference] = ref_item.entry.subscription.partnership.participants[0].user.username
            hash_participants[ref_item.entry.subscription.partnership.participants[1].reference] = ref_item.entry.subscription.partnership.participants[1].user.username
          end
        end

        hash_participants.each do |ref_participant|
          json_participants[count_participant] = {
              "value" => ref_participant[0],
              "Text" => ref_participant[1]
          }
          count_participant += 1
        end

        #Fetch lastest version of entry from CyberCoach.
        #
        #

        if (ref_activities.count > 0)
          entry = EntriesHelper.fetch(ref_activities[0].entry)
        else
          entry = EntriesHelper.fetch(item.entry)
        end

        @body[activity_count] = {
            "Reference" => item.reference,
            "Title" => item.name,
            "StartTime" => item.start_time,
            "EndTime" => item.end_time,
            "Entry" => entry.get_data(false),
            "Participants" => json_participants,
            "IsAllDay" => false,
            "ReadOnly" => true,
            "Sport" => entry.subscription.sport.name,
            "Info" => {
                "Status" => "Busy",
                "From" => "CyberCoach"
            }
        }
        activity_count += 1
      end
    end


    #Second is to convert events of google of current user to json body.
    #
    #

    if (cal.events.instance_of?(Array))
      cal.events.each do |item|
        if (Activity.where('reference like ?', "%" + item.id.to_s + "%").first == nil)
          @body[activity_count] = {
              "Reference" => item.id,
              "Title" => item.title,
              "StartTime" => item.start_time,
              "EndTime" => item.end_time,
              "ReadOnly" => true,
              "Info" => {
                  "Status" => "Busy",
                  "From" => "Google"
              }
          }
          activity_count += 1
        end
      end
    else
      if (Activity.where('reference like ?', "%" + cal.events.id.to_s + "%").first == nil)
        @body[activity_count] = {
            "Reference" => cal.events.id,
            "Title" => cal.events.title,
            "StartTime" => cal.events.start_time,
            "EndTime" => cal.events.end_time,
            "ReadOnly" => true,
            "Info" => {
                "Status" => "Busy",
                "From" => "Google"
            }
        }
        activity_count += 1
      end
    end

    #Third is to convert suggestion weathers to json body.
    #
    #
    get_suggestions.each do |item|
      @body[activity_count] = item
      activity_count += 1
    end

    #Renders json body on console.
    #
    #
    puts @body.to_json

    #Returns json body.
    #
    #
    respond_to do |format|
      if params[:callback]
        format.js { render :json => {:data => @body}, :callback => params[:callback] }
      else
        format.json { render json: {:data => @body} }
      end
    end
  end


  #Running.
  #
  #
  #Create a new Running activity with participants.
  #
  #
  def running_new
    entry = Entry.new
    entry.reference = ""
    entry.user = current_user
    entry.set_property("entrydate", params[:data][:StartTime])
    entry.set_property("entrylocation", params[:data][:location])
    entry.set_property("comment", params[:data][:comment])
    entry.set_property("publicvisible", 2)
    entry.set_property("courselength", params[:data][:courselength])
    entry.set_property("coursetype", params[:data][:coursetype])
    entry.public_visible = 2

    base_new(params, "Running", entry)
  end

  #Delete a new Running activity with participants.
  #
  #
  def running_delete
    base_delete(params, "Running")
  end


  #Boxing.
  #
  #
  #Create a new Boxing activities with participants.
  #
  #
  def boxing_new
    entry = Entry.new
    entry.reference = ""
    entry.user = current_user
    entry.set_property("entrydate", params[:data][:StartTime])
    entry.set_property("entrylocation", params[:data][:location])
    entry.set_property("comment", params[:data][:comment])
    entry.set_property("publicvisible", 2)
    entry.set_property("roundduration", params[:data][:roundduration])
    entry.public_visible = 2

    base_new(params, "Boxing", entry)
  end

  #Delete a new Boxing activity with participants.
  #
  #
  def boxing_delete
    base_delete(params, "Boxing")
  end

  #Soccer.
  #
  #
  #Create a new Soccer activities with participants.
  #
  #
  def soccer_new
    entry = Entry.new
    entry.reference = ""
    entry.user = current_user
    entry.set_property("entrydate", params[:data][:StartTime])
    entry.set_property("entrylocation", params[:data][:location])
    entry.set_property("comment", params[:data][:comment])
    entry.set_property("publicvisible", 2)
    entry.public_visible = 2

    base_new(params, "Soccer", entry)
  end

  #Delete a new Soccer activity with participants.
  #
  #
  def soccer_delete
    base_delete(params, "Soccer")
  end

  #Cycling.
  #
  #
  #Create a new Cycling activities with participants.
  #
  #
  def cycling_new
    entry = Entry.new
    entry.reference = ""
    entry.user = current_user
    entry.set_property("entrydate", params[:data][:StartTime])
    entry.set_property("entrylocation", params[:data][:location])
    entry.set_property("comment", params[:data][:comment])
    entry.set_property("publicvisible", 2)
    entry.set_property("bicycletype", params[:data][:bicycletype])
    entry.public_visible = 2

    base_new(params, "Cycling", entry)
  end

  #Delete a new Cycling activity with participants.
  #
  #
  def cycling_delete
    base_delete(params, "Cycling")
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

  def base_new(params, sport_name, entry)
    @activity = Activity.new
    @activity.name = params[:data][:Title]
    @activity.start_time = params[:data][:StartTime]
    @activity.end_time = params[:data][:EndTime]
    @activity.user = current_user

    host_subscription = Subscription.find_by(reference: "/CyberCoachServer/resources/users/" + current_user.username.downcase + "/" + sport_name + "/")
    if (host_subscription == nil)
      host_subscription = Subscription.new
      host_subscription.user = current_user
      host_subscription.participant = Participant.find_by(user_id: current_user.id)

      sport = Sport.new
      sport.reference = "/CyberCoachServer/resources/sports/" + sport_name
      sport.name = sport_name
      sport.is_proxy = true

      host_subscription.public_visible = 2
      host_subscription.sport = sport

      host_subscription.sport.save
      host_subscription.save
    else
      host_subscription = SubscriptionsHelper.fetch(host_subscription)
    end

    entry.subscription = host_subscription

    if (params[:data][:Participants] != nil && params[:data][:Participants].instance_of?(Array))

      params[:data][:Participants].each do |item|
        partnership = Partnership.where('reference = ?', "/CyberCoachServer/resources/partnerships/" + current_user.username.downcase + ";" + item[:text].downcase + "/").first

        if (partnership == nil)
          partnership = Partnership.where('reference = ?', "/CyberCoachServer/resources/partnerships/" + item[:text].downcase + ";" + current_user.username.downcase + "/").first
        end

        puts "/CyberCoachServer/resources/partnerships/" + item[:text].downcase + ";" + current_user.username.downcase + "/"

        subscription = Subscription.find_by(reference: partnership.reference + sport_name)
        if (subscription == nil)
          sport = Sport.new
          sport.reference = "/CyberCoachServer/resources/sports/" + sport_name
          sport.name = sport_name
          sport.is_proxy = true

          subscription = Subscription.new
          subscription.user = current_user
          subscription.partnership = Partnership.find_by(reference: partnership.reference)
          subscription.public_visible = 2
          subscription.sport = sport
          subscription.save
        else
          subscription = SubscriptionsHelper.fetch(subscription)
        end

        participant = Participant.find_by(reference: item[:value])
        cal_participant = Google::Calendar.new(:username => participant.user.email,
                                               :password => 'Bern2013',
                                               :app_name => 'firmy')

        event_participant = cal_participant.create_event do |e|
          e.title = "[" + current_user.username + "] " + @activity.name
          e.start_time = @activity.start_time
          e.end_time = @activity.end_time
        end

        entry_participant = Entry.new
        entry_participant.subscription = subscription
        entry_participant.user = participant.user
        entry_participant.set_dynamic_property(entry.get_dynamic_property)
        entry_participant.public_visible = 2
        entry_participant.save

        activity_participant = Activity.new
        activity_participant.name = "[" + current_user.username + "] " + @activity.name
        activity_participant.entry = entry_participant
        activity_participant.reference_activity = @activity
        activity_participant.reference = event_participant.id
        activity_participant.start_time = @activity.start_time
        activity_participant.end_time = @activity.end_time
        activity_participant.user = participant.user
        activity_participant.save
      end
    end

    cal = Google::Calendar.new(:username => current_user.email,
                               :password => 'Bern2013',
                               :app_name => 'firmy')

    event = cal.create_event do |e|
      e.title = "[" + current_user.username + "] " + @activity.name
      e.start_time = @activity.start_time
      e.end_time = @activity.end_time
    end

    @activity.entry = entry
    @activity.entry.save

    @activity.entry = Entry.find_by(id: entry.id)
    @activity.reference = event.id
    @activity.save
  end

  def base_delete(params, sport_name)
    @activity = Activity.where('reference = ?', "#{params[:data][:Reference]}").first

    if (@activity != nil && @activity.reference != nil && @activity.reference != '')

      cal = Google::Calendar.new(:username => current_user.email,
                                 :password => 'Bern2013',
                                 :app_name => 'firmy')


      event = cal.find_event_by_id(@activity.reference)
      cal.delete_event(event)

      if (@activity.entry != nil && @activity.entry.reference != nil)
        @activity.entry.delete
      end

      @activity.delete

      if (@activity.reference_activity == nil)

        ref_activities = Activity.where('reference_activity_id = ?', "#{ @activity.id }")

        ref_activities.each do |ref_item|
          ref_cal = Google::Calendar.new(:username => ref_item.user.email,
                                         :password => 'Bern2013',
                                         :app_name => 'firmy')

          ref_event = ref_cal.find_event_by_id(ref_item.reference)
          ref_cal.delete_event(ref_event)

          if (ref_item.entry != nil)
            ref_item.entry.delete
          end
          ref_item.delete
        end
      end
    end
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
          "ReadOnly" => true,
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

  #Provides updating of specified activity with given tile, start_time and end_time.
  #
  #
  def update_tree_activities(activity, title, start_time, end_time)

    #First update itself.
    #
    #
    activity.name = title
    activity.start_time = start_time
    activity.end_time = end_time
    activity.save

    #Activity Root Node just update all children.
    #
    #
    if (activity.reference_activity == nil)

      ref_activities = Activity.where('reference_activity_id = ?', "#{ activity.id }")

      ref_activities.each do |ref_item|
        ref_cal = Google::Calendar.new(:username => ref_item.user.email,
                                       :password => 'Bern2013',
                                       :app_name => 'firmy')

        ref_event = ref_cal.find_event_by_id(ref_item.reference)
        ref_event.title = title
        ref_event.start_time = start_time
        ref_event.end_time = end_time
        ref_cal.save_event(ref_event)

        ref_item.name = title
        ref_item.start_time = start_time
        ref_item.end_time = end_time
        ref_item.save
      end

      #Activity Child Node need to find root node and then update all children.
      #
      #
    else
      root_activity = Activity.where('id = ?', "#{ activity.reference_activity.id }").first

      root_cal = Google::Calendar.new(:username => root_activity.user.email,
                                      :password => 'Bern2013',
                                      :app_name => 'firmy')


      root_event = root_cal.find_event_by_id(root_activity.reference)
      root_event.title = title
      root_event.start_time = start_time
      root_event.end_time = end_time
      root_cal.save_event(root_event)

      root_activity.name = title
      root_activity.start_time = start_time
      root_activity.end_time = end_time
      root_activity.save

      update_tree_activities(root_activity, title, start_time, end_time)
    end

  end
end
