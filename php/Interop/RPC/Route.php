<?php

namespace Hx\Interop\RPC;

use Closure;
use Hx\Interop\ClosureMatcher;
use Hx\Interop\Matcher;
use Hx\Interop\Message;
use InvalidArgumentException;

class Route implements Matcher {
    public static function buildMatcher($criteria): Matcher {
        if ($criteria instanceof Matcher) {
            return $criteria;
        }
        if ($criteria instanceof Closure) {
            return new ClosureMatcher($criteria);
        }
        if (is_string($criteria)) {
            return new ClassMatcher($criteria);
        }
        throw new InvalidArgumentException('Expected a Closure or string');
    }

    private Matcher $matcher;
    private Closure $handler;

    /**
     * @param $matcher
     * @param Closure $handler
     */
    public function __construct($matcher, Closure $handler) {
        $this->matcher = self::buildMatcher($matcher);
        $this->handler = $handler;
    }

    public function match(Message $message): bool {
        return $this->matcher->match($message);
    }

    public function handle(Message $message) {
        ($this->handler)($message);
    }
}
