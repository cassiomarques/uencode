# UEncode

A simple Ruby gem to consume the [uEncode](http://www.uencode.com) API.

## Synopsis

``` ruby
require 'uencode'

# In Rails you can put this inside an initializer
UEncode.configure do |c|
  c.customer_key = "your_uencode_api_key"
end

job = UEncode::Job.new :source => "http://your_source_video_url/foo.avi", :userdata => "This is a simple test"

job.configure_video_output { |c| c.destination = "http://your_destination_url/transcoded.mp4"; c.container = "mpeg4" }

video = UEncode::Medium.new

video.configure_video { |c| c.bitrate = 300000; c.codec = "h264"}

video.configure_audio do |c| 
  c.bitrate    = 64000
  c.codec      = "aac"
  c.samplerate = 44100
  c.channels   = 1
end

job << video

capture = UEncode::CaptureOutput.new :destination => "http://whatever.com/foo.zip", :rate => "every 30s"
job.add_capture capture

request = UEncode::Request.new job
puts job.to_xml
response = request.send

puts response.code # => 'Ok'
puts response.message # => 'Your job was created successfully'
puts response.jobid # => 1234567
puts response.userdata # => 'This is a simple test'
```

## Accepted parameters

Currently all the uEncode API parameters are supported (or so I think :)

Currently the gem does not validate parameters' values, so pay attention at the API docs.

You can see the whole list of accepted parameters in the [uEncode API documentation](http://www.uencode.com/api/300#response_codes).

For the UEncode classes that map to each complex API parameters (like Crop, Size, FrameRate, etc) take a look at the spec file at /spec/elements_spec.rb or read the docs.

## Running the specs

* bundle install
* rspec spec


