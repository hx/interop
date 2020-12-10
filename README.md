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

Pipes, however, do not represent IO primitates, and so can be closed directly.

### RPC

RPC servers and clients wrap around connections to provide core RPC (or any other request-response) functionality.

Clients can augment regular messages with the ID and Class headers required for RPC, and wait for servers to send responses to them, matching responses with requests by ID. Clients can also listen for specific classes of event send by servers, running handlers for them.

Servers can be configured to respond to specific classes of messages with different handlers, allowing responses to be seamlessly returned to clients.

Because clients and servers are both "listening" (clients for events, and servers for requests), they have blocking behaviours that are managed differently depending on available tooling. In most cases a process will be able to wait for a client or server to close or error out.

### Concurrency/parallelism

Readers and writers use mutexes to ensure they are only reading or writing one message at a time, regardless of how many threads are accessing them. As such, operations involving the movement of messages are generally thread-safe.

Client event handlers and server request handlers are generally processed asynchronously wherever possible, to minimise blocking on IO streams.

## Implementations

### Golang

TODO

### Ruby

TODO

### PHP

TODO
