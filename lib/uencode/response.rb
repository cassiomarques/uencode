module UEncode
  class Response
    class BadRequestError < StandardError; end
    class InvalidKeyError < StandardError; end
    class NotActiveError  < StandardError; end
    class ServerError     < StandardError; end
    class UnknownError    < StandardError; end

    ATTRIBUTES = [:status, :message, :job_key, :userdata]

    include AttrSetting    

    def initialize(options)
      check_response_status options[:status], options[:message]
      super
    end

    private
    def check_response_status(status, message)
      return if status == 'Ok'
      case status
      when 'BadRequest'; raise BadRequestError, message
      when 'InvalidKey'; raise InvalidKeyError, message
      when 'NotActive'; raise NotActiveError, message
      when 'ServerError'; raise ServerError, message
      else raise UnknownError, "#{status}: #{message}"
      end
    end
  end
end
