# Interop

Layers of simple inter-process messaging goodness.

The Golang implementation is the reference for the other implementations.

## Protocol

Interop relies on the exchange of messages between processes. Messages are comprised of MIME-style headers, and bodies.

```plain
Content-Type: application/json
Content-Length: 14

{"foo":"bar"}
```

All headers are optional. A double line-break serves as a message terminator in the absense of a `Content-Length` header.

### RPC

In a client/server pairing, a client process can make an RPC request using an ID and a Class. IDs should be unique per session. Clients are responsible for generating IDs. Classes should tell servers how to handle requests.


```plain
Interop-Rpc-Class: ping
Interop-Rpc-Id: 1

Are you there?
```

The server should send a response with the same ID header.

```plain
Interop-Rpc-Id: 1

Yes I am!
```

Servers may send other messages before sending a response (including events and/or responses to other requests), so clients should wait for a message with the same ID.

Servers may send events to clients at any time. An event is simply a message without an ID. Events should have class headers that inform clients how they are to be handled.

## Implementation principles

### Messages

The base type in each language is a `Message`, which should have `headers` and a `body`.

Headers are collections of MIME headers. They should be used in a case-insensitive way.

Bodies are raw binary, and therefore suitable for transmission of compressed data, video streams, etc.

### Readers/Writers

Each language has reader and writer interfaces, which wrap around native IO primitives to allow reading/writing messages directly to/from files (e.g. STDIN/STDOUT), sockets, pipes, buffers, etc.

### Connections

A connection is the combination of a reader and a writer, and should represent a process's bidirectional interface; for example, STDIO, a TCP socket, or pipes into a subprocess.

### Pipes

A pipe simple allows you to read whatever messages are written to it. Pipes can block or have buffers, depending on implementation.

### Closing up

Readers, writers, and connections generally can't be closed directly. Their underlying IO streams should be closed instead.

Pipes, however, do not represent IO primitives, and so can be closed directly.

### RPC

RPC servers and clients wrap around connections to provide core RPC (or any other request-response) functionality.

Clients can augment regular messages with the ID and Class headers required for RPC, and wait for servers to send responses to them, matching responses with requests by ID. Clients can also listen for specific classes of event send by servers, running handlers for them.

Servers can be configured to respond to specific classes of messages with different handlers, allowing responses to be seamlessly returned to clients.

Because clients and servers are both "listening" (clients for events, and servers for requests), they have blocking behaviours that are managed differently depending on available tooling. In most cases a process will be able to wait for a client or server to close or error out.

### Concurrency/parallelism

Readers and writers use mutexes to ensure they are only reading or writing one message at a time, regardless of how many threads are accessing them. As such, operations involving the movement of messages are generally thread-safe.

Client event handlers and server request handlers are generally processed asynchronously wherever possible, to minimise blocking on IO streams.

## Examples

In the below examples, each language implements the same client/server combination.

Client and server processes talk to each other using two FIFOs called `a` and `b`. Clients write to `a` and read from `b`, and servers write to `b` and read from `a`.

Clients send a single RPC request, `countdown`, to servers, with a single header, `ticks`, as an integer. Servers respond to `countdown` by sending one `tick` event per second back to the client, up to the number in the request's `ticks` header.

Clients handle the `tick` event by writing `Tick _n_` to their STDOUT. After receiving their final tick, they close FIFO `a`, which causes the server to exit, which in turn causes the client to exit.

These examples are all runnable from the [/examples](examples) directory.

### Golang

#### Server

```go
import (
	"github.com/hx/interop/interop"
	"os"
	"strconv"
	"time"
)

func main() {
	reader, _ := os.OpenFile("a", os.O_RDONLY, 0)
	writer, _ := os.OpenFile("b", os.O_WRONLY|os.O_SYNC, 0)

	server := interop.NewRpcServer(interop.BuildConn(reader, writer))

	server.HandleClassName("countdown", interop.ResponderFunc(func(request interop.Message, _ *interop.MessageBuilder) {
		num, _ := strconv.Atoi(request.GetHeader("ticks"))
		for i := 1; i <= num; i++ {
			time.Sleep(time.Second)
			event := interop.NewRpcMessage("tick")
			event.SetContent(interop.ContentTypeJSON, i)
			server.Send(event)
		}
	}))

	server.Run()
}
```

#### Client

```go
import (
	"fmt"
	"github.com/hx/interop/interop"
	"os"
)

func main() {
	writer, _ := os.OpenFile("a", os.O_WRONLY|os.O_SYNC, 0)
	reader, _ := os.OpenFile("b", os.O_RDONLY, 0)

	client := interop.NewRpcClient(interop.BuildConn(reader, writer))

	client.Events.HandleClassName("tick", interop.HandlerFunc(func(event interop.Message) error {
		i := 0
		interop.ContentTypeJSON.DecodeTo(event, &i)
		fmt.Println("Tick", i)
		if i == 5 {
			writer.Close()
		}
		return nil
	}))

	client.Start()

	client.Send(interop.NewRpcMessage("countdown").AddHeader("ticks", "5"))

	client.Wait()
}
```

### Ruby

#### Server

```ruby
require 'interop'

reader = File.open('a', 'r')
writer = File.open('b', 'w')

writer.sync = true

server = Hx::Interop::RPC::Server.new(reader, writer)

server.on 'countdown' do |request|
  request['ticks'].to_i.times do |i|
    sleep 1
    server.send 'tick', Hx::Interop::ContentType::JSON.encode(i + 1)
  end
  nil
end

server.wait
```

#### Client

```ruby
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
```

### PHP

#### Server

```php
$reader = fopen('a', 'r');
$writer = fopen('b', 'w');

$server = new Hx\Interop\RPC\Server($reader, $writer);

$server->on('countdown', function (Hx\Interop\Message $message) use($server) {
    $num = (int) $message['ticks'];
    for ($i = 1; $i <= $num; $i++) {
        sleep(1);
        $server->send('tick', $i);
    }
});

$server->wait();
```

#### Client

```php
$writer = fopen('a', 'w');
$reader = fopen('b', 'r');

$client = new Hx\Interop\RPC\Client($reader, $writer);

$client->on('tick', function (Hx\Interop\Message $message) use ($writer) {
    echo "Tick $message->body\n";
    if ($message->body == 5) {
        fclose($writer);
    }
});

$client->call('countdown', ['ticks' => 5]);

$client->wait();
```

### JavaScript

> TODO
