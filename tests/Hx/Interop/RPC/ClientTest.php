<?php

namespace Hx\Interop\RPC;

use Hx\Interop\Buffer;
use Hx\Interop\Conn;
use Hx\Interop\Message;
use PHPUnit\Framework\TestCase;

class ClientTest extends TestCase {
    public function testWait() {
        $out = new Buffer(<<<TEXT
Interop-Rpc-Class: x

I am X

Interop-Rpc-Class: y

I am Y


TEXT
        );
        $client = new Client(Conn::build($out, new Buffer()));
        $events = [];
        $client
            ->on('x', function ($message) use (&$events) {
                $events['x'] = $message;
            })
            ->on('y', function ($message) use (&$events) {
                $events['y'] = $message;
            });
        $client->wait();
        $this->assertCount(2, $events);
        $this->assertEquals("I am X\n", $events['x']->body);
        $this->assertEquals("I am Y\n", $events['y']->body);
    }

    public function testCallSync() {
        $out = new Buffer("Interop-Rpc-Id: 1\n\npong\n\n");
        $client = new Client(Conn::build($out, new Buffer()));
        $result = $client->call('ping');
        $this->assertInstanceOf(Message::class, $result);
        $this->assertEquals("pong\n", $result->body);
    }

    public function testCallAsync() {
        $out = new Buffer("Interop-Rpc-Id: 1\n\npong\n\n");
        $client = new Client(Conn::build($out, new Buffer()));
        $result = null;
        $this->assertNull($client->call('ping', function($message) use(&$result) {
            $result = $message;
        }));
        $client->wait();
        $this->assertInstanceOf(Message::class, $result);
        $this->assertEquals("pong\n", $result->body);
    }
}
