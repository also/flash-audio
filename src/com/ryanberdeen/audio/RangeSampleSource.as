/*
 * Copyright 2009 Ryan Berdeen. All rights reserved.
 * Distributed under the terms of the MIT License.
 * See accompanying file LICENSE.txt
 */

package com.ryanberdeen.audio {
    import flash.media.Sound;
    import flash.utils.ByteArray;

    public class RangeSampleSource implements ISampleSource {
        private var source:ISampleSource;
        private var _offset:Number;
        private var _length:Number;

        public function RangeSampleSource(source:ISampleSource, offset:Number, length:Number):void {
            this.source = source;
            _offset = offset;
            _length = length;
        }

        public function extract(target:ByteArray, length:Number, startPosition:Number = -1):Number {
            if (startPosition == -1) {
                startPosition = 0;
            }
            return source.extract(target, length, _offset + startPosition);
        }

        public function toSourcePosition(position:Number):Number {
            return _offset + position;
        }
        
        public function get offset():Number {
            return _offset;
        }

        public function get length():Number {
            return _length;
        }
    }
}
