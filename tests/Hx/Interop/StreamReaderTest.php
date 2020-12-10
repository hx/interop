<?php

namespace Hx\Interop;

use PHPUnit\Framework\TestCase;

class StreamReaderTest extends TestCase {
    public function testRead() {
        $source = <<<TEXT
Foo: bar
other-foo: baz

Howdy!

Content-length: 3

OMG
Content-Length: 2

Hi

TEXT;
        $reader = new StreamReader(new Buffer($source));

        $message = $reader->read();
        $this->assertCount(2, $message->headers);
        $this->assertEquals('bar', $message['foo']);
        $this->assertEquals('baz', $message['Other-Foo']);
        $this->assertEquals("Howdy!\n", $message->body);

        $message = $reader->read();
        $this->assertEquals('OMG', $message->body);

        $message = $reader->read();
        $this->assertEquals('Hi', $message->body);

        $this->expectException(EOF::class);
        $reader->read();
    }
}
