require 'uencode'
require 'rspec'
require 'rspec/autorun'
require "vcr"


VCR.config do |c|
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures')
  c.stub_with :webmock
  c.allow_http_connections_when_no_cassette = false
  c.ignore_localhost = true
end

Uencode.configure do |c|
  c.customer_key = "1234567890"
end
