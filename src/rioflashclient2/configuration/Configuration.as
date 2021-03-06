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

package rioflashclient2.configuration {
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;

  public class Configuration {
    /**
     * The environment that should be used to get configurations that may change
     * based on where the application is deployed.
     *
     * The default environment is set to 'production', so that it is not needed
     * in production, and thus, remain hidden from malicious users attempting
     * to hack into the player.
     */
    public var environment:String;

    /**
     * Defines the default configurations per environments.
     */
    public var defaultConfigsPerEnvironments:Object = {
      development: {
        // Configuration for development environment.
      },
      staging: {
        // Configuration for staging environment.
      },
      production: {
        // Configuration for production environment.
      }
    }

    /**
     * The base rio server url.
     * "http://edad.rnp.br/redirect.rio?file=/ufrj/palestras/hucff/palestra_nelson.xml" becomes:
     * "http://edad.rnp.br/redirect.rio?file=/ufrj/palestras/hucff/";
     */
    public var baseRioServerURL:String;

    /**
     * The lesson xml file.
     * "http://edad.rnp.br/redirect.rio?file=/ufrj/palestras/hucff/palestra_nelson.xml" becomes:
     * "palestra_nelson.xml";
     */
    public var lessonXML:String

    /**
     * Whether the player should begin playing right away or wait for user input.
     */
    public var autoPlay:Boolean;

    /**
     * Whether the control bar should be displayed or not.
     *
     * @default true
     */
    public var displayControlBar:Boolean;

    /**
     * The buttons to be displayed in the control bar.
     *
     * The given value should be a '|' separated list with the buttons to be
     * displayed. Notice that the order in which each button appears affects
     * the order in which they will be layed out.
     *
     * Also notice that right aligned buttons should be ordered in the reverse
     * order in which they will actually appear. For example, using this:
     *
     *   playPauseButton|volume|progressInformationLabel|videoFullScreenButton
     *
     * Would render buttons as this:
     *
     *   playPauseButton   -----------------------  videoFullScreenButton  |  progressInformationLabel  |  volume
     *
     * While this:
     *
     *   playPauseButton|videoFullScreenButton|volume|progressInformationLabel
     *
     * Would render as:
     *
     *   playPauseButton   -----------------------  progressInformationLabel  | volume  |  videoFullScreenButton
     *
     * Only the order between buttons that have the same alignment will affect
     * rendering. You could do this:
     *
     *   videoFullScreenButton|volume|playPauseButton|progressInformationLabel
     *
     * And it would still render correctly:
     *
     *   playPauseButton   -----------------------  progressInformationLabel  | volume  |  videoFullScreenButton
     *
     * You may skip any button if you don't want it to be displayed:
     *
     *   playPauseButton|videoFullScreenButton
     *
     * Would render:
     *
     *   playPauseButton   -----------------------  videoFullScreenButton
     *
     * @default playPauseButton|videoFullScreenButton|volume|progressInformationLabel
     */
    public var controlBarButtons:Array;
    private static const DEFAULT_CONTROL_BAR_BUTTONS_LAYOUT:String = 'playPauseButton|videoFullScreenButton|volume|progressInformationLabel';

    /**
     * The number of seconds to buffer before start playing the video.
     */
    public var bufferTime:Number;

    /**
     * Default player width.
     */
    public var playerWidth:Number = 320;

    /**
     * Default player height.
     */
    public var playerHeight:Number = 240;


    private static var _instance:Configuration;
    private var rawParameters:Object;
    private var logger:Logger = Log.getLogger('Configuration');

    public static function getInstance():Configuration {
      if (_instance == null) {
        _instance = new Configuration();
      }
      return _instance;
    }

    public function Configuration() {
      // do nothing
    }

    public function readParameters(parameters:Object):void {
      this.rawParameters = parameters;

      logger.info('Loading configurations...');

      setupEnvironment();
      loadEnvironment();

      setupAutoPlay();
      setupControlBar();
      setupBufferTime();
      setupBaseRioServerURL();

      logger.info("Configurations loaded.");
    }

    private function setupEnvironment():void {
      environment = rawParameters.environment ? rawParameters.environment : 'production';
    }

    private function loadEnvironment():void {
      logger.info('Loading {0} environment configurations...', environment);
    }

    public function environmentConfig(configName:String):String {
      return defaultConfigsPerEnvironments[environment][configName];
    }

    private function setupAutoPlay():void {
      autoPlay = booleanValueOf(rawParameters.autoPlay, true);
    }

    private function setupControlBar():void {
      displayControlBar = booleanValueOf(rawParameters.displayControlBar, true);

      if (rawParameters.controlBarButtons) {
        controlBarButtons = rawParameters.controlBarButtons.split('|');
      } else {
        controlBarButtons = DEFAULT_CONTROL_BAR_BUTTONS_LAYOUT.split('|');
      }
    }

    private function setupBufferTime():void {
      bufferTime = new Number(rawParameters.bufferTime) || 3;
    }

    private function setupBaseRioServerURL():void {
      //http://edad.rnp.br/rioflashclient_test.php?xmlfile=/cederj/treinamento/parte2/cederj_treinamento_parte2.xml
      //http://edad.rnp.br/rioflashclient_test.php?xmlfile=/cederj_fisica/a_resistencia_do_ar/a_resistencia_do_ar.xml
		//"http://edad.rnp.br/redirect.rio?file=/cederj/sistemas_comp/ead05002/Aula_001/Aula_001.xml"
		var xmlfile:String = rawParameters.xmlfile || 'http://gtedad05.cos.ufrj.br/redirect.rio?file=/root/Aula_000/Aula_000.xml';
	  //var xmlfile:String = rawParameters.xmlfile || 'http://videoaula.rnp.br/redirect.rio?file=/ufrj/exemplos/treinamento_seedad_2010/treinamento_seedad_2010.xml';
      //'http://roxo.no-ip.com:3001/redirect.rio?file=/ufrj/palestras/hucff/palestra_nelson.xml';
      //xmlfile = "http://roxo.no-ip.com:3001/redirect.rio?file=/ufrj/palestras/hucff/palestra_nelson.xml";
      //xmlfile = "http://roxo.no-ip.com:3001/redirect.rio?file=/aula_ruby.xml";
      baseRioServerURL = xmlfile.slice(0, xmlfile.lastIndexOf('/') + 1);
      lessonXML = xmlfile.slice(xmlfile.lastIndexOf('/') + 1, xmlfile.length);
    }

    private function booleanValueOf(value:Object, defaultValue:Boolean):Boolean {
      if (value == 'true') {
        return true;
      } else if (value == 'false') {
        return false;
      } else {
        return defaultValue;
      }
    }

    public function formatTime(time:Number):String {
      var roundedTime:Number = Math.floor(time);
      var formattedTime:Array = [];

      if (roundedTime >= 3600) {
        formattedTime.push(fillWithZero(Math.floor(roundedTime/3600)));    // hours
      }

      formattedTime.push(fillWithZero(Math.floor((roundedTime%3600)/60))); // minutes
      formattedTime.push(fillWithZero(roundedTime%60));                    // seconds

      return formattedTime.join(':');
    }

    private function fillWithZero(number:Number):String {
      return number > 9 ? number.toString() : '0' + number;
    }

    public function resourceURL(resource:String, start:Number=0):String {
      var url:String = baseRioServerURL + resource;
      if (start != 0) {
        url += '?start=' + start;
      }
      return url;
    }
	
	public function getXMLPath():String
	{
		var startCut:Number = this.baseRioServerURL.indexOf("=");
		var path:String = this.baseRioServerURL.substring(startCut + 1);
		startCut = this.lessonXML.indexOf("=");
		var fileName:String = this.lessonXML.substring(startCut + 1);
		return path + fileName;
	}
  }
}
