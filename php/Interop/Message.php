<?php

namespace Hx\Interop;

use ArrayAccess;
use JsonException;

class Message implements ArrayAccess {
    public const JSON = 'application/json';
    public const BINARY = 'application/octet-stream';

    public static function build(...$args): self {
        if (count($args) === 1 && $args[0] instanceof self) {
            $message = array_shift($args);
        } else {
            $message = new self();
        }

        foreach($args as $arg) {
            if ($arg === null) {
                continue;
            }
            elseif (is_array($arg)) {
                $message->headers->append($arg);
            }
            elseif ($arg instanceof self) {
                $message->headers->append($arg->headers);
                $message->body = $arg->body;
            }
            else {
                $message->body = strval($arg);
                $message[Header::CONTENT_LENGTH] = strlen($message->body);
            }
        }

        return $message;
    }

    /**
     * @param $object
     * @param array|null|Headers $headers
     * @param bool $pretty
     * @return static
     * @throws JsonException
     */
    public static function json($object, $headers = [], bool $pretty = false): self {
        $result = new Message($headers);
        $flags =
            JSON_THROW_ON_ERROR |
            JSON_UNESCAPED_UNICODE |
            JSON_UNESCAPED_SLASHES;
        if ($pretty) {
            $flags |= JSON_PRETTY_PRINT;
        }
        $result->body = json_encode($object, $flags) . "\n";
        $result[Header::CONTENT_TYPE] = Message::JSON;
        $result[Header::CONTENT_LENGTH] = strlen($result->body);
        return $result;
    }

    public Headers $headers;
    public string $body;

    /**
     * Message constructor.
     * @param array|null|Headers $headers
     * @param string $body
     */
    public function __construct($headers = [], $body = '') {
        if (!$headers instanceof Headers) {
            $headers = new Headers($headers);
        }
        $this->headers = $headers;
        $this->body = $body;
    }

    public function offsetExists($offset): bool {
        return $this->headers->offsetExists($offset);
    }

    public function offsetGet($offset): ?string {
        return $this->headers[$offset];
    }

    public function offsetSet($offset, $value) {
        $this->headers[$offset] = $value;
    }

    public function offsetUnset($offset) {
        unset($this->headers[$offset]);
    }

    public function __toString(): string {
        return $this->headers . "\n" . $this->body . "\n";
    }
}
