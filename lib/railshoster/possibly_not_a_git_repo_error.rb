module Railshoster
  class PossiblyNotAGitRepoError < ArgumentError
    include Railshoster::Error
  end
end