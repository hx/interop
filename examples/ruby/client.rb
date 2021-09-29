require 'interop'

writer = File.open('a', 'w')
reader = File.open('b', 'r')

writer.sync = true

client = Hx::Interop::RPC::Client.new(reader, writer)

client.on 'tick' do |event|
  i = event.decode
  puts "Tick #{i}"
  writer.close if i == 5
end

client.call :countdown, ticks: 5

client.wait
