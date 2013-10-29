module PartnershipsHelper
  def self.save_cy_ber_coach(partnership)
    uri = URI.parse("http://diufvm31.unifr.ch:8090/")

    count = 0
    participants_path = ""

    partnership.participants.each do |participant|
      participants_path = participants_path + participant.user.username
      if(partnership.participants.count - 1 != count)
        participants_path = participants_path + ";"
      end
      count += 1
    end

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Put.new("/CyberCoachServer/resources/partnerships/" + participants_path)
    request["Accept"] = "application/json"
    request["Authorization"] =  SessionsHelper.current_user.basic_authorization
    request.set_form_data({ "publicvisible" => "1" })
    response = http.request(request)

    if(response.code == "200" || response.code == "201")
      parsed_json = ActiveSupport::JSON.decode(response.body)
      partnership.reference = parsed_json["uri"]

      if parsed_json["subscriptions"] != nil
        parsed_json["subscriptions"].each do |item|
          subscription = Subscription.where('reference = ?', "#{item['uri']}").first

          if (subscription == nil)
            subscription = Subscription.new
          end

          subscription.partnership = partnership
          subscription.reference = item['uri']
          subscription.is_proxy = true
          subscription.save
        end
      end
      partnership.is_proxy = true
      true
    else
      puts(response.code)
      partnership.asv = "ddd"
      false
    end
  end

  def self.un_proxy(partnership)
    uri = URI.parse("http://diufvm31.unifr.ch:8090/")

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(partnership.reference)
    request["Accept"] = "application/json"
    request["Authorization"] = SessionsHelper.current_user.basic_authorization
    response = http.request(request)

    if(response.code == "200")
      parsed_json = ActiveSupport::JSON.decode(response.body)
      @un_proxy_partnership = Partnership.new
      @un_proxy_partnership.reference = parsed_json["uri"]
      @un_proxy_partnership.public_visible = parsed_json["publicvisible"]

      @un_proxy_partnership
    else
      puts(response.code)
      subscription.asv = "ddd"
      nil
    end
  end

end
