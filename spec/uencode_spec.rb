$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'spec_helper'

describe UEncode do
  it "has a customer_key configuration parameter" do
    UEncode.configure do |c|
      c.customer_key = "1234567890"
    end
    UEncode.customer_key.should == "1234567890"
  end
end

