<?php

namespace Hx\Interop\RPC;

use Closure;
use Hx\Interop\Message;

class Dispatcher {
    /**
     * @var Route[] $routes
     */
    private array $routes = [];

    public function on($matcher, Closure $handler): self {
        $this->routes[] = new Route($matcher, $handler);
        return $this;
    }

    public function dispatch(Message $event) {
        foreach($this->routes as $route) {
            if ($route->match($event)) {
                $route->handle($event);
            }
        }
    }

    public function match(Message $event): ?Route {
        foreach($this->routes as $route) {
            if ($route->match($event)) {
                return $route;
            }
        }
        return null;
    }
}
