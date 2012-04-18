module Railshoster
  class NoSshKeyGivenError < ArgumentError
    include Railshoster::Error
  end
end