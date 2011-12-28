module UEncode
  class Request
    include HTTParty
    base_uri "https://api.uencode.com"
    format :xml
    
    def initialize(job)
      @job = job
    end

    def send
      response = self.class.post "/300/jobs", :body => @job.to_xml, :headers => {"Authentication" => UEncode.customer_key}
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
