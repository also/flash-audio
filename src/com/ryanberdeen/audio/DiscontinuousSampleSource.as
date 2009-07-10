package com.ryanberdeen.audio {
  import flash.media.Sound;
  import flash.utils.ByteArray;

  public class DiscontinuousSampleSource implements ISampleSource {
    private var _sampleSource:ISampleSource;
    private var _sampleRanges:Array;
    private var sampleRangeIndex:int;

    private var startSample:Number;
    private var endSample:Number;
    private var currentSample:Number;
    private var finished:Boolean;

    public function set sampleSource(sampleSource:ISampleSource):void {
      _sampleSource = sampleSource;
    }

    public function set sampleRanges(sampleRanges:Array):void {
      _sampleRanges = sampleRanges;

      sampleRangeIndex = 0;

      startSample = _sampleRanges[sampleRangeIndex][0];
      endSample = _sampleRanges[sampleRangeIndex][1];
      currentSample = startSample;
    }

    public function extract(target:ByteArray, length:Number, startPosition:Number = -1):Number {
      if (startPosition != -1) {
        throw new ArgumentError('startPosition not allowed');
      }

      var samplesRead:int = 0;
      while (!finished && samplesRead < length) {
        var samplesLeft:int = endSample - currentSample;
        var samplesToRead:int = Math.min(samplesLeft, length - samplesRead);
        _sampleSource.extract(target, samplesToRead, currentSample);

        samplesRead += samplesToRead;
        currentSample += samplesToRead;
        if (currentSample == endSample) {
          sampleRangeIndex++;
          if (sampleRangeIndex == _sampleRanges.length) {
            finished = true;
          }
          else {
            startSample = _sampleRanges[sampleRangeIndex][0];
            endSample = _sampleRanges[sampleRangeIndex][1];
            currentSample = startSample;
          }
        }
      }
      return samplesRead;
    }
  }
}
