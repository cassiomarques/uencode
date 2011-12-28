require 'spec_helper'

describe UEncode::Video do
  let(:video) { UEncode::Video.new }

  before :each do
    video.configure_video do |c|
      c.bitrate           = 10000
      c.codec             = "mp4"
      c.deinterlace       = true
      c.framerate         = 30
      c.size              = UEncode::Size.new :width => 500, :height => 400
    end

    video.configure_audio do |c|
      c.codec      = "aac"
      c.bitrate    = 15000
      c.channels   = 2
      c.samplerate = 10000
    end
  end

  describe "#configure_video" do
    let(:video) { UEncode::Video.new }
    let(:config) { YAML::load_file("spec/fixtures/configuration.yaml") }
    let(:video_config) { config["video"] }
    let(:audio_config) { config["audio"] }

    it { video.video.bitrate.should == 10000 }
    it { video.video.codec.should == "mp4" }
    it { video.video.deinterlace.should == true }
    it { video.video.framerate.should == 30 }
    it { video.video.size.height.should == 400 }
    it { video.video.size.width.should == 500 }

    context "from a hash (video parameters)" do
      subject { video.video_config }

      before { video.configure config }

      its(:bitrate) { should == video_config["bitrate"] }
      its(:codec) { should == video_config["codec"] }
      its(:deinterlace) { should == video_config["deinterlace"] }
      its(:framerate) { should == 30 }
      its(:size) { should == UEncode::Size.new(:width => video_config["size"]["width"], :height => video_config["size"]["height"]) }
    end

    context "from a hash (audio parameters)" do
      before { video.configure config }
      subject { video.audio_config }

      its(:codec) { should == audio_config["codec"] }
      its(:bitrate) { should == audio_config["bitrate"] }
      its(:channels) { should == audio_config["channels"] }
      its(:samplerate) { should == audio_config["samplerate"] }
    end
  end

  describe "#configure_audio" do
    let(:video) { UEncode::Video.new }

    it { video.audio.codec.should == "aac" }
    it { video.audio.bitrate.should == 15000 }
    it { video.audio.channels.should == 2 }
    it { video.audio.samplerate.should == 10000 }
  end

  context "video config default values" do
    let(:video_without_configuration) { described_class.new }

    it { video_without_configuration.video.deinterlace.should == false }
  end

  describe "#to_xml" do
    let(:xml) { Nokogiri::XML video.to_xml }

    it "has the correct video configs" do      
      config = xml.xpath("//video")
      config.xpath("//video/bitrate").text.should == "10000"
      config.xpath("//video/codec").text.should == "mp4"
      config.xpath("//video/deinterlace").text.should == "true"
      config.xpath("//video/framerate").text.should == "30"
      config.xpath("//video/size/height").text.should == "400"
      config.xpath("//video/size/width").text.should == "500"
    end

    it "does not include the deinterlace video config when it's null" do
      video.configure_video { |c| c.deinterlace = nil }
      Nokogiri::XML(video.to_xml).xpath("//video/deinterlace").should be_empty
    end

    it "does not include the framerate video config when it's null" do
      video.configure_video { |c| c.framerate = nil }
      Nokogiri::XML(video.to_xml).xpath("//video/framerate").should be_empty
    end

    it "has the correct audio configs" do
      xml.xpath("//audio/codec").text.should == "aac"
      xml.xpath("//audio/bitrate").text.should == "15000"
      xml.xpath("//audio/channels").text.should == "2"
      xml.xpath("//audio/samplerate").text.should == "10000"
    end

    it "does not include the bitrate audio config when it's null" do
      video.configure_audio { |c| c.bitrate = nil }
      Nokogiri::XML(video.to_xml).xpath("//audio/bitrate").should be_empty
    end

    it "does not include the channels audio config when it's null" do
      video.configure_audio { |c| c.channels = nil }
      Nokogiri::XML(video.to_xml).xpath("//audio/channels").should be_empty
    end

    it "does not include the samplerate audio config when it's null" do
      video.configure_audio { |c| c.samplerate = nil }
      Nokogiri::XML(video.to_xml).xpath("//audio/samplerate").should be_empty
    end
  end
end

describe UEncode::Video do
  subject { described_class.new :destination => "http://foobar.com/bla.avi", :container => "mpeg4" }

  its(:destination) { should == "http://foobar.com/bla.avi" }
  its(:container) { should == "mpeg4" }

  describe "#to_xml" do
    let(:video) { described_class.new :destination => "http://foo.com/bar.mp4", :container => "mpeg4" }
    let(:xml) { Nokogiri::XML video.to_xml }

    before :each do
      video.configure_video do |c|
        c.bitrate = 1000
        c.codec   = 'mp4'
      end
      video.configure_audio do |c|
        c.codec = "mpeg2"
      end
    end

    it "has a root element named 'video'" do
      xml.root.name.should == 'video'
    end

    it "has the correct destination value" do
      xml.xpath("//video/destinations/destination").text.should == "http://foo.com/bar.mp4"
    end

    it "has the correct container value" do
      xml.xpath("//video/container").text.should == "mpeg4"
    end

    it "has the correct video configurations" do
      xml.xpath("//video/video/bitrate").text.should == "1000"
    end

    it "has the correct audio configurations" do
      xml.xpath("//video/audio/codec").text.should == "mpeg2"
    end
  end
end

describe UEncode::Capture do
  subject { described_class.new({
    :destination => "http://whatever.com/foo.jpg",
    :rate => "at 20s"
  }) }

  its(:destination) { should == "http://whatever.com/foo.jpg" }
  its(:rate) { should == "at 20s" }

  describe "#to_xml" do
    let(:size) { UEncode::Size.new :width => 400, :height => 500 }
     let(:xml) {
       Nokogiri::XML described_class.new(
         :destination => "http://foo.com/bla.mp4",
         :rate        => 'every 10s',
         :size        => size
       ).to_xml  
     }

     it "has a root element named 'capture'" do
       xml.root.name.should == 'capture'
     end

     it "has the correct value for the rate attribute" do
       xml.xpath("//capture/rate").text.should == "every 10s"
     end

     it "has the correct value for the destination attribute" do
       xml.xpath("//capture/destination").text.should == "http://foo.com/bla.mp4"
     end

     it "has the correct value for the size attribute" do
       xml.xpath("//capture/size/width").text.should == "400"
       xml.xpath("//capture/size/height").text.should == "500"
     end
  end
end


describe UEncode::Size do
  subject { described_class.new :width => 100, :height => 200 }

  its(:height) { should == 200 }
  its(:width) { should == 100 }

  describe "#to_xml" do
    context "when both width and height are informed" do
      let(:xml) { Nokogiri::XML described_class.new(:width => 200, :height => 250).to_xml }

      it "has a root element named 'size'" do
        xml.root.name.should == 'size'
      end

      it "has the correct value for the width attribute" do
        xml.xpath("//width").text.should == "200"
      end

      it "has the correct value for the height attribute" do
        xml.xpath("//height").text.should == "250"
      end
    end

    context "when only the height is informed" do
      let(:xml) { Nokogiri::XML described_class.new(:height => 250).to_xml }  

      it "do not add a width tag" do
        xml.xpath("//width").should be_empty
      end
    end

    context "when only the width is informed" do
      let(:xml) { Nokogiri::XML described_class.new(:width => 200).to_xml }  

      it "do not add a height tag" do
        xml.xpath("//height").should be_empty
      end
    end
  end
end

describe UEncode::Job do
  subject { described_class.new :source => "http://foo.com/bar.avi", :userdata => "some text", :callback => "http://my_url.com" }

  its(:source) { should == "http://foo.com/bar.avi" }
  its(:userdata) { should == "some text" }
  its(:callback) { should == "http://my_url.com" }
  its(:items) { should == [] }

  describe "#<<" do
    it "adds new elements to items" do
      subject << "foo"
      subject.items.should == ["foo"]
    end
  end

  it "is enumerable" do
    subject << "foo"
    subject << "bar"
    subject.map { |item| item }.should == ["foo", "bar"]
  end

  describe "#to_xml" do
    let(:job) { UEncode::Job.new({
      :customerkey => "0123456789",
      :source      => "http://whatever.com/foo.avi",
      :userdata    => "some text",
      :callback    => "http://callback.me/meh"
    })}

    let(:xml) { Nokogiri::XML job.to_xml }

    before :each do
      video1 = UEncode::Video.new :destination => "http://whatever.com/foo1.mp4", :container => "mpeg4"
      video1.configure_video do |c|
        c.bitrate = 1000
        c.codec   = 'mp4'
      end
      video1.configure_audio do |c|
        c.codec = 'aac'
      end
      video2 = UEncode::Video.new :destination => "http://whatever.com/foo2.mp4", :container => "mpeg4"
      video2.configure_video do |c|
        c.bitrate = 1500
        c.codec   = 'mpeg2'
      end
      video2.configure_audio do |c|
        c.codec = 'passthru'
      end
      job << video1
      job << video2

      capture1 = UEncode::Capture.new :destination => "http://whatever.com/foo.zip", :rate => "every 30s"
      job << capture1
      capture2 = UEncode::Capture.new :destination => "http://whatever.com/bar.zip", :rate => "every 10s"
      job << capture2
    end

    it "has a root element named 'job'" do
      xml.root.name.should == 'job'
    end

    it "has the correct source attribute" do
      xml.xpath("//job/source").text.should == "http://whatever.com/foo.avi"
    end

    it "has the correct user data value" do
      xml.xpath("//job/userdata").text.should == 'some text'
    end

    it "has the correct callback value" do
      xml.xpath("//job/callback").text.should == "http://callback.me/meh"
    end

    it "does not include the userdata attribute when it's null" do
      job.instance_variable_set :@userdata, nil
      xml.xpath("//job/userdata").should be_empty
    end

    it "does not include the callback attribute when it's null" do
      job.instance_variable_set :@callback, nil
      xml.xpath("//job/callback").should be_empty
    end

    it "contains the correct content to represent each video output item" do
      xml.xpath("//job/outputs/video").length.should == 2
    end

    it "has the correct video output destination" do
      xml.xpath("//job/outputs/video[1]/destinations/destination").text.should == "http://whatever.com/foo2.mp4"
      xml.xpath("//job/outputs/video[2]/destinations/destination").text.should == "http://whatever.com/foo1.mp4"
    end

    it "has the correct video output container" do
      xml.xpath("//job/outputs/video[1]/container").text.should == "mpeg4"
      xml.xpath("//job/outputs/video[2]/container").text.should == "mpeg4"
    end

    it "contains the correct content to represent the video captures" do
      xml.xpath("//job/outputs/capture").length.should == 2
    end
  end
end
