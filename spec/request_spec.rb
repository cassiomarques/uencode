require 'spec_helper'

describe UEncode::Request do
  context "being created" do
    let(:job) { UEncode::Job.new :source => "http://whatever.com/foo/avi" }
    let(:request) { UEncode::Request.new job }

    it "initializes the job attribute" do
      request.instance_variable_get(:@job).should == job
    end
  end

  describe "#send" do
    let(:job) { UEncode::Job.new :source => "http://dailydigital-files.s3.amazonaws.com/staging/3/iphone.mp4", :userdata => "This is a simple test", :callback => "cassiomarques@dailydigital.com" }
    let(:request) { UEncode::Request.new job }

    before :each do
      video1 = UEncode::Video.new(
        :destination => "http://dailydigital-files.s3.amazonaws.com/staging/3/iphone_transcoded.mp4",
        :container   => "mpeg4"
      )
      video1.configure_video { |c| 
        c.bitrate = 300000
        c.codec = "h264"
        c.size       = UEncode::Size.new(:width => 640, :height => 480)        
      }
      video1.configure_audio do |c| 
        c.bitrate    = 64000
        c.codec      = "aac"
        c.samplerate = 44100
        c.channels   = 1
      end
      job << video1
      capture = UEncode::Capture.new(
        :destination => "http://dailydigital-files.s3.amazonaws.com/staging/3/iphone_capture.jpg",
        :rate        => "at 60s",
        :size        => UEncode::Size.new(:width => 640, :height => 480)
      )
      job << capture
    end

    around :each do |example|
      VCR.use_cassette "job_with_one_video_and_no_capture", &example
    end

    it "returns a response containing the key for the transcoding job" do
      request.send.job_key.should == "68074e2a55912eb4fb092bc6668e6ce3"
    end

    it "returns a response containing the status for the job" do
      request.send.status.should == 'Ok'
    end

    it "returns a response containing the previously sent user data" do
      request.send.userdata.should == "This is a simple test"
    end
  end
end
