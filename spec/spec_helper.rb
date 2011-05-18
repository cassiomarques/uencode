require 'uencode'
require 'rspec'
require 'rspec/autorun'
require "vcr"


VCR.config do |c|
  library_dir = File.join(File.dirname(__FILE__), 'fixtures/')
  c.cassette_library_dir = library_dir
  c.stub_with :webmock
  c.allow_http_connections_when_no_cassette = false
  c.ignore_localhost = true
end

UEncode.configure do |c|
  c.customer_key = "1q2w3e4r5t"
end
