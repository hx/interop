<?php

namespace Hx\Interop\RPC;

use Hx\Interop\Header;
use Hx\Interop\Matcher;
use Hx\Interop\Message;

class ClassMatcher implements Matcher {
    private string $class;

    /**
     * @param string $class
     */
    public function __construct(string $class) {
        $this->class = $class;
    }

    public function match(Message $message): bool {
        return $message[Header::RPC_CLASS] === $this->class;
    }
}
