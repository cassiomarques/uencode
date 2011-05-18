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
    let(:job) { UEncode::Job.new :source => "http://dailydigital-files.s3.amazonaws.com/staging/3/iphone.mp4", :userdata => "This is a simple test" }
    let(:request) { UEncode::Request.new job }

    before :each do
      job.configure_video_output do |c| 
        c.destination = "http://dailydigital-files.s3.amazonaws.com/staging/3/iphone_transcoded.mp4"
        c.container   = "mpeg4"
      end
      video1 = UEncode::Medium.new
      video1.configure_video { |c| c.bitrate = 300000; c.codec = "h264"}
      video1.configure_audio do |c| 
        c.bitrate    = 64000
        c.codec      = "aac"
        c.samplerate = 44100
        c.channels   = 1
      end
      job << video1
    end

    around :each do |example|
      VCR.use_cassette "job_with_one_video_and_no_capture", &example
    end

    it "returns a response containing the jobid" do
      request.send.jobid.should =~ /\A\d+\z/
    end

    it "returns a response containing a code" do
      request.send.code.should == 'Ok'
    end

    it "returns a response containing the previously sent user data" do
      request.send.userdata.should == "This is a simple test"
    end

    it "returns a response containing a message" do
      request.send.message.should == "You job was created successfully."
    end
  end
end
