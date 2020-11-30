require 'bundler'

Bundler.setup

require 'pathname'
require 'open3'
require 'json'

require 'interop'

include Hx::Interop

args = ARGV.dup
main = false

if args.first == '--main'
  args.shift
  main = true
end

layer_name = args.shift

sequence = []
rec      = -> *things { sequence << [layer_name, *things].join(' ') }

if args.any?
  i, o     = Open3.popen2(*args)
  upstream = Connection.build(o, i)
  close    = i.method(:close)
else
  upstream = Pipe.new(1)
  close    = upstream.method(:close)
end

client = RPC::Client.new(upstream)

client.on :finishing do |event|
  rec.call 'handle', event[:layer_name]
end

run = lambda do
  rec.call 'calling'
  sequence << client.call(:dig, Message.json(["#{layer_name} called"])).decode
end

rec.call 'init'

if main
  run.call
else
  $stdout.sync = true
  server       = RPC::Server.new($stdin, $stdout)
  server.on :dig do |request|
    sequence.concat request.decode
    rec.call 'dig'
    run.call
    rec.call 'trigger'
    server.send :finishing, layer_name: layer_name
    Message.json sequence
  end
  server.wait
end

close.call
client.wait

puts JSON.pretty_generate(sequence) if main
