module Uencode
  class Response
    ATTRIBUTES = [:code, :message, :jobid, :userdata]

    include AttrSetting    
  end
end
