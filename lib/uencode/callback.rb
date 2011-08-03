module UEncode
  class Callback
    class Item
      ATTRIBUTES = [:key, :destination, :status, :error_message, :started, :completed, :bytes]

      include AttrSetting

      def bytes
        @bytes.to_i
      end

      def completed
        DateTime.parse @completed
      end

      def started
        DateTime.parse @started
      end
    end

    ATTRIBUTES = [:key, :status, :userdata, :started, :completed]

    include AttrSetting

    class Video   < Item ; end
    class Capture < Item; end

    def initialize(options)
      super
      @options = options
      create_output_results
    end

    def items
      @items ||= []
    end

    def videos
      items.select { |item| item.instance_of?(Video) }
    end

    def captures
      items.select { |item| item.instance_of?(Capture) }
    end

    def completed
      DateTime.parse @completed
    end

    def started
      DateTime.parse @started
    end

    private
    def create_output_results
      create_video_output_results
      create_capture_output_results
    end

    def create_video_output_results
      items << Video.new(@options["outputs"]["video"])
    end

    def create_capture_output_results
      items << Capture.new(@options["outputs"]["capture"])
    end
  end
end
