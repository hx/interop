<?php

namespace Hx\Interop;

use Hx\Interop\Error\AlreadyClosed;

/**
 * Interface ByteWriter
 * @package Hx\Interop
 */
interface ByteWriter {
    /**
     * Write the given byte string to the underlying resource.
     * @param string $buf The string of bytes to be written.
     * @throws AlreadyClosed when the underlying stream is closed.
     */
    public function writeBytes(string $buf): void;
}
