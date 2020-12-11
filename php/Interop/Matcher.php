<?php

namespace Hx\Interop;

interface Matcher {
    public function match(Message $message): bool;
}
