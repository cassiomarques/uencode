require 'spec_helper'

describe UEncode::Medium do
  let(:medium) { UEncode::Medium.new }

  before :each do
    medium.configure_video do |c|
      c.bitrate           = 10000
      c.codec             = "mp4"
      c.cbr               = false
      c.crop              = nil
      c.deinterlace       = true
      c.framerate         = UEncode::FrameRate.new :numerator => 1000, :denominator => 1001
      c.height            = 500
      c.keyframe_interval = 0
      c.maxbitrate        = 10000
      c.par               = nil
      c.profile           = "baseline"
      c.passes            = 1
      c.stretch           = false
      c.width             = 400
    end

    medium.configure_audio do |c|
      c.codec      = "aac"
      c.bitrate    = 15000
      c.channels   = 2
      c.samplerate = 10000
    end
  end

  describe "#configure_video" do
    let(:medium) { UEncode::Medium.new }
    let(:config) { YAML::load_file("spec/fixtures/configuration.yaml") }
    let(:video_config) { config["video"] }
    let(:audio_config) { config["audio"] }

    it { medium.video.bitrate.should == 10000 }
    it { medium.video.codec.should == "mp4" }
    it { medium.video.cbr.should == false }
    it { medium.video.crop.should be_nil }
    it { medium.video.deinterlace.should == true }
    it { medium.video.framerate.numerator.should == 1000 }
    it { medium.video.height.should == 500 }
    it { medium.video.keyframe_interval.should == 0 }
    it { medium.video.maxbitrate.should == 10000 }
    it { medium.video.par.should be_nil }
    it { medium.video.profile.should == "baseline" }
    it { medium.video.passes.should == 1 }
    it { medium.video.stretch.should == false }
    it { medium.video.width.should == 400 }

    context "from a hash (video parameters)" do
      before { medium.configure config }
      subject { medium.video_config }

      its(:bitrate) { should == video_config["bitrate"] }
      its(:codec) { should == video_config["codec"] }
      its(:cbr) { should == video_config["cbr"] }
      its(:crop) { should == video_config["crop"] }
      its(:deinterlace) { should == video_config["deinterlace"] }
      its(:framerate) { should == video_config["framerate"] }
      its(:height) { should == video_config["height"] }
      its(:keyframe_interval) { should == video_config["keyframe_interval"] }
      its(:maxbitrate) { should == video_config["maxbitrate"] }
      its(:par) { should == video_config["par"] }
      its(:profile) { should == video_config["profile"] }
      its(:passes) { should == video_config["passes"] }
      its(:stretch) { should == video_config["stretch"] }
      its(:width) { should == video_config["width"] }
    end

    context "from a hash (audio parameters)" do
      before { medium.configure config }
      subject { medium.audio_config }

      its(:codec) { should == audio_config["codec"] }
      its(:bitrate) { should == audio_config["bitrate"] }
      its(:channels) { should == audio_config["channels"] }
      its(:samplerate) { should == audio_config["samplerate"] }
    end
  end

  describe "#configure_audio" do
    let(:medium) { UEncode::Medium.new }

    it { medium.audio.codec.should == "aac" }
    it { medium.audio.bitrate.should == 15000 }
    it { medium.audio.channels.should == 2 }
    it { medium.audio.samplerate.should == 10000 }
  end

  context "video config default values" do
    let(:medium_without_configuration) { described_class.new }

    it { medium_without_configuration.video.cbr.should == false }
    it { medium_without_configuration.video.deinterlace.should == false }
    it { medium_without_configuration.video.profile.should == "main" }
    it { medium_without_configuration.video.passes.should == 1 }
    it { medium_without_configuration.video.stretch.should == false }
  end

  describe "#to_xml" do
    let(:xml) { Nokogiri::XML medium.to_xml }

    before :each do
      medium.configure_video do |c|
        c.crop = UEncode::Crop.new :width => 125, :height => 150, :x => 100, :y => 200
        c.par = UEncode::Par.new :numerator => 10, :denominator => 11
      end
    end

    it "has a root element named 'media'" do
      xml.root.name.should == 'medium'
    end

    it "has the correct video configs" do
      config = xml.xpath("//video")
      config.xpath("//video/bitrate").text.should == "10000"
      config.xpath("//video/codec").text.should == "mp4"
      config.xpath("//cbr").text.should == "false"
      config.xpath("//crop/width").text.should == "125"
      config.xpath("//crop/height").text.should == "150"
      config.xpath("//crop/x").text.should == "100"
      config.xpath("//crop/y").text.should == "200"
      config.xpath("//deinterlace").text.should == "true"
      config.xpath("//framerate/numerator").text.should == "1000"
      config.xpath("//framerate/denominator").text.should == "1001"
      config.xpath("//video/height").text.should == "500"
      config.xpath("//keyframe_interval").text.should == "0"
      config.xpath("//maxbitrate").text.should == "10000"
      config.xpath("//par/numerator").text.should == "10"
      config.xpath("//par/denominator").text.should == "11"
      config.xpath("//profile").text.should == "baseline"
      config.xpath("//passes").text.should == "1"
      config.xpath("//video/width").text.should == "400"
    end

    it "does not include the cbr video config when it's null" do
      medium.configure_video { |c| c.cbr = nil }
      Nokogiri::XML(medium.to_xml).xpath("//video/cbr").should be_empty
    end

    it "does not include the crop video config when it's null" do
      medium.configure_video { |c| c.crop = nil }
      Nokogiri::XML(medium.to_xml).xpath("//video/crop").should be_empty
    end

    it "does not include the deinterlace video config when it's null" do
      medium.configure_video { |c| c.deinterlace = nil }
      Nokogiri::XML(medium.to_xml).xpath("//video/deinterlace").should be_empty
    end

    it "does not include the framerate video config when it's null" do
      medium.configure_video { |c| c.framerate = nil }
      Nokogiri::XML(medium.to_xml).xpath("//video/framerate").should be_empty
    end

    it "does not include the height video config when it's null" do
      medium.configure_video { |c| c.height = nil }
      Nokogiri::XML(medium.to_xml).xpath("//video/height").should be_empty
    end

    it "does not include the keyframe_interval video config when it's null" do
      medium.configure_video { |c| c.keyframe_interval = nil }
      Nokogiri::XML(medium.to_xml).xpath("//video/keyframe_interval").should be_empty
    end

    it "does not include the maxbitrate video config when it's null" do
      medium.configure_video { |c| c.maxbitrate = nil }
      Nokogiri::XML(medium.to_xml).xpath("//video/maxbitrate").should be_empty
    end

    it "does not include the par video config when it's null" do
      medium.configure_video { |c| c.par = nil }
      Nokogiri::XML(medium.to_xml).xpath("//video/par").should be_empty
    end

    it "does not include the profile video config when it's null" do
      medium.configure_video { |c| c.profile = nil }
      Nokogiri::XML(medium.to_xml).xpath("//video/profile").should be_empty
    end

    it "does not include the passes video config when it's null" do
      medium.configure_video { |c| c.passes = nil }
      Nokogiri::XML(medium.to_xml).xpath("//video/passes").should be_empty
    end
    
    it "does not include the stretch video config when it's null" do
      medium.configure_video { |c| c.stretch = nil }
      Nokogiri::XML(medium.to_xml).xpath("//video/stretch").should be_empty
    end

    it "does not include the width video config when it's null" do
      medium.configure_video { |c| c.width = nil }
      Nokogiri::XML(medium.to_xml).xpath("//video/width").should be_empty
    end

    it "does not include the stretch video config when it's false" do
      medium.configure_video { |c|  c.stretch = false }
      Nokogiri::XML(medium.to_xml) .xpath("//video/stretch").should be_empty
    end

    it "has the correct audio configs" do
      xml.xpath("//audio/codec").text.should == "aac"
      xml.xpath("//audio/bitrate").text.should == "15000"
      xml.xpath("//audio/channels").text.should == "2"
      xml.xpath("//audio/samplerate").text.should == "10000"
    end

    it "does not include the bitrate audio config when it's null" do
      medium.configure_audio { |c| c.bitrate = nil }
      Nokogiri::XML(medium.to_xml).xpath("//audio/bitrate").should be_empty
    end

    it "does not include the channels audio config when it's null" do
      medium.configure_audio { |c| c.channels = nil }
      Nokogiri::XML(medium.to_xml).xpath("//audio/channels").should be_empty
    end

    it "does not include the samplerate audio config when it's null" do
      medium.configure_audio { |c| c.samplerate = nil }
      Nokogiri::XML(medium.to_xml).xpath("//audio/samplerate").should be_empty
    end
  end
end

describe UEncode::VideoOutput do
  subject { described_class.new :destination => "http://foobar.com/bla.avi", :container => "mpeg4" }

  its(:destination) { should == "http://foobar.com/bla.avi" }
  its(:container) { should == "mpeg4" }


  describe "#to_xml" do
    let(:video_output) { described_class.new :destination => "http://foo.com/bar.mp4", :container => "mpeg4" }
    let(:xml) { Nokogiri::XML video_output.to_xml }


    it "has a root element named 'output'" do
      xml.root.name.should == 'output'
    end

    it "has the correct destination value" do
      xml.xpath("//output/video/destination").text.should == "http://foo.com/bar.mp4"
    end

    it "has the correct container value" do
      xml.xpath("//output/video/container").text.should == "mpeg4"
    end
  end
end

describe UEncode::CaptureOutput do
  subject { described_class.new({
    :destination => "http://whatever.com/foo.jpg",
    :rate => "at 20s",
    :stretch => false
  }) }

  its(:destination) { should == "http://whatever.com/foo.jpg" }
  its(:rate) { should == "at 20s" }
  its(:stretch) { should == false }

  context "default values" do
    let(:capture) { described_class.new :rate => "every 10s" }

    it { capture.stretch.should == false }
  end

  describe "#to_xml" do
    let(:crop) { UEncode::Crop.new :width => 125, :height => 140, :x => 100, :y => 200 }
    let(:size) { UEncode::Size.new :width => 400, :height => 500 }
     let(:xml) {
       Nokogiri::XML described_class.new(
         :destination => "http://foo.com/bla.mp4",
         :stretch     => false,
         :rate        => 'every 10s',
         :crop        => crop,
         :size        => size
       ).to_xml  
     }

     it "has a root element named capture" do
       xml.root.name.should == 'output'
     end

     it "has the correct value for the rate attribute" do
       xml.xpath("//output/capture/rate").text.should == "every 10s"
     end

     it "has the correct value for the destination attribute" do
       xml.xpath("//output/capture/destination").text.should == "http://foo.com/bla.mp4"
     end

     it "has the correct value for the crop attribute" do
       xml.xpath("//output/capture/crop/width").text.should == "125"
       xml.xpath("//output/capture/crop/height").text.should == "140"
     end

     it "has the correct value for the size attribute" do
       xml.xpath("//output/capture/size/width").text.should == "400"
       xml.xpath("//output/capture/size/height").text.should == "500"
     end
  end
end

describe UEncode::Crop do
  subject { described_class.new :width => 100, :height => 200, :x => 100, :y => 150 }

  its(:width) { should == 100 }
  its(:height) { should == 200 }
  its(:x) { should == 100 }
  its(:y) { should = 150 }

  describe "#to_xml" do
    let(:xml) { Nokogiri::XML described_class.new(:width => 100, :height => 200, :x => 100, :y => 150).to_xml }

    it "has a root element named 'crop'" do
      xml.root.name.should == 'crop'
    end

    it "has the correct value for the width attribute" do
      xml.xpath("//width").text.should == "100"
    end

    it "has the correct value for the height attribute" do
      xml.xpath("//height").text.should == "200"
    end

    it "has the correct value for the x attribute" do
      xml.xpath("//x").text.should == "100"
    end

    it "has the correct value for the y attribute" do
      xml.xpath("//y").text.should == "150"
    end
  end
end

shared_examples_for "an element that represents a rate number" do
  subject { described_class.new :numerator => numerator, :denominator => denominator }

  its(:numerator) { should == numerator }
  its(:denominator) { should == denominator }

  describe "#to_xml" do
    let(:xml) { Nokogiri::XML described_class.new(:numerator => numerator, :denominator => denominator).to_xml }
    
    it "has a root element named '#{name}'" do
      xml.root.name.should == name
    end

    it "has the correct value for the numerator attribute" do
      xml.xpath("//numerator").text.should == numerator.to_s
    end

    it "has the correct value for the denominator attribute" do
      xml.xpath("//denominator").text.should == denominator.to_s
    end
  end  
end

describe UEncode::FrameRate do
  let(:name) { "framerate" }
  let(:numerator) { 1000 }
  let(:denominator) { 1001 }

  it_should_behave_like "an element that represents a rate number"
end

describe UEncode::Par do
  let(:name) { "par" }
  let(:numerator) { 10 }
  let(:denominator) { 11 }

  it_should_behave_like "an element that represents a rate number"
end

describe UEncode::Size do
  subject { described_class.new :width => 100, :height => 200 }

  its(:height) { should == 200 }
  its(:width) { should == 100 }

  describe "#to_xml" do
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
end

describe UEncode::Job do
  subject { described_class.new :source => "http://foo.com/bar.avi", :userdata => "some text", :notify => "http://my_url.com" }

  its(:source) { should == "http://foo.com/bar.avi" }
  its(:userdata) { should == "some text" }
  its(:notify) { should == "http://my_url.com" }
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
      :notify      => "http://notify.me/meh"
    })}

    let(:xml) { Nokogiri::XML job.to_xml }

    before :each do
      video1 = UEncode::Medium.new
      video1.configure_video do |c|
        c.bitrate = 1000
        c.codec   = 'mp4'
      end
      video1.configure_audio do |c|
        c.codec = 'aac'
      end
      video2 = UEncode::Medium.new
      video2.configure_video do |c|
        c.bitrate = 1500
        c.codec   = 'mpeg2'
      end
      video2.configure_audio do |c|
        c.codec = 'passthru'
      end
      job << video1
      job << video2

      job.configure_video_output do |c|
        c.destination = "http://whatever.com/foo1.mp4"
        c.container   = "mpeg4"
      end

      capture1 = UEncode::CaptureOutput.new :destination => "http://whatever.com/foo.zip", :rate => "every 30s"
      job.add_capture capture1
      capture2 = UEncode::CaptureOutput.new :destination => "http://whatever.com/bar.zip", :rate => "every 10s"
      job.add_capture capture2
    end

    it "has a root element named 'job'" do
      xml.root.name.should == 'job'
    end

    it "has the correct customer key value" do
      xml.xpath("//job/customerkey").text.should == "1q2w3e4r5t"
    end

    it "has the correct source attribute" do
      xml.xpath("//job/source").text.should == "http://whatever.com/foo.avi"
    end

    it "has the correct user data value" do
      xml.xpath("//job/userdata").text.should == 'some text'
    end

    it "has the correct notify value" do
      xml.xpath("//job/notify").text.should == "http://notify.me/meh"
    end

    it "does not include the userdata attribute when it's null" do
      job.instance_variable_set :@userdata, nil
      xml.xpath("//job/userdata").should be_empty
    end

    it "does not include the notify attribute when it's null" do
      job.instance_variable_set :@notify, nil
      xml.xpath("//job/notify").should be_empty
    end

    it "contains the correct content to represent each video output item" do
      xml.xpath("//job/outputs/output/video/media/medium").length.should == 2
    end

    it "has the correct video output destination" do
      xml.xpath("//job/outputs/output/video/destination").text.should == "http://whatever.com/foo1.mp4"
    end

    it "has the correct video output container" do
      xml.xpath("//job/outputs/output/video/container").text.should == "mpeg4"
    end

    it "contains the correct content to represent the video captures" do
      xml.xpath("//job/outputs/output/capture").length.should == 2
    end
  end
end
