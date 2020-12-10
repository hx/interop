<?php

namespace Hx\Interop;

use PHPUnit\Framework\TestCase;

class StreamWriterTest extends TestCase {
    public function testWrite() {
        $buf = new Buffer();
        $writer = new StreamWriter($buf);
        $message = new Message(['foo' => 'bar'], 'baz');
        $writer->write($message);
        $this->assertEquals("Foo: bar\n\nbaz\n", strval($buf));
    }
}
