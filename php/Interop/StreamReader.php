<?php

namespace Hx\Interop;

use Hx\Interop\Error\Unexpected;

class StreamReader implements Reader {
    private ByteReader $byteReader;

    /**
     * @param ByteReader $byteReader
     */
    public function __construct(ByteReader $byteReader) {
        $this->byteReader = $byteReader;
    }

    public function read(): Message {
        $message = new Message($this->readHeaders());
        $length = $message[Header::CONTENT_LENGTH];
        $message->body = ($length === null || $length === '') ?
            join('', $this->readParagraph()) :
            $this->readLength(intval($length));
        return $message;
    }

    /**
     * @return Headers
     * @throws EOF
     * @throws Error\InvalidHeader
     */
    private function readHeaders(): Headers {
        return Headers::parse($this->readParagraph());
    }

    /**
     * @return string[]
     * @throws EOF
     */
    private function readParagraph(): array {
        $result = [];
        while (true) {
            $line = $this->readLine();
            if ($line === "\n" || $line === "\r\n") {
                return $result;
            }
            $result[]= $line;
        }
    }

    /**
     * @param int $length
     * @return string
     * @throws EOF
     * @throws Unexpected if the given length of bytes is not followed by a newline.
     */
    private function readLength(int $length): string {
        $result = $length >= 0 ? $this->byteReader->readBytes($length) : '';
        $sep = $this->byteReader->readBytes(1);
        if ($sep == "\r") {
            $sep = $this->byteReader->readBytes(1);
        }
        if ($sep !== "\n") {
            throw new Unexpected("Expected a newline after $length bytes");
        }
        return $result;
    }

    /**
     * @return string
     * @throws EOF
     */
    private function readLine(): string {
        return $this->byteReader->readUntil("\n");
    }
}
