require 'interop'

reader = File.open('a', 'r')
writer = File.open('b', 'w')

server = Hx::Interop::RPC::Server.new(reader, writer)

server.on 'countdown' do |request|
  request['ticks'].to_i.times do |i|
    sleep 1
    server.send 'tick', Hx::Interop::ContentType::JSON.encode(i + 1)
  end
  nil
end

server.wait
