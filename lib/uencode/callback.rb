module UEncode
  class Callback 
    class Item
      attr_reader :key, :destination, :status, :error_message, :started, :completed

      def initialize(xml)
        @doc           = Nokogiri::XML(xml)
        @key           = @doc.xpath("//key").text
        @destination   = @doc.xpath("//destination").text
        @status        = @doc.xpath("//status").text
        @error_message = @doc.xpath("//error_message").text
        @started       = Date.parse(@doc.xpath("//started").text)
        @completed     = Date.parse(@doc.xpath("//completed").text)
      end
    end

    class Video < Item 
      attr_reader :bytes

      def initialize(xml)
        super
        @bytes = @doc.xpath("//bytes").text.to_i
      end
    end

    class Capture < Item; end

    attr_reader :key, :status, :userdata, :started, :completed, :items

    def initialize(xml)
      @doc   = Nokogiri::XML(xml)
      @items = []
      set_job_attributes
      create_output_results
    end

    def videos
      items.select { |item| item.instance_of?(Video) }
    end

    def captures
      items.select { |item| item.instance_of?(Capture) }
    end

    private
    def set_job_attributes
      @key       = @doc.xpath("//callback/key[1]").text
      @status    = @doc.xpath("//callback/status[1]").text
      @userdata  = @doc.xpath("//callback/userdata").text
      @started   = Date.parse(@doc.xpath("//callback/started[1]").text)
      @completed = Date.parse(@doc.xpath("//callback/completed[1]").text)
    end

    def create_output_results
      create_video_output_results
      create_capture_output_results
    end

    def create_video_output_results
      @doc.xpath("//outputs/video").each { |video_xml| @items << Video.new(video_xml.to_xml) } 
    end

    def create_capture_output_results
      @doc.xpath("//outputs/capture").each { |capture_xml| @items << Capture.new(capture_xml.to_xml) } 
    end
  end
end
