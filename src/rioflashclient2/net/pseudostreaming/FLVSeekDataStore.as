/*
 * Copyright (C) 2011, Edmundo Albuquerque de Souza e Silva.
 *
 * This file may be distributed under the terms of the Q Public License
 * as defined by Trolltech AS of Norway and appearing in the file
 * LICENSE.QPL included in the packaging of this file.
 *
 * THIS FILE IS PROVIDED AS IS WITH NO WARRANTY OF ANY KIND, INCLUDING
 * THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL,
 * INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING
 * FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
 * NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION
 * WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

package rioflashclient2.net.pseudostreaming {
  import rioflashclient2.net.pseudostreaming.DefaultSeekDataStore;

  public class FLVSeekDataStore extends DefaultSeekDataStore {

    override protected function extractKeyFrameFilePositions(metaData:Object):Array {
        log.debug("extractKeyFrameFilePositions");
        var keyFrames:Object = extractKeyFrames(metaData);
        if (!keyFrames) return null;
        return keyFrames.filepositions;
    }

    override protected function extractKeyFrameTimes(metaData:Object):Array {
        log.debug("extractKeyFrameTimes");
        var keyFrames:Object = extractKeyFrames(metaData);
        if (!keyFrames) return null;

        var keyFrameTimes:Array = keyFrames.times;
        if (!keyFrameTimes) {
            log.error("clip does not have keyframe metadata, cannot use pseudostreaming");
        }
        return keyFrameTimes as Array;
    }

    private function extractKeyFrames(metaData:Object):Object {
        var keyFrames:Object = metaData.keyframes;
        log.debug("keyFrames: " + keyFrames); // commented
        if (!keyFrames) {
            log.info("No keyframes in this file, random seeking cannot be done");
            return null;
        }
        return keyFrames;
    }

    override protected function queryParamValue(pos:Number):Number {
        _startKeyFrameTime = _keyFrameTimes[pos];
        return _keyFrameFilePositions[pos] as Number;
    }


    override public function inBufferSeekTarget(target:Number):Number {
        return target;
    }

    override public function currentPlayheadTime(time:Number, start:Number):Number {
        return time - start;
    }
  }
}