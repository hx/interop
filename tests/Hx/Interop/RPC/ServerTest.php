<?php

use Hx\Interop\Buffer;
use Hx\Interop\Message;
use Hx\Interop\RPC\Server;
use PHPUnit\Framework\TestCase;

class ServerTest extends TestCase {
    public function testSend() {
        $out = new Buffer();
        $server = new Server(new Buffer(), $out);
        $server->send('foo', Message::json(123));
        $server->wait();
        $this->assertEquals(
            "Interop-Rpc-Class: foo\nContent-Type: application/json\nContent-Length: 4\n\n123\n\n",
            (string) $out
        );
    }
}
