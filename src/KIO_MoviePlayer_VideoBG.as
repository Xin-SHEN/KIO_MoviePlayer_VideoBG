package
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.MP3Loader;
	import com.greensock.loading.SWFLoader;
	import com.greensock.loading.VideoLoader;
	import com.greensock.loading.XMLLoader;
	import com.greensock.loading.display.ContentDisplay;
	import com.kio.tools.display.KioSprite;
	import com.kio.tools.udp.UDPReceivedDataEvent;
	
	import flash.desktop.NativeApplication;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	
	[SWF(backgroundColor="#000000", frameRate="30",width="5760",height="1200")] //1792_896 / 1664
	public class KIO_MoviePlayer_VideoBG extends KioSprite
	{
		//loading sequence
		private var loaderMax:LoaderMax;		
		private var xmlConfig:XML;	
		
		private var ipLoader:VideoLoader;
		private var ipMovie:ContentDisplay;
		private var bg:ContentDisplay;
		
		private var bgLoader:VideoLoader;
		private var bgMovie:ContentDisplay;
		
		private var repeatCount:int = -1;
		private var playedCount:int = 0;
		
		public function KIO_MoviePlayer_VideoBG()
		{
			super("视频播放器",55555,0,true,false,true);	
			this.addEventListener(Event.ADDED_TO_STAGE,initXML);
		}
		
		//读取XML
		private function initXML(e:Event):void{
			LoaderMax.activate([ImageLoader, SWFLoader, VideoLoader, MP3Loader]);
			loaderMax = new LoaderMax({onComplete:initStage});
			loaderMax.append(new XMLLoader("config.xml",{name:"xmlConfigCom"}));
			loaderMax.load();	
		}
		
		private function initStage(e:LoaderEvent):void{		
			xmlConfig = LoaderMax.getContent("xmlConfigCom");	
			
			//通信设置
			initUDP(parseInt(xmlConfig.UDP[0].Port[0]),0);
			
			//背景图片设置
			bg = LoaderMax.getContent("preface"); 
			this.addChild(bg);
			bg.visible = false;
			
			//影片设置
			repeatCount = parseInt(xmlConfig.LoaderMax[0].VideoLoader[0].@repeat);
			ipLoader = LoaderMax.getLoader("movie");
			ipMovie = LoaderMax.getContent("movie");
			this.addChild(ipMovie);
			
			//欢迎界面
			bgLoader = LoaderMax.getLoader("moviebg");
			bgMovie = LoaderMax.getContent("moviebg");
			this.addChild(bgMovie);
			bgLoader.gotoVideoTime(0,true);
			
			ipLoader.addEventListener(VideoLoader.VIDEO_COMPLETE,OnVideoComplete);
			if(xmlConfig.LoaderMax[0].VideoLoader[0].@autoPlay=="false") ipMovie.visible = false;
		}		
		
		private function OnVideoComplete(event:LoaderEvent):void{
			if(repeatCount==-1) return;	
			else{
				trace("aaa");
				ipMovie.visible = false;
//				bg.visible = false;
				bgLoader.pauseVideo();
				bgMovie.visible = false;
			}
			//			if(++playedCount>repeatCount)
			//				{
			//					ipMovie.visible = false; //如果影片停止播放
			//					playedCount = 0;
			//				}
		}
		
		protected override function socketDataReceived(evt:UDPReceivedDataEvent):void
		{
			//			trace("received:"+evt.data);
			evt.data = evt.data.toLowerCase();	
			switch(evt.data){
				case "replay":	
					ipMovie.visible = true;
					ipLoader.gotoVideoTime(0,true);
//					bg.visible = false;
					bgLoader.pauseVideo();
					bgMovie.visible = false;
					bg.visible = false;
					break;
				case "play":
					ipMovie.visible = true;
					ipLoader.playVideo();
//					bg.visible = false;
					bgLoader.pauseVideo();
					bgMovie.visible = false;
					bg.visible = false;
					break;
				case "stop":
					ipLoader.pauseVideo();
					ipMovie.visible = false;
//					bg.visible = true;
					bgMovie.visible = true;
					bgLoader.gotoVideoTime(0,true);
					bg.visible = false;
					break;
				case "pause":
					ipLoader.pauseVideo();
					bg.visible = false;
					break;
				case "preface":
					ipLoader.pauseVideo();
					ipMovie.visible = false;
					bg.visible = true;
					bgMovie.visible = false;
					bgLoader.pauseVideo();
					break;
				case "volumedown":
					ipLoader.volume -=0.1;
					if(ipLoader.volume <0)
						ipLoader.volume = 0;
					break;
				case "volumeup":
					ipLoader.volume +=0.1;
					if(ipLoader.volume >1)
						ipLoader.volume = 1;
					break;
			}
		}
	}
}

