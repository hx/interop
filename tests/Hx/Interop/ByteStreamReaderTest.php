<?php

namespace Hx\Interop;

use PHPUnit\Framework\TestCase;

class ByteStreamReaderTest extends TestCase {
    public function testReadBytes() {
        $fp = $this->memoryStream('123456789');
        try {
            $reader = new ByteStreamReader($fp);
            $this->assertEquals('123', $reader->readBytes(3));
            $this->assertEquals('4567', $reader->readBytes(4));

            $this->expectException(EOF::class);
            $reader->readBytes(3);
        } finally {
            fclose($fp);
        }
    }

    public function testReadUntil() {
        $fp = $this->memoryStream('123456789');
        try {
            $reader = new ByteStreamReader($fp);
            $this->assertEquals('123', $reader->readUntil('3'));
            $this->assertEquals('4567', $reader->readUntil('67'));

            $this->expectException(EOF::class);
            $reader->readUntil('@');
        } finally {
            fclose($fp);
        }
    }

    private function memoryStream(string $contents = '') {
        $fp = fopen('php://memory', 'r+');
        fwrite($fp, $contents);
        rewind($fp);
        return $fp;
    }
}
