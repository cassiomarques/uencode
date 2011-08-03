require 'spec_helper'

describe UEncode::Callback do
  let(:xml) {
    %Q{
<?xml version="1.0"?>
<callback>
  <key>68074e2a55912eb4fb092bc6668e6ce3</key>
  <status>Warning</status>
  <userdata>This is a simple test</userdata>
  <started>2011-08-02T16:44:06+00:00</started>
  <completed>2011-08-02T16:46:15+00:00</completed>
  <outputs>
    <capture>
      <key>3689bc85c85a89d8d071d0893d00f585</key>
      <destination>dailydigital-files.s3.amazonaws.com/staging/3/iphone_capture.jpg</destination>
      <status>Error</status>
      <error_message>Error transferring output</error_message>
      <started>2011-08-02T16:44:58+00:00</started>
      <completed>2011-08-02T16:45:11+00:00</completed>
    </capture>
    <video>
      <key>6d1a4d9f5b84b2df240faf1dced389c7</key>
      <destination>dailydigital-files.s3.amazonaws.com/staging/3/iphone_transcoded.mp4</destination>
      <status>Ok</status>
      <bytes>412431</bytes>
      <started>2011-08-02T16:45:02+00:00</started>
      <completed>2011-08-02T16:45:20+00:00</completed>
      <fps/>
    </video>
  </outputs>
</callback>
  }
  }

  subject { UEncode::Callback.new xml }

  its(:key) { should == "68074e2a55912eb4fb092bc6668e6ce3" }
  its(:status) { should == "Warning" }
  its(:userdata) { should == "This is a simple test" }
  its(:started) { should == Date.parse("2011-08-02T16:44:06+00:00") }
  its(:completed) { should == Date.parse("2011-08-02T16:46:15+00:00") }

  describe "#videos" do
    context "video output" do
      subject { UEncode::Callback.new(xml).videos.first }
    
      its(:key) { should == "6d1a4d9f5b84b2df240faf1dced389c7" }
      its(:destination) { should == "dailydigital-files.s3.amazonaws.com/staging/3/iphone_transcoded.mp4" }
      its(:status) { should == "Ok" }
      its(:bytes) { should == 412431 }
      its(:started) { should == Date.parse("2011-08-02T16:45:02+00:00") }
      its(:completed) { should == Date.parse("2011-08-02T16:45:20+00:00") }
    end
  end

  describe "#captures" do
    context "capture output" do
      subject { UEncode::Callback.new(xml).captures.first }

      its(:key) { should == "3689bc85c85a89d8d071d0893d00f585" }
      its(:destination) { should == "dailydigital-files.s3.amazonaws.com/staging/3/iphone_capture.jpg" }
      its(:status) { should == "Error" }
      its(:error_message) { should == "Error transferring output" }
      its(:started) { should == Date.parse("2011-08-02T16:44:58+00:00") }
      its(:completed) { should == Date.parse("2011-08-02T16:45:11+00:00") }      
    end
  end
end
