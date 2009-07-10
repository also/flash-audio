/*
 * Copyright 2009 Ryan Berdeen. All rights reserved.
 * Distributed under the terms of the MIT License.
 * See accompanying file LICENSE.txt
 */

package com.ryanberdeen.audio {
  import flash.utils.ByteArray;

  public interface ISampleSource {
    function extract(target:ByteArray, length:Number, startPosition:Number = -1):Number;
  }
}