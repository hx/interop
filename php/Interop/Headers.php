<?php

namespace Hx\Interop;

use ArrayAccess;
use ArrayIterator;
use Countable;
use InvalidArgumentException;
use IteratorAggregate;

class Headers implements ArrayAccess, Countable, IteratorAggregate {
    /**
     * Parse headers from an array of wire-formatted lines.
     * @param array $lines One raw MIME header per line
     * @return static
     * @throws Error\InvalidHeader
     */
    public static function parse(array $lines): self {
        $result = new self();
        foreach($lines as $line) {
            $result->headers[] = Header::parse($line);
        }
        return $result;
    }

    /**
     * @var Header[]
     */
    private array $headers;

    public function __construct($headers = []) {
        $this->headers = [];
        $this->append($headers);
    }

    public function offsetExists($offset): bool {
        $key = Header::canonicalName($offset);
        foreach ($this->headers as $header) {
            if ($header->name() === $key) {
                return true;
            }
        }
        return false;
    }

    public function offsetGet($offset): ?string {
        $key = Header::canonicalName($offset);
        foreach ($this->headers as $header) {
            if ($header->name() === $key) {
                return $header->value();
            }
        }
        return null;
    }

    public function offsetSet($offset, $value) {
        if ($value === null) {
            unset($this[$offset]);
            return;
        }

        $key = Header::canonicalName($offset);

        foreach ($this->headers as $k => $header) {
            if ($header->name() === $key) {
                $this->headers[$k] = new Header($key, $value);
                $this->remove($key, $k + 1);
                return;
            }
        }

        $this->headers[]= new Header($key, $value);
    }

    public function offsetUnset($offset) {
        $this->remove(Header::canonicalName($offset));
    }

    public function add(string $name, string $value): Headers {
        $this->headers[]= new Header($name, $value);
        return $this;
    }

    private function remove(string $key, int $offset = 0): void {
        $new = array_slice($this->headers, 0, $offset);
        $old = array_slice($this->headers, $offset);
        foreach($old as $header) {
            if ($header->name() !== $key) {
                $new[] = $header;
            }
        }
        $this->headers = $new;
    }

    public function count(): int {
        return count($this->headers);
    }

    public function getIterator(): ArrayIterator {
        return new ArrayIterator($this->headers);
    }

    public function append($val): self {
        if (is_array($val) || $val instanceof Headers) {
            foreach ($val as $k => $v) {
                $this->add($k, $v);
            }
        } elseif ($val !== null) {
            throw new InvalidArgumentException('Expected some headers');
        }
        return $this;
    }
    public function __toString(): string {
        return join('', $this->headers);
    }
}
