<?php

namespace Hx\Interop;

use InvalidArgumentException;

class ByteStreamReader implements ByteReader {
    /**
     * @var resource
     */
    private $resource;
    private string $buffer = '';

    /**
     * ByteStreamReader constructor.
     * @param $resource resource An open and readable file, socket, memory stream, etc.
     */
    public function __construct($resource) {
        if (!is_resource($resource) || get_resource_type($resource) !== 'stream') {
            throw new InvalidArgumentException('Expected a resource');
        }
        stream_set_read_buffer($resource, 0);
        stream_set_blocking($resource, true);
        $this->resource = $resource;
    }

    public function readUntil(string $sep): string {
        $pos = strpos($this->buffer, $sep);
        if ($pos !== false) {
            return $this->shift($pos + strlen($sep));
        }
        while (true) {
            $byte = fgetc($this->resource);
            if ($byte === false) {
                throw new EOF();
            }
            $this->buffer .= $byte;
            if (str_ends_with($this->buffer, $sep)) {
                return $this->shift(strlen($this->buffer));
            }
        }
    }

    public function readBytes(int $len): string {
        while (true) {
            if (strlen($this->buffer) >= $len) {
                return $this->shift($len);
            }
            if (feof($this->resource)) {
                throw new EOF();
            }
            $bytes = fread($this->resource, $len - strlen($this->buffer));
            if ($bytes === false) {
                // TODO: figure out what the *actual* error was
                throw new EOF();
            }
            $this->buffer .= $bytes;
        }
    }

    private function shift(int $len): string {
        $result = substr($this->buffer, 0, $len);
        $this->buffer = substr($this->buffer, $len);
        return $result;
    }
}
