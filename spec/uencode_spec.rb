$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'spec_helper'

describe Uencode do
  it "has a customer_key configuration parameter" do
    Uencode.configure do |c|
      c.customer_key = "1234567890"
    end
    Uencode.customer_key.should == "1234567890"
  end
end

describe Uencode::VideoOutput do
  subject { described_class.new :destination => "http://foobar.com/bla.avi", :container => "mpeg4" }

  its(:destination) { should == "http://foobar.com/bla.avi" }
  its(:container) { should == "mpeg4" }
    
  describe "#configure_video" do
    let(:video_output) { Uencode::VideoOutput.new :container => "mpeg4" }

    before :each do
      video_output.configure_video do |c|
        c.bitrate           = 10000
        c.codec             = "mp4"
        c.cbr               = false
        c.crop              = nil
        c.deinterlace       = true
        c.framerate         = Uencode::FrameRate.new :numerator => 1000, :denominator => 1001
        c.height            = 500
        c.keyframe_interval = 0
        c.maxbitrate        = 10000
        c.par               = nil
        c.profile           = "baseline"
        c.passes            = 1
        c.stretch           = false
        c.width             = 400
      end
    end

    it { video_output.video_config.bitrate.should == 10000 }
    it { video_output.video_config.codec.should == "mp4" }
    it { video_output.video_config.cbr.should == false }
    it { video_output.video_config.crop.should be_nil }
    it { video_output.video_config.deinterlace.should == true }
    it { video_output.video_config.framerate.numerator.should == 1000 }
    it { video_output.video_config.height.should == 500 }
    it { video_output.video_config.keyframe_interval.should == 0 }
    it { video_output.video_config.maxbitrate.should == 10000 }
    it { video_output.video_config.par.should be_nil }
    it { video_output.video_config.profile.should == "baseline" }
    it { video_output.video_config.passes.should == 1 }
    it { video_output.video_config.stretch.should == false }
    it { video_output.video_config.width.should == 400 }
  end

  describe "#configure_audio" do
    let(:video_output) { Uencode::VideoOutput.new :container => "mpeg4" }

    before :each do
      video_output.configure_audio do |c|
        c.codec      = "aac"
        c.bitrate    = 15000
        c.channels   = 2
        c.samplerate = 10000
      end
    end

    it { video_output.audio_config.codec.should == "aac" }
    it { video_output.audio_config.bitrate.should == 15000 }
    it { video_output.audio_config.channels.should == 2 }
    it { video_output.audio_config.samplerate.should == 10000 }
  end

  context "video config default values" do
    let(:video_output) { Uencode::VideoOutput.new :container => "mpeg4" }

    it { video_output.video_config.cbr.should == false }
    it { video_output.video_config.deinterlace.should == false }
    it { video_output.video_config.profile.should == "main" }
    it { video_output.video_config.passes.should == 1 }
    it { video_output.video_config.stretch.should == false }
  end
end

describe Uencode::CaptureOutput do
  subject { described_class.new({
    :destination => "http://whatever.com/foo.jpg",
    :rate => "at 20s",
    :stretch => false
  }) }

  its(:destination) { should == "http://whatever.com/foo.jpg" }
  its(:rate) { should == "at 20s" }
  its(:stretch) { should == false }
end

describe Uencode::Crop do
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
    
    it "has a root element named 'framerate'" do
      xml.root.name.should == 'framerate'
    end

    it "has the correct value for the numerator attribute" do
      xml.xpath("//numerator").text.should == numerator.to_s
    end

    it "has the correct value for the denominator attribute" do
      xml.xpath("//denominator").text.should == denominator.to_s
    end
  end  
end

describe Uencode::FrameRate do
  let(:numerator) { 1000 }
  let(:denominator) { 1001 }

  it_should_behave_like "an element that represents a rate number"
end

describe Uencode::Par do
  let(:numerator) { 10 }
  let(:denominator) { 11 }

  it_should_behave_like "an element that represents a rate number"
end

describe Uencode::Job do
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

end
