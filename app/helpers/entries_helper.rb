module EntriesHelper
  def self.save_cy_ber_coach(entry)
    uri = URI.parse("http://diufvm31.unifr.ch:8090/")

    puts "Reference: " + entry.subscription.reference

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(entry.subscription.reference)
    request["Accept"] = "application/json"
    request["Authorization"] = SessionsHelper.current_user.basic_authorization
    request["Content-Type"] =  "application/json"

=begin
    if (entry.type == "running")
      request.set_form_data({ "entryrunning" => {
                                "publicvisible" => "2",
                                "comment" => entry.comment,
                                "entrylocation" => entry.entry_location,
                                "coursetype" => entry.course_type,
                                "track" => entry.track}
                            })
    else
=end
    test = ActiveSupport::JSON.encode({ entryboxing:
                                            { publicvisible: "2",
                                              comment: "",
                                              entrydate: "",
                                              roundduration: "",
                                              entrylocation: "",
                                              roundduration: "",
                                              numberofrounds: ""
                                            }
                                      })

      request(test)

    #end
    http
    response = http.request(request)

    if (response.code == "200" || response.code == "201")
      parsed_json = ActiveSupport::JSON.decode(response.body)
      puts parsed_json
      entry.reference = parsed_json["uri"]
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
