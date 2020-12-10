<?php

namespace Hx\Interop;

use PHPUnit\Framework\TestCase;

class HeadersTest extends TestCase {
    public function testParse() {
        $input = [
            "foo-bar: baz\n",
            'x:y'
        ];
        $actual = Headers::parse($input);
        $this->assertCount(2, $actual);
        $this->assertEquals('baz', $actual['foo-bar']);
        $this->assertEquals('y', $actual['X']);
    }

    public function testOffsetSet() {
        $h = new Headers();
        $h['foo'] = 'baz';
        $h['foo'] = 'bar';
        $this->assertEquals('bar', $h['foo']);
        $this->assertEquals('bar', $h['FOO']);
    }

    public function testAdd() {
        $h = new Headers();
        $h['foo'] = 'bar';
        $h->add('FOO', 'baz');
        $this->assertCount(2, $h);
    }

    public function testIterate() {
        $h = new Headers();
        $h['foo'] = 'baz';
        $h['foo'] = 'bar';
        $h->add('FOO', 'baz');
        $h['bar'] = 'quux';

        $objects = [];
        foreach($h as $obj) {
            $objects[] = $obj;
        }

        $this->assertCount(3, $objects);
        $this->assertEquals('Foo', $objects[0]->name());
        $this->assertEquals('bar', $objects[0]->value());
        $this->assertEquals('Foo', $objects[1]->name());
        $this->assertEquals('baz', $objects[1]->value());
        $this->assertEquals('Bar', $objects[2]->name());
        $this->assertEquals('quux', $objects[2]->value());
    }
}
