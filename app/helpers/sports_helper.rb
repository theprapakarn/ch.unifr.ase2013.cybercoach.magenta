module SportsHelper

  def self.get_cy_ber_coach_sports
    uri = URI.parse("http://diufvm31.unifr.ch:8090/")

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new("/CyberCoachServer/resources/sports/")
    request["Accept"] = "application/json"

    response = http.request(request)
    parsed_json = ActiveSupport::JSON.decode(response.body)

    @sports = Array.new(Integer(parsed_json['available']))
    count = 0

    parsed_json["sports"].each do |item|
      sport = Sport.new
      sport.reference = item['uri']
      sport.name = item['name']
      @sports[count] = sport

      count += 1
    end

    @sports
  end
end
