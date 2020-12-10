<?php

namespace Hx\Interop;

use Hx\Interop\Error\InvalidHeader;
use PHPUnit\Framework\TestCase;

class HeaderTest extends TestCase {
    public function testParse() {
        $actual = Header::parse("content-LENGTH: 45\n");
        $this->assertInstanceOf(Header::class, $actual);
    }

    public function testParseFailure() {
        $this->expectException(InvalidHeader::class);
        Header::parse('I am not a header');
    }

    public function testToString() {
        $header = new Header('i-am-a', 'header');
        $this->assertEquals("I-Am-A: header\n", strval($header));
    }
}
