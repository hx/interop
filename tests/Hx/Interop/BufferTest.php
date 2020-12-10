<?php

namespace Hx\Interop;

use Hx\Interop\Error\AlreadyClosed;
use PHPUnit\Framework\TestCase;

class BufferTest extends TestCase {
    public function testReadBytes() {
        $buf = new Buffer('123456789');
        $this->assertEquals('123', $buf->readBytes(3));
        $this->assertEquals('4567', $buf->readBytes(4));
        $this->expectException(EOF::class);
        $buf->readBytes(3);
    }

    public function testReadUntil() {
        $buf = new Buffer("foo\nbar\n\n");
        $this->assertEquals("foo\n", $buf->readUntil("\n"));
        $this->assertEquals("bar\n", $buf->readUntil("\n"));
        $this->assertEquals("\n", $buf->readUntil("\n"));
        $this->expectException(EOF::class);
        $buf->readUntil("\n");
    }

    public function testWriteBytes() {
        $buf = new Buffer();
        $buf->writeBytes('123');
        $buf->writeBytes('456');
        $this->assertEquals('123456', strval($buf));
        $buf->close();
        $this->expectException(AlreadyClosed::class);
        $buf->writeBytes('789');
    }
}
