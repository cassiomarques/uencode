module Uencode
  class Crop
    ATTRIBUTES = [:width, :height, :x, :y]

    def to_xml
      %Q{
        <crop>
          <width>#{width}</width>
          <height>#{height}</height>
          <x>#{x}</x>
          <y>#{y}</y>
        </crop>
      }
    end
  end

  module RateElement
    def to_xml
      %Q{
        <framerate>
          <numerator>#{numerator}</numerator>
          <denominator>#{denominator}</denominator>
        </framerate>
      }
    end
  end

  class FrameRate
    include RateElement
    ATTRIBUTES = [:numerator, :denominator]
  end

  class Par < FrameRate
    include RateElement
    ATTRIBUTES = [:numerator, :denominator]
  end

  class CaptureOutput
    ATTRIBUTES = [:destination, :rate, :stretch]
  end

  class VideoOutput
    ATTRIBUTES = [:destination, :container]

    attr_reader :video_config, :audio_config

    def initialize(options)
      @video_config = VideoConfig.new
      @audio_config = AudioConfig.new
      super
    end

    def configure_video
      yield @video_config
    end

    def configure_audio
      yield @audio_config
    end

    private
    class VideoConfig
      attr_accessor :bitrate, :codec, :cbr, :crop, :deinterlace, :framerate, :height, :keyframe_interval,
                    :maxbitrate, :par, :profile, :passes, :stretch, :width

      def initialize
        @cbr = false
        @deinterlace = false
        @profile = "main"
        @passes = 1
        @stretch = false
      end

    end

    class AudioConfig
      attr_accessor :codec, :bitrate, :channels, :samplerate
    end
  end

  class Job
    ATTRIBUTES = [:source, :userdata, :notify]

    include Enumerable

    attr_reader :items

    def initialize(options)
      @items = []
      super
    end

    def <<(item)
      @items << item
    end

    def each
      @items.each { |item| yield item }
    end
  end

  [FrameRate, Crop, VideoOutput, CaptureOutput, Job].each { |klass| klass.send :include, AttrSetting }
end
