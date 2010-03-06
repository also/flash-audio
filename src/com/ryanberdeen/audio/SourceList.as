/*
 * Copyright 2010 Ryan Berdeen. All rights reserved.
 * Distributed under the terms of the MIT License.
 * See accompanying file LICENSE.txt
 */

package com.ryanberdeen.audio {
    import flash.media.Sound;
    import flash.utils.ByteArray;

    import flash.external.ExternalInterface;

    /**
    * Provides samples based on a list of samples.
    */
    public class SourceList implements ISampleSource {
        private var _sources:Array;
        private var _length:Number;

        private var sli:SourceListItem;
        private var outputPosition:Number;
        private var finished:Boolean;

        private var positionSli:SourceListItem;

        public function set sources(sources:Array):void {
            _length = 0;
            _sources = [];
            var index:int = 0;
            for each (var item:ISampleSource in sources) {
                var s:SourceListItem = new SourceListItem();
                s.startOffset = _length;
                _length += item.length;
                s.endOffset = _length;
                s.length = item.length;
                s.source = item;
                s.index = index++;
                _sources.push(s);
            }

            sli = _sources[0];
            positionSli = sli;

            outputPosition = 0;
        }

        public function extract(target:ByteArray, length:Number, startPosition:Number = -1):Number {
            if (startPosition != -1) {
                if (startPosition != outputPosition) {
                    outputPosition = startPosition;
                    sli = seek(outputPosition, sli);
                }
            }

            var framesRead:int = 0;
            while (!finished && framesRead < length) {
                var framesLeft:int = sli.endOffset - outputPosition;
                var framesToRead:int = Math.min(framesLeft, length - framesRead);
                sli.extract(target, framesToRead, outputPosition);

                framesRead += framesToRead;
                outputPosition += framesToRead;
                if (outputPosition == sli.endOffset) {
                    if (sli.index == _sources.length - 1) {
                        finished = true;
                    }
                    else {
                        sli = _sources[sli.index + 1];
                    }
                }
            }
            return framesRead;
        }

        public function toSourcePosition(position:Number):Number {
            positionSli = seek(position, positionSli);
            return positionSli.toSourcePosition(position);
        }

        private function seek(position:Number, seekSli:SourceListItem):SourceListItem {
            while (position > seekSli.endOffset) {
                seekSli = _sources[seekSli.index + 1];
            }
            while (position < seekSli.startOffset) {
                seekSli = _sources[seekSli.index - 1];
            }

            return seekSli;
        }

        public function get length():Number {
            return _length;
        }

        public function get sampleSourceIndex():int {
            return positionSli.index;
        }
    }
}
