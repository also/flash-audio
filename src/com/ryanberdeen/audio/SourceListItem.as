/*
 * Copyright 2010 Ryan Berdeen. All rights reserved.
 * Distributed under the terms of the MIT License.
 * See accompanying file LICENSE.txt
 */

package com.ryanberdeen.audio {
    import flash.utils.ByteArray;

    internal class SourceListItem {
        public var source:ISampleSource;
        public var startOffset:Number;
        public var endOffset:Number;
        public var length:Number;
        public var index:int;

        public function toSourcePosition(position:Number):Number {
            return source.toSourcePosition(position - startOffset);
        }

        public function extract(target:ByteArray, length:Number, startPosition:Number):Number {
            return source.extract(target, length, startPosition - startOffset);
        }
    }
}
