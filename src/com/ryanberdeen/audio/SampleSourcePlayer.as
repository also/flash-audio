package com.ryanberdeen.audio {
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.SampleDataEvent;
  import flash.media.Sound;
  import flash.media.SoundChannel;
  import flash.utils.ByteArray;

  public class SampleSourcePlayer extends EventDispatcher {
    private static const SAMPLE_BUFFER_SIZE:int = 8192;
    private var _sampleSource:ISampleSource;
    private var outputSound:Sound;
    private var soundChannel:SoundChannel;
    private var playing:Boolean;

    private var _sampleCount:Number;

    public function SampleSourcePlayer():void {
      outputSound = new Sound();

      outputSound.addEventListener(SampleDataEvent.SAMPLE_DATA, function(e:SampleDataEvent):void {
        _sampleSource.extract(e.data, SAMPLE_BUFFER_SIZE);
      });
    }

    public function set sampleSource(sampleSource:ISampleSource):void {
      _sampleSource = sampleSource;
    }

    public function start():void {
      if (soundChannel != null) {
        soundChannel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
      }

      soundChannel = outputSound.play();
      soundChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
      playing = true;
    }

    public function stop():void {
      if (playing) {
        soundChannel.stop();
        playing = false;
      }
    }

    public function get position():Number {
      return soundChannel.position;
    }

    private function soundCompleteHandler(e:Event):void {
      dispatchEvent(new Event(Event.SOUND_COMPLETE));
    }
  }
}
