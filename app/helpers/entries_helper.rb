module EntriesHelper
  def self.save_cy_ber_coach(entry)
    uri = URI.parse("http://diufvm31.unifr.ch:8090/")
    http = Net::HTTP.new(uri.host, uri.port)

    if (entry.subscription != nil)
      if (entry.id == nil)
        request = Net::HTTP::Post.new(entry.subscription.reference)
        puts "Entry Subscription: " +  entry.subscription.reference
      else
        request = Net::HTTP::Put.new(entry.reference)
        puts "Entry Subscription: " +  entry.reference
      end

      request["Accept"] = "application/json"
      request["Authorization"] = entry.user.basic_authorization
      request["Content-Type"] = "application/json"
      request.body = entry.get_data().to_json

      response = http.request(request)

      if (response.code == "200" || response.code == "201")
        if (entry.id == nil)
          entry.reference = response["location"]
        end
        entry.is_proxy = true
        true
      else
        puts(response.body)
        puts(response.code)
        subscription.asv = "ddd"
        false
      end
    end
  end

  def self.fetch(entry)
    uri = URI.parse("http://diufvm31.unifr.ch:8090/")

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(entry.reference)
    request["Accept"] = "application/json"
    request["Authorization"] = entry.user.basic_authorization
    response = http.request(request)

    entry.subscription = SubscriptionsHelper.fetch(entry.subscription)
    entry_root = "entry" + entry.subscription.sport.name.downcase

    if (response.code == "200")
      parsed_json = ActiveSupport::JSON.decode(response.body)
      @un_proxy_entry = Entry.new
      @un_proxy_entry.id = entry.id
      @un_proxy_entry.reference = parsed_json[entry_root]["uri"]
      @un_proxy_entry.public_visible = parsed_json[entry_root]["publicvisible"]
      @un_proxy_entry.subscription = entry.subscription

      @un_proxy_entry.set_property("comment", parsed_json[entry_root]["comment"])
      @un_proxy_entry.set_property("entrylocation", parsed_json[entry_root]["entrylocation"])
      @un_proxy_entry
    else
      puts(response.code)
      subscription.asv = "ddd"
      nil
    end
  end

  def self.delete_cy_ber_coach(entry)
    uri = URI.parse("http://diufvm31.unifr.ch:8090/")
    http = Net::HTTP.new(uri.host, uri.port)

    puts "Delete Entry : " +  entry.reference

    if (entry.subscription != nil)
      request = Net::HTTP::Delete.new(entry.reference)
      request["Accept"] = "application/json"
      request["Authorization"] = entry.user.basic_authorization
      request["Content-Type"] = "application/json"
      response = http.request(request)

      if (response.code == "200" || response.code == "201")
        true
      else
        puts(response.body)
        puts(response.code)
        subscription.asv = "ddd"
        false
      end
    end
  end
end
