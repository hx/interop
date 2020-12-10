<?php

namespace Hx\Interop;

interface Reader {
    /**
     * @return Message
     * @throws EOF
     */
    public function read(): Message;
}
