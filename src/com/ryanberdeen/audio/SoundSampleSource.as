package com.ryanberdeen.audio {
  import flash.media.Sound;
  import flash.utils.ByteArray;

  public class SoundSampleSource implements ISampleSource {
    private var sound:Sound;
    private var startAtBeginning:Boolean;

    public function SoundSampleSource(sound:Sound):void {
      this.sound = sound;
      startAtBeginning = true;
    }

    public function extract(target:ByteArray, length:Number, startPosition:Number = -1):Number {
      if (startAtBeginning) {
        if (startPosition == -1) {
          startPosition = 0;
        }
        startAtBeginning = false;
      }
      return sound.extract(target, length, startPosition);
    }
  }
}
