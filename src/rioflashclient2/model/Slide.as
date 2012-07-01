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

package rioflashclient2.model {
  /**
   * Classe responsável pelo parser dos slides de acordo com o xml.
   * @author LAND
   * 
   */	
  public class Slide {
    public var time:int;
    public var relative_path:String;
    public var actions:Array;
    public function Slide() {
    }
    
	/**
	 * Método que cria um objeto Slide de acordo com o parser feito no xml. 
	 * @param rawSlide
	 * @return 
	 * 
	 */	
    public static function createFromRaw(rawSlide:XML):Slide {
      var slide:Slide = new Slide();
      slide.time = rawSlide.@time;
      slide.relative_path = rawSlide.@relative_path;
	  slide.actions = [];
	  if(rawSlide.actions.action.length()){
		  for each(var item:XML in rawSlide.actions.action){
			    slide.actions.push({time: item.@time, callback:item.text()});
		  }
	  }
      return slide;
    }

    public function valid():Boolean {
      return true;
    }
    
    public function url():String {
      return "http://"
    }
  }
}