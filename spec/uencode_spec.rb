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

