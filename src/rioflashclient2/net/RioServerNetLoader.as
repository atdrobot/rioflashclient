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
  import __AS3__.vec.Vector;
  
  import org.osmf.media.MediaResourceBase;
  import org.osmf.media.MediaType;
  import org.osmf.media.MediaTypeUtil;
  import org.osmf.media.URLResource;
  import org.osmf.net.NetConnectionFactoryBase;
  import org.osmf.net.NetLoader;
  import org.osmf.utils.URL;

  public class RioServerNetLoader extends NetLoader {
    public function RioServerNetLoader(factory:NetConnectionFactoryBase=null) {
      super(factory);
    }

    override public function canHandleResource(resource:MediaResourceBase):Boolean
    {
      return super.canHandleResource(resource) || canHandleAdResource(resource as URLResource);
    }

    private function canHandleAdResource(resource:URLResource):Boolean {
      var rt:int = MediaTypeUtil.checkMetadataMatchWithResource(resource, MEDIA_TYPES_SUPPORTED, MIME_TYPES_SUPPORTED);
      if (rt != MediaTypeUtil.METADATA_MATCH_UNKNOWN)
      {
        return rt == MediaTypeUtil.METADATA_MATCH_FOUND;
      }
      
      if (resource != null) {
        var url:URL = new URL(resource.url);
        
        if (validURL(url) && validProtocol(url)) {
          return emptyPath(url) || dotInPath(url) || validExtension(url);
        }
      }
      
      return false;
    }
    
    private function validURL(url:URL):Boolean {
      return url != null && url.rawUrl != null && url.rawUrl.length > 0;
    }
    
    private function validProtocol(url:URL):Boolean {
      return url.protocol == "" || url.protocol.search(/file$|http$|https$/i) != -1;
    }
    
    private function emptyPath(url:URL):Boolean {
      return url.path == null || url.path.length <= 0;
    }
    
    private function dotInPath(url:URL):Boolean {
      return url.path.indexOf(".") == -1;
    }
    
    private function validExtension(url:URL):Boolean {
      var extensionPattern:RegExp = new RegExp("\.flv|\.f4v|\.mov|\.mp4|\.mp4v|\.m4v", "i");
      return extensionPattern.test(url.rawUrl);
    }
    
    private static const MEDIA_TYPES_SUPPORTED:Vector.<String> = Vector.<String>([MediaType.VIDEO]);
    private static const MIME_TYPES_SUPPORTED:Vector.<String> = Vector.<String>
    ([
      "video/x-flv", 
      "video/x-f4v",
      "video/mp4",
      "video/mp4v-es",
      "video/x-m4v",
      "video/quicktime",
    ]);
  }
}
