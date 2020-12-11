<?php

namespace Hx\Interop\RPC;

use Closure;
use Hx\Interop\Matcher;
use Hx\Interop\Message;

class Route implements Matcher {
    private Matcher $matcher;
    private Closure $handler;

    /**
     * @param $matcher
     * @param Closure $handler
     */
    public function __construct($matcher, Closure $handler) {
        $this->matcher = matcher($matcher);
        $this->handler = $handler;
    }

    public function match(Message $message): bool {
        return $this->matcher->match($message);
    }

    public function handle(Message $message) {
        ($this->handler)($message);
    }
}
