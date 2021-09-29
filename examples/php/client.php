<?php

require_once __DIR__ . '/../../vendor/autoload.php';

$writer = fopen('a', 'w');
$reader = fopen('b', 'r');

$client = new Hx\Interop\RPC\Client($reader, $writer);

$client->on('tick', function (Hx\Interop\Message $message) use ($writer) {
    echo "Tick $message->body\n";
    if ($message->body == 5) {
        fclose($writer);
    }
});

$client->call('countdown', ['ticks' => 5]);

$client->wait();
