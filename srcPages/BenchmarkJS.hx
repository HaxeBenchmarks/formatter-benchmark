import haxe.Http;
import js.Browser;
import js.Syntax;
import js.html.CanvasRenderingContext2D;
import js.html.CanvasElement;
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
		request.onError = function(msg:String) {
			trace("failed to download Haxe 3 data: " + msg);
		}
		request.request();

		var request:Http = new Http("data/archiveHaxe4.json");

		request.onData = function(data:String) {
			var parser:JsonParser<ArchivedResults> = new JsonParser<ArchivedResults>();
			haxe4Data = parser.fromJson(data, "archiveHaxe4.json");
			checkLoaded();
		}
		request.onError = function(msg:String) {
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
		showLatest();
		showHistory(Cpp, "cppBenchmarks");
		showHistory(Java, "javaBenchmarks");
		showHistory(Jvm, "jvmBenchmarks");
		showHistory(Hashlink, "hlBenchmarks");
		showHistory(Csharp, "csharpBenchmarks");
		showHistory(NodeJs, "nodeBenchmarks");
		showHistory(Neko, "nekoBenchmarks");
		showHistory(Php, "phpBenchmarks");
		showHistory(Python, "pythonBenchmarks");
	}

	function showLatest() {
		var latestHaxe3Data:TestRun = haxe3Data[haxe3Data.length - 1];
		var latestHaxe4Data:TestRun = haxe4Data[haxe4Data.length - 1];
		var labels:Array<String> = [Cpp, Csharp, Hashlink, Java, Jvm, Neko, NodeJs, Php, Python];

		var haxe3Dataset = {
			label: latestHaxe3Data.haxeVersion,
			backgroundColor: "#FF6666",
			borderColor: "#FF0000",
			borderWidth: 1,
			data: [for (label in labels) null]
		};

		var haxe4Dataset = {
			label: latestHaxe4Data.haxeVersion,
			backgroundColor: "#6666FF",
			borderColor: "#0000FF",
			borderWidth: 1,
			data: [for (label in labels) null]
		};

		var haxe4ES6Dataset = {
			label: latestHaxe4Data.haxeVersion + " (ES6)",
			backgroundColor: "#66FF66",
			borderColor: "#00FF00",
			borderWidth: 1,
			data: [for (label in labels) null]
		};

		var data = {
			labels: labels,
			datasets: [haxe3Dataset, haxe4Dataset]
		};
		for (target in latestHaxe3Data.targets) {
			var index:Int = data.labels.indexOf(target.name);
			if (index < 0) {
				continue;
			}
			if (target.name == Jvm) {
				continue;
			}
			haxe3Dataset.data[index] = Math.round(target.time * 1000) / 1000;
		}
		for (target in latestHaxe4Data.targets) {
			var index:Int = data.labels.indexOf(target.name);
			if (index < 0) {
				continue;
			}
			haxe4Dataset.data[index] = Math.round(target.time * 1000) / 1000;
			if (target.name == NodeJs) {
				var time:Null<Float> = getHistoryTime(latestHaxe4Data, NodeJsEs6);
				haxe4ES6Dataset.data[index] = Math.round(time * 1000) / 1000;
			}
		}
		var ctx:CanvasRenderingContext2D = cast(Browser.document.getElementById("latestBenchmarks"), CanvasElement).getContext("2d");

		var options = {
			type: "bar",
			data: data,
			options: {
				responsive: true,
				legend: {
					position: "top",
				},
				title: {
					display: true,
					text: "latest benchmark results"
				},
				tooltips: {
					mode: "index",
					intersect: false
				},
				hover: {
					mode: "nearest",
					intersect: true
				},
				scales: {
					yAxes: [
						{
							scaleLabel: {
								display: true,
								labelString: "runtime in seconds"
							}
						}
					]
				}
			}
		};
		Syntax.code("new Chart ({0}, {1})", ctx, options);
	}

	function showHistory(target:Target, canvasId:String) {
		var haxe3Dataset = {
			label: target + " (Haxe 3)",
			backgroundColor: "#FF6666",
			borderColor: "#FF0000",
			borderWidth: 1,
			fill: false,
			spanGaps: true,
			data: []
		};

		var haxe4Dataset = {
			label: target + " (Haxe 4)",
			backgroundColor: "#6666FF",
			borderColor: "#0000FF",
			borderWidth: 1,
			fill: false,
			spanGaps: true,
			data: []
		};
		var haxe4ES6Dataset = {
			label: target + " (Haxe 4 (ES6))",
			backgroundColor: "#66FF66",
			borderColor: "#00FF00",
			borderWidth: 1,
			fill: false,
			spanGaps: true,
			data: []
		};
		var data = {
			labels: [],
			datasets: [haxe3Dataset, haxe4Dataset]
		};
		if (target == Jvm) {
			data.datasets = [haxe4Dataset];
		}
		if (target == NodeJs) {
			data.datasets.push(haxe4ES6Dataset);
		}

		var datasetData:Array<HistoricalDataPoint> = [];
		for (run in haxe3Data) {
			var time:Null<Float> = getHistoryTime(run, target);
			if (time == null) {
				continue;
			}
			datasetData.push({
				time: Math.round(time * 1000) / 1000,
				date: run.date,
				dataset: Haxe3
			});
		}
		for (run in haxe4Data) {
			var time:Null<Float> = getHistoryTime(run, target);
			if (time == null) {
				continue;
			}
			var time2:Null<Float> = null;
			if (target == NodeJs) {
				time2 = getHistoryTime(run, NodeJsEs6);
			}
			datasetData.push({
				time: Math.round(time * 1000) / 1000,
				time2: Math.round(time2 * 1000) / 1000,
				date: run.date,
				dataset: Haxe4
			});
		}
		datasetData.sort(sortDate);
		for (item in datasetData) {
			data.labels.push(item.date);
			switch (item.dataset) {
				case Haxe3:
					haxe3Dataset.data.push(item.time);
					haxe4Dataset.data.push(null);
					haxe4ES6Dataset.data.push(null);
				case Haxe4:
					haxe3Dataset.data.push(null);
					haxe4Dataset.data.push(item.time);
					haxe4ES6Dataset.data.push(item.time2);
			}
		}

		var ctx:CanvasRenderingContext2D = cast(Browser.document.getElementById(canvasId), CanvasElement).getContext("2d");
		var options = {
			type: "line",
			data: data,
			options: {
				responsive: true,
				legend: {
					position: "top",
				},
				title: {
					display: true,
					text: '$target benchmark results'
				},
				scales: {
					yAxes: [
						{
							scaleLabel: {
								display: true,
								labelString: "runtime in seconds"
							}
						}
					]
				}
			}
		};
		Syntax.code("new Chart ({0}, {1})", ctx, options);
	}

	function sortDate(a:HistoricalDataPoint, b:HistoricalDataPoint):Int {
		if (a.date > b.date) {
			return 1;
		}
		if (a.date < b.date) {
			return -1;
		}
		return 0;
	}

	function getHistoryTime(testRun:TestRun, target:Target):Null<Float> {
		for (runTarget in testRun.targets) {
			if (target == runTarget.name) {
				return runTarget.time;
			}
		}
		return null;
	}
}

@:enum
abstract Target(String) to String {
	var Cpp = "C++";
	var Csharp = "C#";
	var Hashlink = "Hashlink";
	var Java = "Java";
	var Jvm = "JVM";
	var Neko = "Neko";
	var NodeJs = "NodeJS";
	var NodeJsEs6 = "NodeJS (ES6)";
	var Php = "PHP";
	var Python = "Python";
}

typedef HistoricalDataPoint = {
	var time:Float;
	var ?time2:Float;
	var date:String;
	var dataset:Dataset;
}
