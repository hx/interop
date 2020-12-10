<?php

namespace Hx\Interop;

use Hx\Interop\Error\AlreadyClosed;

class Buffer implements ByteReader, ByteWriter {
    private string $buffer;
    private int $cursor = 0;
    private bool $closed = false;

    public function __construct(string $buffer = '') {
        $this->buffer = $buffer;
    }

    public function readUntil(string $sep): string {
        $pos = strpos($this->buffer, $sep, $this->cursor);
        if ($pos === false) {
            $this->cursor = strlen($this->buffer);
            throw new EOF();
        }
        return $this->readBytes($pos - $this->cursor + strlen($sep));
    }

    public function readBytes(int $len): string {
        if ($this->closed) {
            throw new EOF();
        }
        if ($len <= 0) {
            return '';
        }
        if ($len > strlen($this->buffer) - $this->cursor) {
            $this->cursor = strlen($this->buffer);
            throw new EOF();
        }
        $result = substr($this->buffer, $this->cursor, $len);
        $this->cursor += $len;
        return $result;
    }

    public function writeBytes(string $buf): void {
        if ($this->closed) {
            throw new AlreadyClosed();
        }
        $this->buffer .= $buf;
    }

    public function rewind(): self {
        $this->cursor = 0;
        return $this;
    }

    public function clear(): self {
        $this->buffer = '';
        return $this->rewind();
    }

    /**
     * @throws AlreadyClosed
     */
    public function close(): void {
        if ($this->closed) {
            throw new AlreadyClosed();
        }
        $this->closed = true;
    }

    public function __toString(): string {
        return $this->buffer;
    }
}
