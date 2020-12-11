<?php

namespace Hx\Interop\RPC;

use Hx\Interop\Header;
use Hx\Interop\Matcher;
use Hx\Interop\Message;

class IDMatcher implements Matcher {
    private string $id;

    /**
     * @param string $id
     */
    public function __construct(string $id) {
        $this->id = $id;
    }

    public function match(Message $message): bool {
        return $message[Header::RPC_ID] == $this->id;
    }
}
