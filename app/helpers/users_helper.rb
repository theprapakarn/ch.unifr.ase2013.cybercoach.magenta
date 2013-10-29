module UsersHelper
  def self.save_or_update_cy_ber_coach(user)

    if user.id == nil
      participant = Participant.new
      participant.user = user
      participant.public_visible = "2"
      participant.first_name = ""
      participant.last_name = ""
    else
      participant = Participant.where('user_id = ?', "#{user.id}").first

      if participant == nil
        participant = Participant.new
        participant.user = user
        participant.public_visible = "2"
        participant.first_name = ""
        participant.last_name = ""
      end
    end

    uri = URI.parse("http://diufvm31.unifr.ch:8090/")

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Put.new("/CyberCoachServer/resources/users/" + user.username)
    request["Accept"] = "application/json"
    request.set_form_data({"email" => user.email,
                           "password" => user.password,
                           "publicvisible" => participant.public_visible,
                           "realname" => participant.first_name + " " + participant.last_name})

    if user.basic_authorization == nil
      request.basic_auth(user.username, user.password)
    else
      request["Authorization"] = user.basic_authorization
    end

    response = http.request(request)

    user.basic_authorization = request["Authorization"]

    if (response.code == "200" || response.code == "201")
      parsed_json = ActiveSupport::JSON.decode(response.body)

      participant.reference = parsed_json["uri"]
      participant.date_created = parsed_json["datecreated"]
      participant.save

      if parsed_json["subscriptions"] != nil
        parsed_json["subscriptions"].each do |item|
          subscription = Subscription.where('reference = ?', "#{item['uri']}").first

          if (subscription == nil)
            subscription = Subscription.new
          end

          subscription.participant = participant
          subscription.reference = item['uri']
          subscription.is_proxy = true
          subscription.save
        end
      end

      if parsed_json["partnerships"] != nil
        parsed_json["partnerships"].each do |item|
          partnership = Partnership.where('reference = ?', "#{ item['uri'] }").first

          if (partnership == nil)
            partnership = Partnership.new
          end

          partnership.reference = item['uri']
          partnership.is_proxy = true
          partnership.save

          participant.partnerships.concat(partnership)
        end
      end

      true
    else
      puts(response.code)
      puts(user.username)
      puts(user.password)
      subscription.asv = "ddd"
      false
    end
  end

end
