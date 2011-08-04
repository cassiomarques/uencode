module UEncode
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

  class Size
    ATTRIBUTES = [:width, :height]

    def to_xml
      %Q{
        <size>
          <width>#{width}</width>
          <height>#{height}</heignt>
        </size>
      }
    end
  end

  module RateElement
    ATTRIBUTES = [:numerator, :denominator]

    include AttrSetting

    def to_xml
      %Q{
        <#{root_name}>
          <numerator>#{numerator}</numerator>
          <denominator>#{denominator}</denominator>
        </#{root_name}>
      }
    end

    def ==(other)
      numerator == other.numerator && denominator == other.denominator
    end
  end

  class FrameRate
    include RateElement

    private
    def root_name; "framerate"; end
  end

  class Par < FrameRate
    include RateElement

    private
    def root_name; "par"; end
  end

  class CaptureOutput
    ATTRIBUTES = [:destination, :rate, :stretch, :crop, :size]

    def initialize(options)
      super
      @stretch = false if @stretch.nil?
    end

    def to_xml
      %Q{
        <output>
          <capture>
            <rate>#{rate}</rate>
            <destination>#{destination}</destination>
          #{@crop ? @crop.to_xml : ""}
          #{@size ? @size.to_xml : ""}
          </capture>
        <//output>
      }
    end
  end

  class VideoOutput
    ATTRIBUTES = [:destination, :container]

    include Enumerable

    # a list of Medium
    attr_reader :items
    attr_writer :destination, :container

    def initialize(options)
      @items = []
      super
    end

    def each
      @items.each { |item|  yield item }
    end

    def to_xml
      %Q{
        <output>
          <video>
            <destination>#{destination}</destination>
            <container>#{container}</container>
            <media>
              #{@items.inject("") { |s, item| s << item.to_xml }}
            </media>
          </video>
        </output>
      }
    end
  end

  # Medium is a single video to transcode
  class Medium
    attr_reader :video_config, :audio_config

    def initialize
      @video_config = VideoConfig.new
      @audio_config = AudioConfig.new
    end

    # Configures the transcoding using a nested hash with the following format:
    #
    #   config = {"video" => { ... }, "audio" => { ... }
    #
    # The keys for the "video" hash can be any of the following: bitrate, codec, cbr, crop, 
    # deinterlace, framerate, height, keyframe_interval, maxbitrate, par, profile, passes,
    # stretch, width.
    #
    # The "framerate" and "par" values must be also hashes, with the following format:
    #
    #   {"numerator" => 10, "denominator" => 11}
    #
    # The keys for the "audio" hash can be any of the following:
    # codec, bitrate, channels, samplerate.
    #   
    def configure(hash)
      video = hash["video"]
      audio = hash["audio"]      
      configure_video do |c|
        video.each_pair { |key, value| c.send("#{key}=", value) }
      end

      configure_audio do |c|
        audio.each_pair { |key, value| c.send("#{key}=", value) }
      end
    end

    def configure_video
      yield @video_config
    end

    def configure_audio
      yield @audio_config
    end     

    def video
      @video_config
    end

    def audio
      @audio_config
    end

    def to_xml
      %Q{
        <medium>
          <video>
            <bitrate>#{video.bitrate}</birate>
            <codec>#{video.codec}</birate>
            #{!video.cbr.nil? ? '<cbr>' + video.cbr.to_s + '</cbr>' : ""}
            #{video.crop ? video.crop.to_xml : ""}
            #{video.deinterlace.nil? ? "" : '<deinterlace>' + video.deinterlace.to_s + '</deinterlace>'}
            #{video.framerate ? video.framerate.to_xml : ""}
            #{video.height.nil? ? "" : '<height>' + video.height.to_s + '</height>'}
            #{video.keyframe_interval.nil? ? "" : '<keyframe_interval>' + video.keyframe_interval.to_s + '</keyframe_interval>'}
            #{video.maxbitrate.nil? ? "" : '<maxbitrate>' + video.maxbitrate.to_s + '</maxbitrate>'}
            #{video.par ? video.par.to_xml : ""}
            #{video.profile.nil? ? "" : '<profile>' + video.profile + '</profile>'}
            #{video.passes.nil? ? "" : '<passes>' + video.passes.to_s + '</passes>'}
            #{[nil, false].include?(video.stretch) ? "" : '<stretch>' + video.stretch.to_s + '</stretch>'}
            #{video.width.nil? ? "" : '<width>' + video.width.to_s + '</width>'}
          </video>
          <audio>
            #{audio.codec.nil? ? "" : '<codec>' + audio.codec + '</codec>'}
            #{audio.bitrate.nil? ? "" : '<bitrate>' + audio.bitrate.to_s + '</bitrate>'}
            #{audio.channels.nil? ? "" : '<channels>' + audio.channels.to_s + '</channels>'}
            #{audio.samplerate.nil? ? "" : '<samplerate>' + audio.samplerate.to_s + '</samplerate>'}
          </audio>
        </medium>
      }
    end
  end

  # The video configs for each Medium
  class VideoConfig
    attr_accessor :bitrate, :codec, :cbr, :crop, :deinterlace, :framerate, :height, :keyframe_interval,
      :maxbitrate, :par, :profile, :passes, :stretch, :width

    def initialize
      @cbr         = false
      @deinterlace = false
      @profile     = "main"
      @passes      = 1
      @stretch     = false
    end

    def framerate=(_framerate)
      _framerate = FrameRate.new(_framerate) unless _framerate.instance_of?(FrameRate) || _framerate.nil?
      instance_variable_set :@framerate, _framerate
    end

    def par=(_par)
      _par = Par.new(_par) unless _par.instance_of?(Par) || _par.nil?
      instance_variable_set :@par, _par
    end
  end

  # The audio configs for each Medium
  class AudioConfig
    attr_accessor :codec, :bitrate, :channels, :samplerate
  end

  class Job
    ATTRIBUTES = [:source, :userdata, :notify]

    include Enumerable

    def self.from_hash(hash)
      new({})
    end

    def initialize(options)
      @video_output = VideoOutput.new options[:video_output] || {}
      @captures = []
      @customerkey = options[:customerkey]
      super
    end

    def configure_video_output
      yield @video_output      
    end

    def items
      @video_output.items
    end

    def <<(item)
      @video_output.items << item
    end

    def add_capture(capture)
      @captures << capture
    end

    def each(&block)
      @video_output.each &block
    end

    def to_xml
      xml = %Q{
        <job>
          <customerkey>#{@customerkey || UEncode.customer_key}</customerkey>
          <source>#{source}</source>
          #{userdata.nil? ? "" : '<userdata>' + userdata + '</userdata>'}
          #{notify.nil? ? "" : '<notify>' + notify + '</notify>'}
          <outputs>
            #{@video_output.to_xml}
            #{@captures.inject("") { |s, cap| s << cap.to_xml }}
          </outputs>
        </job>
      }
      Nokogiri::XML(xml).to_xml
    end
  end

  [Size, Crop, VideoOutput, CaptureOutput, Job].each { |klass| klass.send :include, AttrSetting }
end
