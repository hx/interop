<?php

namespace Hx\Interop;

class ClosureMatcher implements Matcher {
    private string $closure;

    /**
     * @param string $closure
     */
    public function __construct(string $closure) {
        $this->closure = $closure;
    }

    public function match(Message $message): bool {
        return !!($this->closure)($message[Header::RPC_CLASS]);
    }
}
