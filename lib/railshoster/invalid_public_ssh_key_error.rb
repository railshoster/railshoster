module Railshoster
  class InvalidPublicSshKeyError < ArgumentError
    include Railshoster::Error
  end
end