module UEncode
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

    def ==(other)
      other.width == width && other.height == height
    end
  end

  class Capture
    ATTRIBUTES = [:destination, :rate, :size]

    def initialize(options)
      super
    end

    def to_xml
      %Q{
        <capture>
          <rate>#{rate}</rate>
          <destination>#{destination}</destination>
          #{@size ? @size.to_xml : ""}
        </capture>
      }
    end
  end

  class Video
    ATTRIBUTES = [:destination, :container]

    attr_reader :video_config, :audio_config

    def initialize(options = {})
      super
      @video_config = VideoConfig.new
      @audio_config = AudioConfig.new
    end

    # Configures the transcoding using a nested hash with the following format:
    #
    #   config = {"video" => { ... }, "audio" => { ... }
    #
    # The keys for the "video" hash can be any of the following: bitrate, codec, 
    # deinterlace, framerate, size.
    #
    # The video size must be specified as a hash containing the 'width' and 'height' keys
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
        <video>
          <destination>#{destination}</destination>
          <container>#{container}</container>
          <video>
            <bitrate>#{video.bitrate}</birate>
            <codec>#{video.codec}</birate>
            #{video.deinterlace.nil? ? "" : '<deinterlace>' + video.deinterlace.to_s + '</deinterlace>'}
            #{video.framerate.nil? ? "" : '<framerate>' + video.framerate.to_s + '</framerate>'}
            #{video.size.nil? ? "" : video.size.to_xml}
          </video>
          <audio>
            #{audio.codec.nil? ? "" : '<codec>' + audio.codec + '</codec>'}
            #{audio.bitrate.nil? ? "" : '<bitrate>' + audio.bitrate.to_s + '</bitrate>'}
            #{audio.channels.nil? ? "" : '<channels>' + audio.channels.to_s + '</channels>'}
            #{audio.samplerate.nil? ? "" : '<samplerate>' + audio.samplerate.to_s + '</samplerate>'}
          </audio>
        </video>
      }
    end
  end

  class VideoConfig
    attr_accessor :bitrate, :codec, :deinterlace, :framerate, :size

    def initialize
      @deinterlace = false
    end

    def size=(_size)
      _size = Size.new(_size) unless _size.instance_of?(Size) || _size.nil?
      instance_variable_set :@size, _size
    end
  end

  # The audio configs for each instance of +Video+
  class AudioConfig
    attr_accessor :codec, :bitrate, :channels, :samplerate
  end

  class Job
    ATTRIBUTES = [:source, :userdata, :callback]

    attr_reader :items

    include Enumerable

    def self.from_hash(hash)
      new({})
    end

    def initialize(options)
      @items = []
      super
    end

    def <<(item)
      @items << item
    end

    def each(&block)
      @items.each &block
    end

    def to_xml
      xml = %Q{
        <job>
          <customerkey>#{UEncode.customer_key}</customerkey>
          <source>#{source}</source>
          #{userdata.nil? ? "" : '<userdata>' + userdata + '</userdata>'}
          #{callback.nil? ? "" : '<callback>' + callback + '</callback>'}
          <outputs>
            #{@items.sort_by { |i| i.class.name }.inject("") { |s, item| s << item.to_xml }}
          </outputs>
        </job>
      }
      Nokogiri::XML(xml).to_xml
    end
  end

  [Size, Video, Capture, Job].each { |klass| klass.send :include, AttrSetting }
end
