module Railshoster
  class BadApplicationJSONHashError < ArgumentError
    include Railshoster::Error
  end
end
