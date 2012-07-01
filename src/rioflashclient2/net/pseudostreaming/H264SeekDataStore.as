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

  public class H264SeekDataStore extends DefaultSeekDataStore {

    override protected function extractKeyFrameTimes(metaData:Object):Array {
      var times:Array = new Array();
      for (var j:Number = 0; j != metaData.seekpoints.length; ++j) {
        times[j] = Number(metaData.seekpoints[j]['time']);
        log.debug("keyFrame[" + j + "] = " + times[j]);
      }
      return times;
    }

    override protected function queryParamValue(pos:Number):Number {
      var paramValue:Number = _keyFrameTimes[pos] + 0.01
      _startKeyFrameTime = paramValue;
      return paramValue;
    }
  }
}