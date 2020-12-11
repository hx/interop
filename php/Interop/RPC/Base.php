<?php

namespace Hx\Interop\RPC;

use Closure;
use Hx\Interop\Conn;
use Hx\Interop\Header;
use Hx\Interop\Message;
use Hx\Interop\ReaderWriter;

abstract class Base {
    protected ReaderWriter $conn;
    protected Dispatcher $dispatcher;

    /**
     * @param mixed ...$args
     */
    public function __construct(...$args) {
        $this->dispatcher = new Dispatcher();
        $this->conn = Conn::build(...$args);
    }

    public function on($matcher, Closure $handler): self {
        $this->dispatcher->on($matcher, $handler);
        return $this;
    }

    protected function buildMessage($first, ...$rest): Message {
        if (is_string($first)) {
            $first = [Header::RPC_CLASS => $first];
        }
        return Message::build($first, ...$rest);
    }
}
