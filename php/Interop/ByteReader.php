<?php

namespace Hx\Interop;

/**
 * Interface ByteReader
 * @package Hx\Interop
 */
interface ByteReader {
    /**
     * Read from the underlying resource until $sep is encountered.
     * @param string $sep The record terminator at which reading should stop
     * @return string All bytes up to and including the given $sep
     * @throws EOF if the underlying resource runs out of data.
     */
    public function readUntil(string $sep): string;

    /**
     * @param int $len The number of bytes to read.
     * @return string A string with length matching the given $len.
     * @throws EOF if the underlying resource runs out of data
     */
    public function readBytes(int $len): string;
}
