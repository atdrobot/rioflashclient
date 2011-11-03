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
  import org.osmf.logging.Logger;
  
  import rioflashclient2.configuration.Configuration;

  /**
   * Classe reponsável pelo parser dos tópicos do xml.
   * @author LAND
   * 
   */    
  public class Topics {
    public var rawXML:XML;
    public var parsedXML:XML;
    public var topicTimes:Array = new Array();

	/**
	 * Construtor da classe que chama o parser xml dos tópicos para o arquivo especificado através do parâmetro. 
	 * @param xml
	 * 
	 */	
    public function Topics(xml:XML) {
      rawXML = xml;
      parsedXML = parse(rawXML);
    }

	/**
	 * Parser dos tópicos do arquivo xml.
	 * @param xml
	 * @return 
	 * 
	 */	
    public function parse(xml:XML):XML {
      var item:XML = <node />
      if (xml.hasOwnProperty("text")) {
        if ( Configuration.getInstance().formatTime(xml.time) == "00:00" ) {
			item.@label = "00:01" + " - " + xml.text;
			item.@time = 1;
			topicTimes.push(1);
		}
		else {
			item.@label = Configuration.getInstance().formatTime(xml.time) + " - " + xml.text;
			item.@time = xml.time;
			topicTimes.push(xml.time);	
		}
      } else {
        item.@label = 'Root';
      }

      for each (var childNode:XML in xml.ind_item) {
        item.appendChild(parse(childNode));
      }

      return item;
    }

	/**
	 * Método que retorna o xml já com o parser efetuado. 
	 * @return 
	 * 
	 */	
    public function toXML():XML {
      return parsedXML;
    }
  }
}