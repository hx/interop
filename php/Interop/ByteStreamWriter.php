<?php

namespace Hx\Interop;

use Hx\Interop\Error\AlreadyClosed;
use InvalidArgumentException;
use TypeError;

class ByteStreamWriter implements ByteWriter {
    private $resource;

    public function __construct($resource) {
        if (!is_resource($resource) || get_resource_type($resource) !== 'stream') {
            throw new InvalidArgumentException('Expected a resource');
        }
        stream_set_write_buffer($resource, 0);
        stream_set_blocking($resource, true);
        $this->resource = $resource;
    }

    public function writeBytes(string $buf): void {
        $written = 0;
        try {
            $written = fwrite($this->resource, $buf, strlen($buf));
        } catch (TypeError $e) {
            if ($e->getMessage() !== 'fwrite(): supplied resource is not a valid stream resource') {
                throw $e;
            }
        }
        if ($written !== strlen($buf)) {
            throw new AlreadyClosed();
        }
    }
}
