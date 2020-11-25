require 'pathname'

require 'interop/error'
require 'interop/version'
require 'interop/connection'
require 'interop/pipe'

module Hx
  module Interop
    ROOT = Pathname(__dir__).parent
  end
end
