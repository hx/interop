<?php

namespace Hx\Interop;

use Hx\Interop\Error\AlreadyClosed;
use PHPUnit\Framework\TestCase;

class ByteStreamWriterTest extends TestCase {
    public function testWriteBytes() {
        $fp = fopen('php://memory', 'r+');
        try {
            $writer = new ByteStreamWriter($fp);
            $writer->writeBytes('foo');
            $writer->writeBytes('bar');
            rewind($fp);
            $this->assertEquals('foobar', stream_get_contents($fp));
        } finally {
            fclose($fp);
        }

        $this->expectException(AlreadyClosed::class);
        $writer->writeBytes('baz');
    }
}
