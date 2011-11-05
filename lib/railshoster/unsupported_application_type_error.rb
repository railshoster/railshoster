module Railshoster  
  class UnsupportedApplicationTypeError < StandardError
    include Railshoster::Error
  end  
end