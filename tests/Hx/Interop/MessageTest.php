<?php

namespace Hx\Interop;

use JsonException;
use PHPUnit\Framework\TestCase;
use stdClass;

class MessageTest extends TestCase {
    public function testJson() {
        $thing = [
            'a' => 'ü',
            'b' => false
        ];
        $message = Message::json($thing, ['hello' => 'buddy']);
        $this->assertEquals('{"a":"ü","b":false}'."\n", $message->body);
        $this->assertCount(3, $message->headers);
        $this->assertEquals('application/json', $message[Header::CONTENT_TYPE]);
        $this->assertEquals('21', $message[Header::CONTENT_LENGTH]);
        $this->assertEquals('buddy', $message['HELLO']);
    }

    public function testBadJson() {
        $this->expectException(JsonException::class);
        $thing = new stdClass();
        $thing->ohno = $thing;
        Message::json($thing);
    }
}
