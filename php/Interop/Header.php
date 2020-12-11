<?php

namespace Hx\Interop;

use Hx\Interop\Error\InvalidHeader;

class Header {
    public const RPC_ID = 'Interop-Rpc-Id';
    public const RPC_CLASS = 'Interop-Rpc-Class';
    public const RPC_ERROR = 'Interop-Rpc-Error';
    public const CONTENT_LENGTH = 'Content-Length';
    public const CONTENT_TYPE = 'Content-Type';

    public static function canonicalName(string $name): string {
        $parts = preg_split("`[-_\\s]+`", trim($name));
        foreach ($parts as $k => $i) {
            $parts[$k] = ucfirst(strtolower($i));
        }
        return join('-', $parts);
    }

    /**
     * @param string $rawHeader E.g. 'Foo: Bar\n'
     * @return self The parsed header.
     * @throws InvalidHeader
     */
    public static function parse(string $rawHeader): self {
        $pair = preg_split('`:\s*`', trim($rawHeader), 2);
        if (count($pair) !== 2) {
            throw new InvalidHeader();
        }
        return new self(...$pair);
    }

    private string $name;
    private string $value;

    public function __construct(string $name, string $value) {
        $this->name = self::canonicalName($name);
        $this->value = strval($value);
    }

    public function name(): string {
        return $this->name;
    }

    public function value(): string {
        return $this->value;
    }

    public function __toString(): string {
        return sprintf("%s: %s\n", $this->name, $this->value);
    }
}
