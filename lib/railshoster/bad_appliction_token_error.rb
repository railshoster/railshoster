module Railshoster
  class BadApplicationTokenError < ArgumentError
    include Railshoster::Error
  end
end
