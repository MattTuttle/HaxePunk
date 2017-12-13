package haxepunk.audio;

import haxe.io.Bytes;
import haxe.io.BytesData;
import haxe.io.BytesInput;

// Thanks to http://www-mmsp.ece.mcgill.ca/Documents/AudioFormats/WAVE/WAVE.html
class Wave
{
    public var data(default, null):BytesData;
    public var frequency(default, null):Int;
    public var channels(default, null):Int;
    public var bitsPerSample(default, null):Int;

    function new() {}

    public static function fromBytes(bytes:Bytes):Null<Wave>
    {
        var b = new BytesInput(bytes);
        b.bigEndian = false;

        if (b.readString(4) != "RIFF") return null;
        var length = b.readInt32();
        if (b.readString(4) != "WAVE") return null;

        var wave = new Wave();

        while (b.position < b.length)
        {
            switch (b.readString(4))
            {
                case "fmt ": wave.readFormat(b);
                case "data": wave.readData(b);
            }
        }

        return wave;
    }

    function readData(b:BytesInput)
    {
        var chunkSize = b.readInt32();
        data = b.read(chunkSize).getData();
        // read padding byte if odd
        if (chunkSize % 2 == 1) b.readByte();
    }

    function readFormat(b:BytesInput)
    {
        var chunkSize = b.readInt32();
        var formatTag = b.readInt16();
        if (formatTag != WAVE_FORMAT_PCM)
        {
            throw "HaxePunk only supports PCM wave files";
        }
        channels = b.readInt16();
        frequency = b.readInt32();
        b.readInt32(); // avgBytesPerSec
        b.readInt16(); // blockAlign
        bitsPerSample = b.readInt16();
        if (chunkSize > 16)
        {
            b.readInt16(); // size
            if (chunkSize > 18)
            {
                b.readInt16(); // validBitsPerSample
                b.readInt32(); // channelMask
                b.readString(16); // subFormat
            }
        }
    }

    static inline var WAVE_FORMAT_PCM:Int = 1;
}