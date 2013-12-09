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

    @activities = Activity.where('user_id = ?', current_user.id)
    @body = [@activities.length]
    activity_count = 0

    cal = Google::Calendar.new(:username => current_user.email,
                               :password => 'Bern2013',
                               :app_name => 'firmy')

    @activities.each do |item|
      exist_event_on_google = cal.find_event_by_id(item.reference)

      if (exist_event_on_google == nil)
        item.delete()
      else
        count_participant = 0
        json_participants = Array.new

        ref_activities = Activity.where('reference_activity_id = ?', "#{ item.id }")

        if (ref_activities.count == 0)
          if (item.reference_activity_id != nil && item.reference_activity_id != "")
            ref_activities = Activity.where('reference_activity_id = ?', "#{ item.reference_activity_id }")

            ref_activities.each do |ref_item|
              json_participants[count_participant] = {
                  "value" => ref_item.entry.subscription.partnership.participants[0].reference,
                  "Text" => ref_item.entry.subscription.partnership.participants[0].user.username
              }
              count_participant += 1
            end
          end
        else
          ref_activities.each do |ref_item|
            json_participants[count_participant] = {
                "value" => ref_item.entry.subscription.partnership.participants[1].reference,
                "Text" => ref_item.entry.subscription.partnership.participants[1].user.username
            }
            count_participant += 1
          end
        end


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
            "Comment" => entry.get_property("comment"),
            "Location" => entry.get_property("entrylocation"),
            "Participants" => json_participants,
            "IsAllDay" => false,
            "ReadOnly" => true,
            "Info" => {
                "Status" => "Busy",
                "From" => "CyberCoach"
            }
        }

        activity_count += 1
      end
    end

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
      if (Activity.where('reference like ?', "%" + item.id.to_s + "%").first == nil)
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

    get_suggestions.each do |item|
      @body[activity_count] = item
      activity_count += 1
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
    @activity.user = current_user

    entry = Entry.new
    entry.reference = ""
    entry.is_proxy = true
    entry.user = current_user
    entry.set_property("entrylocation", params[:running][:Location])
    entry.set_property("comment", params[:running][:Comment])
    entry.set_property("publicvisible", 2)
    entry.public_visible = 2

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
      entry.is_proxy = false
      entry.subscription = subscription
    else
      params[:running][:Participants].each do |item|
        partnership = Partnership.where('reference = ?', "/CyberCoachServer/resources/partnerships/" + current_user.username.downcase + ";" + item[:text].downcase + "/").first

        if (partnership == nil)
          partnership = Partnership.where('reference = ?', "/CyberCoachServer/resources/partnerships/" + item[:text].downcase + ";" + current_user.username.downcase + "/").first
        end

        puts "/CyberCoachServer/resources/partnerships/" + item[:text].downcase + ";" + current_user.username.downcase + "/"

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
        entry_participant.set_property("entrylocation", params[:running][:Location])
        entry_participant.set_property("comment", params[:running][:Comment])
        entry_participant.set_property("publicvisible", 2)
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
      e.title = @activity.name
      e.start_time = @activity.start_time
      e.end_time = @activity.end_time
    end

    @activity.entry = entry
    @activity.entry.save

    @activity.reference = event.id
    @activity.save
  end

  def running_delete
    @activity = Activity.where('reference = ?', "#{params[:running][:Reference]}").first

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


  def running_update
    @activity = Activity.where('reference = ?', "#{params[:running][:Reference]}").first
    ref_activity = @activity

    if (@activity.reference.include?("ref:"))
      @activity = Activity.where('id = ?', "#{ @activity.reference[4, @activity.reference.length] }").first
    end

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
        partnership = Partnership.where('reference = ?', "/CyberCoachServer/resources/partnerships/" + current_user.username.downcase + ";" + item[:text].downcase + "/").first

        if (partnership == nil)
          partnership = Partnership.where('reference = ?', "/CyberCoachServer/resources/partnerships/" + item[:text].downcase + ";" + current_user.username.downcase + "/").first
        end

        puts "/CyberCoachServer/resources/partnerships/" + item[:text].downcase + ";" + current_user.username.downcase + "/"

        subscription = Subscription.find_by(reference: partnership.reference + "/Running/")
        if (subscription == nil)
          puts "Not Found: "
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
          subscription.save
        else
          subscription = SubscriptionsHelper.fetch(subscription)
          puts "Found: " + subscription.reference
        end
        isFound = false
        @activity.entries.each do |entry|
          if (entry.subscription.reference = subscription.reference)
            entry.set_property("entrylocation", params[:running][:Location])
            entry.set_property("comment", params[:running][:Comment])
            entry.set_property("publicvisible", 2)
            entry.public_visible = 2
            entry.save

            puts "Found Entry: " + entry.get_property("comment")

            isFound = true
          end
        end

        if (!isFound)

          puts "Not Found Entry: " + params[:running][:Comment]

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
end
