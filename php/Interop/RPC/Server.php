<?php

namespace Hx\Interop\RPC;

use Hx\Interop\EOF;
use Hx\Interop\Header;
use Hx\Interop\Message;
use InvalidArgumentException;

class Server extends Base {
    public function send($event, ...$args) {
        $event = $this->buildMessage($event, ...$args);

        if (isset($event->headers[Header::RPC_ID])) {
            throw new InvalidArgumentException('Cannot send an event with an ID');
        }

        $this->conn->write($event);
    }

    public function wait() {
        $request = null;
        while (true) {
            try {
                $request = $this->conn->read();
            } catch (EOF) {
                return;
            }
            $response = $this->makeResponse($this->dispatcher->match($request)?->handle($request));
            $response[Header::RPC_ID] = $request[Header::RPC_ID];
            $this->conn->write($response);
        }
    }

    private function makeResponse($response): Message {
        if ($response instanceof Message) {
            return $response;
        }

        if (!is_array($response)) {
            $response = [$response];
        }

        return Message::build(...$response);
    }
}
