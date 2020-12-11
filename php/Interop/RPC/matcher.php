<?php

namespace Hx\Interop\RPC;

use Closure;
use Hx\Interop\ClosureMatcher;
use Hx\Interop\Matcher;
use InvalidArgumentException;

function matcher($criteria): Matcher {
    if ($criteria instanceof Closure) {
        return new ClosureMatcher($criteria);
    }
    if (is_string($criteria)) {
        return new ClassMatcher($criteria);
    }
    throw new InvalidArgumentException('Expected a Closure or string');
}
