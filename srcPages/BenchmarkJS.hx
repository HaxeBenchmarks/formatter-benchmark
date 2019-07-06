import haxe.Http;
import js.Browser;
import js.jquery.JQuery;
import json2object.JsonParser;
import data.TestRun;

class BenchmarkJS {
	var haxe3Data:Null<ArchivedResults>;
	var haxe4Data:Null<ArchivedResults>;
	var documentLoaded:Bool;

	public static function main() {
		new BenchmarkJS();
	}

	public function new() {
		haxe3Data = null;
		haxe4Data = null;
		documentLoaded = false;
		requestArchivedData();
		new JQuery(Browser.document).ready(function() {
			documentLoaded = true;
			checkLoaded();
		});
	}

	function requestArchivedData() {
		var request:Http = new Http("data/archiveHaxe3.json");

		request.onData = function(data:String) {
			var parser:JsonParser<ArchivedResults> = new JsonParser<ArchivedResults>();
			haxe3Data = parser.fromJson(data, "archiveHaxe3.json");
			checkLoaded();
		}
		request.onData = function(msg:String) {
			trace("failed to download Haxe 3 data: " + msg);
		}
		request.request();

		var request:Http = new Http("data/archiveHaxe4.json");

		request.onData = function(data:String) {
			var parser:JsonParser<ArchivedResults> = new JsonParser<ArchivedResults>();
			haxe4Data = parser.fromJson(data, "archiveHaxe4.json");
			checkLoaded();
		}
		request.onData = function(msg:String) {
			trace("failed to download Haxe 4 data: " + msg);
		}
		request.request();
	}

	function checkLoaded() {
		if (haxe3Data == null) {
			return;
		}
		if (haxe4Data == null) {
			return;
		}
		if (!documentLoaded) {
			return;
		}
		showData();
	}

	function showData() {
		trace("showData");
		trace(haxe3Data);
		trace(haxe4Data);
	}
}
