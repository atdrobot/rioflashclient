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

package rioflashclient2.net
{
  import org.osmf.elements.SWFLoader;
  import org.osmf.media.MediaResourceBase;
  import org.osmf.media.MediaType;
  import org.osmf.media.MediaTypeUtil;
  import org.osmf.media.URLResource;
  import org.osmf.utils.URL;

  public class RioServerSWFLoader extends SWFLoader
  {
    /**
     * @private
     *
     * Indicates whether this SWFLoader is capable of handling the specified resource.
     * Returns <code>true</code> for URLResources with SWF extensions.
     * @param resource Resource proposed to be loaded.
     */
    override public function canHandleResource(resource:MediaResourceBase):Boolean
    {
      var rt:int = MediaTypeUtil.checkMetadataMatchWithResource(resource, MEDIA_TYPES_SUPPORTED, MIME_TYPES_SUPPORTED);
      if (rt != MediaTypeUtil.METADATA_MATCH_UNKNOWN)
      {
        return rt == MediaTypeUtil.METADATA_MATCH_FOUND;
      }
      var urlResource:URLResource = resource as URLResource;
      if (urlResource != null &&
        urlResource.url != null)
      {
        var url:URL = new URL(urlResource.url);
        return validExtension(url);
      }
      return false;
    }

    private function validExtension(url:URL):Boolean {
      var extensionPattern:RegExp = new RegExp("\.swf", "i");
      return extensionPattern.test(url.rawUrl);
    }

    private static const MIME_TYPES_SUPPORTED:Vector.<String> = Vector.<String>(["application/x-shockwave-flash"]);
    private static const MEDIA_TYPES_SUPPORTED:Vector.<String> = Vector.<String>([MediaType.SWF]);
  }
}