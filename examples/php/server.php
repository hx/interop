<?php

require_once __DIR__ . '/../../vendor/autoload.php';

$reader = fopen('a', 'r');
$writer = fopen('b', 'w');

$server = new Hx\Interop\RPC\Server($reader, $writer);

$server->on('countdown', function (Hx\Interop\Message $message) use($server) {
    $num = (int) $message['ticks'];
    for ($i = 1; $i <= $num; $i++) {
        sleep(1);
        $server->send('tick', Hx\Interop\Message::json($i));
    }
});

$server->wait();
