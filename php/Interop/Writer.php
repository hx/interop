<?php

namespace Hx\Interop;

use Hx\Interop\Error\AlreadyClosed;

interface Writer {
    /**
     * @param Message $message
     * @throws AlreadyClosed
     */
    public function write(Message $message): void;
}
