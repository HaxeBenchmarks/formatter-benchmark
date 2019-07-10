import haxe.Http;
import js.Browser;
import js.Syntax;
import js.html.CanvasRenderingContext2D;
import js.html.CanvasElement;
import js.jquery.JQuery;
import js.jquery.Event;
import json2object.JsonParser;
import data.TestRun;
import data.ExponentialMovingAverage;
import data.IMovingAverage;
import data.SimpleMovingAverage;

class BenchmarkJS {
	var haxe3Data:Null<ArchivedResults>;
	var haxe4Data:Null<ArchivedResults>;
	var documentLoaded:Bool;
	var windowSize:Int;
	var averageFactory:(windowSize:Int) -> IMovingAverage;
	var withAverage:Bool;

	public static function main() {
		new BenchmarkJS();
	}

	public function new() {
		haxe3Data = null;
		haxe4Data = null;
		documentLoaded = false;
		windowSize = 6;
		averageFactory = SimpleMovingAverage.new;
		withAverage = true;
		requestArchivedData();
		new JQuery(Browser.document).ready(function() {
			documentLoaded = true;
			checkLoaded();
		});
		new JQuery("#average").change(changeAverage);
		new JQuery("#averageWindow").change(changeAverageWindow);
	}

	function changeAverage(event:Event) {
		switch (new JQuery("#average").val()) {
			case "SMA":
				withAverage = true;
				averageFactory = SimpleMovingAverage.new;
			case "EMA":
				withAverage = true;
				averageFactory = ExponentialMovingAverage.new;
			default:
				withAverage = false;
				averageFactory = SimpleMovingAverage.new;
		}
		showData();
	}

	function changeAverageWindow(event:Event) {
		windowSize = Std.parseInt(new JQuery("#averageWindow").val());
		changeAverage(event);
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
		showHistory(HashlinkC, "hlcBenchmarks");
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
			datasets: [haxe3Dataset, haxe4Dataset, haxe4ES6Dataset]
		};
		for (target in latestHaxe3Data.targets) {
			var index:Int = data.labels.indexOf(target.name);
			if (index < 0) {
				continue;
			}
			if (target.name == Jvm) {
				continue;
			}
			haxe3Dataset.data[index] = target.time;
		}
		for (target in latestHaxe4Data.targets) {
			var index:Int = data.labels.indexOf(target.name);
			if (index < 0) {
				continue;
			}
			haxe4Dataset.data[index] = target.time;
			if (target.name == NodeJs) {
				var time:Null<Float> = getHistoryTime(latestHaxe4Data, NodeJsEs6);
				haxe4ES6Dataset.data[index] = time;
			}
		}
		var ctx:CanvasRenderingContext2D = cast(Browser.document.getElementById("latestBenchmarks"), CanvasElement).getContext("2d");

		var options = {
			type: "bar",
			data: data,
			options: {
				responsive: true,
				animation: {
					duration: 0
				},
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
		var haxe3SMADataset = {
			label: target + " (Haxe 3 avg)",
			backgroundColor: "#FFCCCC",
			borderColor: "#FFCCCC",
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
		var haxe4SMADataset = {
			label: target + " (Haxe 4 avg)",
			backgroundColor: "#CCCCFF",
			borderColor: "#CCCCFF",
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
		var haxe4ES6SMADataset = {
			label: target + " (Haxe 4 (ES6) avg)",
			backgroundColor: "#CCFFCC",
			borderColor: "#CCFFCC",
			borderWidth: 1,
			fill: false,
			spanGaps: true,
			data: []
		};
		var data = {
			labels: [],
			datasets: []
		};
		if (withAverage) {
			data.datasets = [haxe3Dataset, haxe3SMADataset, haxe4Dataset, haxe4SMADataset];
		} else {
			data.datasets = [haxe3Dataset, haxe4Dataset];
		}
		if (target == Jvm) {
			data.datasets = [haxe4Dataset];
			if (withAverage) {
				data.datasets.push(haxe4SMADataset);
			}
		}
		if (target == NodeJs) {
			data.datasets.push(haxe4ES6Dataset);
			if (withAverage) {
				data.datasets.push(haxe4ES6SMADataset);
			}
		}

		var datasetData:Array<HistoricalDataPoint> = [];
		var average:IMovingAverage = averageFactory(windowSize);
		for (run in haxe3Data) {
			var time:Null<Float> = getHistoryTime(run, target);
			if (time == null) {
				continue;
			}
			average.addValue(time);
			datasetData.push({
				time: time,
				sma: average.getAverage(),
				date: run.date,
				dataset: Haxe3
			});
		}
		var average:IMovingAverage = averageFactory(windowSize);
		var average2:IMovingAverage = averageFactory(windowSize);
		for (run in haxe4Data) {
			var time:Null<Float> = getHistoryTime(run, target);
			if (time == null) {
				continue;
			}
			var time2:Null<Float> = null;
			if (target == NodeJs) {
				time2 = getHistoryTime(run, NodeJsEs6);
			}
			average.addValue(time);
			average2.addValue(time2);
			datasetData.push({
				time: time,
				sma: average.getAverage(),
				time2: time2,
				sma2: average2.getAverage(),
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
					haxe3SMADataset.data.push(item.sma);
					haxe4Dataset.data.push(null);
					haxe4SMADataset.data.push(null);
					haxe4ES6Dataset.data.push(null);
					haxe4ES6SMADataset.data.push(null);
				case Haxe4:
					haxe3Dataset.data.push(null);
					haxe3SMADataset.data.push(null);
					haxe4Dataset.data.push(item.time);
					haxe4SMADataset.data.push(item.sma);
					haxe4ES6Dataset.data.push(item.time2);
					haxe4ES6SMADataset.data.push(item.sma2);
			}
		}

		var ctx:CanvasRenderingContext2D = cast(Browser.document.getElementById(canvasId), CanvasElement).getContext("2d");
		var options = {
			type: "line",
			data: data,
			options: {
				responsive: true,
				animation: {
					duration: 0
				},
				legend: {
					position: "top",
				},
				title: {
					display: true,
					text: '$target benchmark results'
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

	function sortDate(a:HistoricalDataPoint, b:HistoricalDataPoint):Int {
		if (a.date > b.date) {
			return 1;
		}
		if (a.date < b.date) {
			return -1;
		}
		return 0;
	}

	function getHistoryTime(testRun:TestRun, target:Target):Null<TimeValue> {
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
	var HashlinkC = "Hashlink/C";
	var Java = "Java";
	var Jvm = "JVM";
	var Neko = "Neko";
	var NodeJs = "NodeJS";
	var NodeJsEs6 = "NodeJS (ES6)";
	var Php = "PHP";
	var Python = "Python";
}

typedef HistoricalDataPoint = {
	var time:TimeValue;
	var sma:TimeValue;
	var ?time2:TimeValue;
	var ?sma2:TimeValue;
	var date:String;
	var dataset:Dataset;
}
