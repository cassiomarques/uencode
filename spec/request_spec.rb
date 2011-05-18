require 'spec_helper'

describe Uencode::Request do
  context "being created" do
    let(:job) { Uencode::Job.new :source => "http://whatever.com/foo/avi" }
    let(:request) { Uencode::Request.new job }

    it "initializes the job attribute" do
      request.instance_variable_get(:@job).should == job
    end
  end

  describe "#send" do
    it "raises an error when the response code is not 'OK'" do
      fail 'implement this!'
    end
  end


end
