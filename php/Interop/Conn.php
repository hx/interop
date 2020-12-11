<?php

namespace Hx\Interop;

class Conn implements ReaderWriter {
    public static function build($reader, $writer = null): ReaderWriter {
        if ($writer === null) {
            if ($reader instanceof ReaderWriter) {
                return $reader;
            }
            $writer = $reader;
        }

        $reader = self::castResource($reader, 'Reader');
        $writer = self::castResource($writer, 'Writer');

        return new self($reader, $writer);
    }

    private static function castResource($object, $type) {
        $byteInterface = "Hx\Interop\Byte$type";
        $streamClass   = "Hx\Interop\Stream$type";
        $byteClass     = "Hx\Interop\ByteStream$type";
        if (is_resource($object) && get_resource_type($object) === 'stream') {
            $object = new $byteClass($object);
        }
        if ($object instanceof $byteInterface) {
            $object = new $streamClass($object);
        }
        return $object;
    }

    private Reader $reader;
    private Writer $writer;

    /**
     * @param Reader $reader
     * @param Writer $writer
     */
    public function __construct(Reader $reader, Writer $writer) {
        $this->reader = $reader;
        $this->writer = $writer;
    }

    public function read(): Message {
        return $this->reader->read();
    }

    public function write(Message $message): void {
        $this->writer->write($message);
    }
}
