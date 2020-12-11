<?php

namespace Hx\Interop\RPC;

use Closure;
use Hx\Interop\ReaderWriter;

abstract class Base {
    protected ReaderWriter $conn;
    protected Dispatcher $dispatcher;

    /**
     * @param ReaderWriter $conn
     */
    public function __construct(ReaderWriter $conn) {
        $this->dispatcher = new Dispatcher();
        $this->conn = $conn;
    }

    public function on($matcher, Closure $handler): self {
        $this->dispatcher->on($matcher, $handler);
        return $this;
    }
}
