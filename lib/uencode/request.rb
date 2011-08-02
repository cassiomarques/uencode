module UEncode
  class Request
    include HTTParty

    base_uri "http://204.14.178.5"
    format :xml
    
    def initialize(job)
      @job = job
    end

    def send
      response = self.class.post "/job", :body => @job.to_xml
      parse_response response
    end

    private
    def parse_response(response_xml)
      doc      = Nokogiri::XML response_xml.body
      status   = doc.xpath("//status").text
      key      = doc.xpath("//job/key[1]").text
      message  = doc.xpath("//message").text
      userdata = doc.xpath("//userdata").text

      Response.new(
        :status   => status,
        :job_key  => key,
        :message  => message,
        :userdata => userdata
      )
    end
  end
end
