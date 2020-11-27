require 'pathname'

require 'interop/error'
require 'interop/version'
require 'interop/connection'
require 'interop/pipe'
require 'interop/interceptor'
require 'interop/middleware'
require 'interop/rpc/client'
require 'interop/rpc/server'

module Hx
  module Interop
    ROOT = Pathname(__dir__).parent
  end
end
