module UEncode
  class Request
    include HTTParty

    base_uri "https://www.uencode.com"
    format :xml
    
    def initialize(job)
      @job = job
    end

    def send
      response = self.class.put "/jobs?version=300", :body => @job.to_xml
      parse_response response
    end

    private
    def parse_response(response_xml)
      doc      = Nokogiri::XML response_xml.body
      code     = doc.xpath("//code").text
      message  = doc.xpath("//message").text
      jobid    = doc.xpath("//jobid").text
      userdata = doc.xpath("//userdata").text

      Response.new(
        :code     => code,
        :message  => message,
        :jobid    => jobid,
        :userdata => userdata
      )
    end
  end
end
