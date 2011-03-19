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

/*****************************************************
*
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
*
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*
*
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems
*  Incorporated. All Rights Reserved.
*
*****************************************************/
package rioflashclient2.elements
{
  import rioflashclient2.elements.AsynchLoadingProxyElement;
  import org.osmf.media.MediaElement;
  import org.osmf.traits.LoadTrait;

  /**
   * A ProxyElement which preloads its proxied element up front.  The preload
   * operation is defined as a load plus a play followed by a pause.  Extends
   * AsynchLoadingProxyElement, which is a generic base class for proxies that
   * need to incorporate custom logic into the load operation.
   **/
  public class PreloadingProxyElement extends AsynchLoadingProxyElement
  {
    /**
     * Constructor.
     **/
    public function PreloadingProxyElement(proxiedElement:MediaElement)
    {
      super(proxiedElement);
    }

    /**
     * @private
     **/
    override protected function createAsynchLoadingProxyLoadTrait():LoadTrait
    {
      return new PreloadingLoadTrait(proxiedElement);
    }
  }
}