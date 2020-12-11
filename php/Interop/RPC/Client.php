<?php

namespace Hx\Interop\RPC;

use Closure;
use Hx\Interop\EOF;
use Hx\Interop\Error\AlreadyClosed;
use Hx\Interop\Error\AlreadyWaiting;
use Hx\Interop\Header;
use Hx\Interop\Matcher;
use Hx\Interop\Message;
use InvalidArgumentException;

class Client extends Base {
    private bool $waiting = false;
    private array $responders = [];
    private int $lastId = 0;

    /**
     * @var string Message ID prefix to be prepended to request IDs
     */
    public string $idPrefix = '';

    /**
     * @param $message
     * @param Closure|null $responder
     * @return Message|null
     * @throws EOF
     * @throws AlreadyClosed
     */
    public function call($message, ?Closure $responder = null): ?Message {
        $id = $this->idPrefix . ++$this->lastId;
        $message = $this->buildMessage($message);
        $message[Header::RPC_ID] = $id;
        $this->conn->write($message);

        if ($responder) {
            $this->responders[$id] = $responder;
            return null;
        }

        return $this->waitUntil(new IDMatcher($id));
    }

    /**
     * @throws AlreadyWaiting
     */
    public function wait(): void {
        if ($this->waiting) {
            throw new AlreadyWaiting();
        }
        try {
            while ($message = $this->conn->read()) {
                $this->handle($message);
            }
        } catch (EOF) {}
    }

    /**
     * @param Matcher $matcher
     * @return Message
     * @throws EOF
     */
    private function waitUntil(Matcher $matcher): Message {
        $wasWaiting = $this->waiting;
        $this->waiting = true;
        try {
            while (true) {
                $message = $this->conn->read();
                if ($matcher->match($message)) {
                    return $message;
                }
                $this->handle($message);
            }
        } finally {
            $this->waiting = $wasWaiting;
        }
    }

    private function handle(Message $message) {
        if ($id = $message[Header::RPC_ID]) {
            if (isset($this->responders[$id])) {
                $responder = $this->responders[$id];
                unset($this->responders[$id]);
                $responder($message);
                return;
            }
        }
        $this->dispatcher->dispatch($message);
    }

    private function buildMessage($message): Message {
        if ($message instanceof Message) {
            return $message;
        }
        if (is_string($message)) {
            return new Message([Header::RPC_CLASS => $message]);
        }
        throw new InvalidArgumentException('Expected a Message or a string');
    }
}
