<?php

namespace Hx\Interop;

use PHPUnit\Framework\TestCase;
use TypeError;

class ConnTest extends TestCase {
    public function testBuildFromBuffer() {
        $in = new Buffer("Content-Length: 0\n\n\n");
        $out = fopen('php://memory', 'r+');
        try {
            $conn = Conn::build($in, $out);

            $message = $conn->read();
            $this->assertEquals('0', $message[Header::CONTENT_LENGTH]);
            $this->assertEquals('', $message->body);

            $conn->write($message);
            rewind($out);
            $this->assertEquals("Content-Length: 0\n\n\n", stream_get_contents($out));
        } finally {
            fclose($out);
        }
    }

    public function testBadBuild() {
        $this->expectException(TypeError::class);
        Conn::build('not', 'right');
    }
}
