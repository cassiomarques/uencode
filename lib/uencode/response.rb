module UEncode
  class Response
    class BadRequestError < StandardError; end
    class InvalidKeyError < StandardError; end
    class NotActiveError  < StandardError; end
    class ServerError     < StandardError; end
    class UnknownError    < StandardError; end

    ATTRIBUTES = [:code, :message, :jobid, :userdata]

    include AttrSetting    

    def initialize(options)
      check_response_code options[:code], options[:message]
      super
    end

    private
    def check_response_code(code, message)
      return if code == 'Ok'
      case code
      when 'BadRequest'; raise BadRequestError, message
      when 'InvalidKey'; raise InvalidKeyError, message
      when 'NotActive'; raise NotActiveError, message
      when 'ServerError'; raise ServerError, message
      else raise UnknownError, "#{code}: #{message}"
      end
    end
  end
end
