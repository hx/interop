<?php

namespace Hx\Interop;

class StreamWriter implements Writer {
    private ByteWriter $byteWriter;

    /**
     * @param ByteWriter $byteWriter
     */
    public function __construct(ByteWriter $byteWriter) {
        $this->byteWriter = $byteWriter;
    }

    public function write(Message $message): void {
        foreach($message->headers as $header) {
            $this->byteWriter->writeBytes(strval($header));
        }
        $this->byteWriter->writeBytes("\n");
        $this->byteWriter->writeBytes($message->body);
        $this->byteWriter->writeBytes("\n");
    }
}
