$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'singleton'
require 'nokogiri'
require 'httparty'

module UEncode
  class << self
    attr_accessor :customer_key

    def configure
      yield self
    end
  end

  module AttrSetting
    def set_attributes(options)
      self.class.const_get("ATTRIBUTES").each { |attr| instance_variable_set(:"@#{attr}", options[attr]) }
    end

    def initialize(options)
      set_attributes options
    end

    def self.included(klass)
      attr = klass.const_get "ATTRIBUTES"
      klass.send(:attr_reader, *attr)
    end
  end
end

require "uencode/elements"
require "uencode/request"
require "uencode/response"
