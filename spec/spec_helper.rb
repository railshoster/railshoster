require 'rspec'

require 'fakefs/safe'
require 'fakefs/spec_helpers'

# https://github.com/defunkt/fakefs
# Turn FakeFS on and off in a given example group
# describe "my spec" do
#  include FakeFS::SpecHelpers
# end

require File.join(File.dirname(__FILE__), '..', 'lib', 'railshoster')

RSpec.configure do |c|
  c.mock_with :mocha
end
