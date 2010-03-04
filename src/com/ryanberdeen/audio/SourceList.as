/*
 * Copyright 2009 Ryan Berdeen. All rights reserved.
 * Distributed under the terms of the MIT License.
 * See accompanying file LICENSE.txt
 */

package com.ryanberdeen.audio {
  import flash.media.Sound;
  import flash.utils.ByteArray;
  
  import flash.external.ExternalInterface;

  /**
  * Provides samples based on an arbitrary list of sample ranges.
  */
  public class SourceList implements ISampleSource {
    private var _sources:Array;
    private var _length:Number;

    private var sourceIndex:int;
    private var source:ISampleSource;
    private var extractionPosition:Number;
    private var startPosition:Number;
    private var finished:Boolean;

    private var positionRangeIndex:int;
    private var localPosition:Number;

    private var linearPosition:Number;

    public function set sources(sources:Array):void {
      _sources = sources;

      sourceIndex = 0;
      source = _sources[sourceIndex];

      extractionPosition = 0;

      startPosition = 0;

      linearPosition = 0;
      localPosition = extractionPosition;
      positionRangeIndex = 0;

      _length = 0;
      for each (var s:ISampleSource in _sources) {
        _length += s.length;
      }
    }

    public function extract(target:ByteArray, length:Number, startPosition:Number = -1):Number {
      if (startPosition != -1) {
        if (startPosition != this.startPosition) {
          var newPosition:Array = seek(this.startPosition, startPosition, extractionPosition, sourceIndex);
          extractionPosition = newPosition[0];
          sourceIndex = newPosition[1];
          source = _sources[sourceIndex];
        }
      }

      var framesRead:int = 0;
      while (!finished && framesRead < length) {
        var framesLeft:int = source.length - extractionPosition;
        var framesToRead:int = Math.min(framesLeft, length - framesRead);
        source.extract(target, framesToRead, extractionPosition);

        framesRead += framesToRead;
        extractionPosition += framesToRead;
        if (extractionPosition == source.length) {
          sourceIndex++;

          if (sourceIndex == _sources.length) {
            finished = true;
          }
          else {
            source = _sources[sourceIndex];
            extractionPosition = 0;
          }
        }
      }

      this.startPosition = startPosition + framesRead;
      return framesRead;
    }

    public function toSourcePosition(position:Number):Number {
      var result:Array = seek(linearPosition, position, localPosition, positionRangeIndex);
      linearPosition = position;
      localPosition = result[0];
      positionRangeIndex = result[1];
      return result[0];
    }

    private function seek(linearStart:Number, linearEnd:Number, sourcePosition:Number, index:int):Array {
      if (linearEnd < linearStart) {
        // TODO might be faster to seek backwards and then seek forwards
        linearStart = 0;
        index = 0;
        sourcePosition = 0;
      }

      var distance:Number = linearEnd - linearStart;

      var source:ISampleSource;
      var distanceLeft:Number;
      var framesLeftThisSample:Number;

      var framesAdvanced:Number = 0;
      while (framesAdvanced < distance) {
        source = _sources[index];
        framesLeftThisSample = source.length - sourcePosition;
        distanceLeft = distance - framesAdvanced;
        if (framesLeftThisSample > distanceLeft) {
          sourcePosition += distanceLeft;
          framesAdvanced += distanceLeft;
        }
        else {
          index++;
          if (index < _sources.length) {
            sourcePosition = 0;
          }
          framesAdvanced += framesLeftThisSample;
        }
      }
      return [sourcePosition, index];
    }

    public function get length():Number {
      return _length;
    }

    public function get sampleSourceIndex():int {
      return positionRangeIndex;
    }
  }
}
