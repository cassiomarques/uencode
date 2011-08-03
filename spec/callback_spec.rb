require 'spec_helper'

describe UEncode::Callback do
  let(:hash) { {
    "key"=>"68074e2a55912eb4fb092bc6668e6ce3",
    "status"=>"Warning",
    "userdata"=>"39",
    "started"=>"2011-08-03T14:54:59+00:00",
    "completed"=>"2011-08-03T14:57:26+00:00",
    "outputs"=>{
      "capture"=>{
        "key"=>"51c505b08854c5600c3397da5fd7c4c2",
        "destination"=>"dailydigital-files.s3.amazonaws.com/staging/3/iphone_capture.jpg",
        "status"=>"Error",
        "error_message" => "Error transferring output",
        "bytes"=>"54137",
        "started"=>"2011-08-02T16:44:58+00:00",
        "completed"=>"2011-08-02T16:45:11+00:00"
      },
      "video"=>{
        "key"=>"6d1a4d9f5b84b2df240faf1dced389c7",
        "destination"=>"dailydigital-files.s3.amazonaws.com/staging/3/iphone_transcoded.mp4",
        "status"=>"Ok",
        "bytes"=>"412431",
        "started"=>"2011-08-03T14:55:12+00:00",
        "completed"=>"2011-08-03T14:55:24+00:00",
        "fps"=>nil
      }
    }
  }}

  subject { UEncode::Callback.new hash}

  its(:key) { should == "68074e2a55912eb4fb092bc6668e6ce3" }
  its(:status) { should == "Warning" }
  its(:userdata) { should == "39" }
  its(:started) { should == DateTime.parse("2011-08-03T14:54:59+00:00") }
  its(:completed) { should == DateTime.parse("2011-08-03T14:57:26+00:00") }

  describe "#videos" do
    context "video output" do
      subject { UEncode::Callback.new(hash).videos.first }

      its(:key) { should == "6d1a4d9f5b84b2df240faf1dced389c7" }
      its(:destination) { should == "dailydigital-files.s3.amazonaws.com/staging/3/iphone_transcoded.mp4" }
      its(:status) { should == "Ok" }
      its(:bytes) { should == 412431 }
      its(:started) { should == DateTime.parse("2011-08-03T14:55:12+00:00") }
      its(:completed) { should == DateTime.parse("2011-08-03T14:55:24+00:00") }
    end
  end

  describe "#captures" do
    context "capture output" do
      subject { UEncode::Callback.new(hash).captures.first }

      its(:key) { should == "51c505b08854c5600c3397da5fd7c4c2" }
      its(:destination) { should == "dailydigital-files.s3.amazonaws.com/staging/3/iphone_capture.jpg" }
      its(:status) { should == "Error" }
      its(:error_message) { should == "Error transferring output" }
      its(:started) { should == DateTime.parse("2011-08-02T16:44:58+00:00") }
      its(:completed) { should == DateTime.parse("2011-08-02T16:45:11+00:00") }
    end
  end
end
