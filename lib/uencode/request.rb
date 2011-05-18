module Uencode
  class Request
    ENDPOINT = "https://www.uencode.com/jobs?version=300"

    def initialize(job)
      @job = job
    end

    def send
      response_xml = Typhoeus::Request.put(ENDPOINT, :body => job.to_xml)
    end

    private
    def parse_response(response_xml)
      doc      = Nokogir::XML response_xml.body
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
