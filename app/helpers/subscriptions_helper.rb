module SubscriptionsHelper

  def self.save_cy_ber_coach(subscription)
    uri = URI.parse("http://diufvm31.unifr.ch:8090/")
    put_path = ""

    if subscription.participant
      put_path = subscription.participant.reference + subscription.sport.name
    end

    if subscription.partnership
      put_path = subscription.partnership.reference + subscription.sport.name
    end

    puts "SubScription: " + put_path

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Put.new(put_path)
    request["Accept"] = "application/json"
    request["Authorization"] = subscription.user.basic_authorization
    request.set_form_data({"publicvisible" => "2"})
    response = http.request(request)

    if (response.code == "200" || response.code == "201")
      parsed_json = ActiveSupport::JSON.decode(response.body)
      subscription.reference = parsed_json["uri"]
      subscription.is_proxy = true
      true
    else
      puts(response.code)
      subscription.asv = "ddd"
      false
    end
  end

  def self.fetch(subscription)
    uri = URI.parse("http://diufvm31.unifr.ch:8090/")

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(subscription.reference)
    request["Accept"] = "application/json"
    request["Authorization"] = subscription.user.basic_authorization
    response = http.request(request)

    if (response.code == "200")
      parsed_json = ActiveSupport::JSON.decode(response.body)
      @un_proxy_subscription = Subscription.new
      @un_proxy_subscription.id = subscription.id
      @un_proxy_subscription.reference = parsed_json["uri"]
      @un_proxy_subscription.public_visible = parsed_json["publicvisible"]

      sport = Sport.new
      sport.reference = parsed_json["sport"]["uri"]
      sport.name = parsed_json["sport"]["name"]

      if parsed_json["entries"]
        parsed_json["entries"].each do |entry_json|
          entry = Entry.find_by(reference: entry_json['uri'])
          if (entry == nil)
=begin
            entry = Entry.new
            entry.reference = entry_json["entry" + sport.name.downcase]["uri"]
            entry.is_proxy = true
            entry.subscriptions.concat(@un_proxy_subscription)
            entry.user = subscription.user
            entry.save
=end
          end
        end
      end

      @un_proxy_subscription.sport = sport
      @un_proxy_subscription
    else
      puts(response.code)
      subscription.asv = "ddd"
      nil
    end
  end

end
