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
	var haxeNightlyData:Null<ArchivedResults>;
	var documentLoaded:Bool;
	var windowSize:Int;
	var averageFactory:(windowSize:Int) -> IMovingAverage;
	var showAverage:ShowAverage;
	var withHaxe3:Bool;
	var withHaxe4:Bool;
	var withHaxeNightly:Bool;
	var chartObjects:Map<String, Any>;

	public static function main() {
		new BenchmarkJS();
	}

	public function new() {
		haxe3Data = null;
		haxe4Data = null;
		haxeNightlyData = null;
		documentLoaded = false;
		windowSize = 6;
		averageFactory = SimpleMovingAverage.new;
		showAverage = DataAndAverage;
		withHaxe3 = true;
		withHaxe4 = true;
		withHaxeNightly = true;
		chartObjects = new Map<String, Any>();
		requestArchivedData();
		new JQuery(Browser.document).ready(function() {
			documentLoaded = true;
			checkLoaded();
		});
		new JQuery("#onlyAverage").change(changeOnlyAverage);
		new JQuery("#average").change(changeAverage);
		new JQuery("#averageWindow").change(changeAverageWindow);
		new JQuery("#withHaxe3").change(changeWithHaxe3);
		new JQuery("#withHaxe4").change(changeWithHaxe4);
		new JQuery("#withHaxeNightly").change(changeWithHaxeNightly);
	}

	function changeOnlyAverage(event:Event) {
		var show:Bool = new JQuery("#onlyAverage").is(":checked");
		if (show) {
			switch (showAverage) {
				case JustData:
					showAverage = OnlyAverage;
				case OnlyAverage:
				case DataAndAverage:
					showAverage = OnlyAverage;
			}
		} else {
			switch (showAverage) {
				case JustData:
				case OnlyAverage:
					showAverage = DataAndAverage;
				case DataAndAverage:
			}
		}
		showData();
	}

	function changeWithHaxe3(event:Event) {
		withHaxe3 = new JQuery("#withHaxe3").is(":checked");
		showData();
	}

	function changeWithHaxe4(event:Event) {
		withHaxe4 = new JQuery("#withHaxe4").is(":checked");
		showData();
	}

	function changeWithHaxeNightly(event:Event) {
		withHaxeNightly = new JQuery("#withHaxeNightly").is(":checked");
		showData();
	}

	function changeAverage(event:Event) {
		switch (new JQuery("#average").val()) {
			case "SMA":
				switch (showAverage) {
					case JustData:
						showAverage = DataAndAverage;
					case OnlyAverage:
					case DataAndAverage:
				}
				averageFactory = SimpleMovingAverage.new;
			case "EMA":
				switch (showAverage) {
					case JustData:
						showAverage = DataAndAverage;
					case OnlyAverage:
					case DataAndAverage:
				}
				averageFactory = ExponentialMovingAverage.new;
			default:
				switch (showAverage) {
					case JustData:
					case OnlyAverage:
						showAverage = JustData;
					case DataAndAverage:
						showAverage = JustData;
				}
				new JQuery("#onlyAverage").prop("checked", false);
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

		var request:Http = new Http("data/archiveHaxeNightly.json");
		request.onData = function(data:String) {
			var parser:JsonParser<ArchivedResults> = new JsonParser<ArchivedResults>();
			haxeNightlyData = parser.fromJson(data, "archiveHaxeNightly.json");
			checkLoaded();
			trace(haxeNightlyData);
		}
		request.onError = function(msg:String) {
			trace("failed to download Haxe 3 data: " + msg);
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
		if (haxeNightlyData == null) {
			return;
		}
		if (!documentLoaded) {
			return;
		}
		showData();
	}

	function showData() {
		showLatest();
		showLinesOfCode();
		showHistory(Cpp, "cppBenchmarks");
		showHistory(Java, "javaBenchmarks");
		showHistory(Jvm, "jvmBenchmarks");
		showHistory(Hashlink, "hlBenchmarks");
		showHistory(HashlinkC, "hlcBenchmarks");
		showHistory(Csharp, "csharpBenchmarks");
		showHistory(NodeJs, "nodeBenchmarks");
		showHistory(NodeJsEs6, "nodeES6Benchmarks");
		showHistory(Neko, "nekoBenchmarks");
		showHistory(Eval, "evalBenchmarks");
		showHistory(Php, "phpBenchmarks");
		showHistory(Python, "pythonBenchmarks");
	}

	function showLatest() {
		var latestHaxe3Data:TestRun = haxe3Data[haxe3Data.length - 1];
		var latestHaxe4Data:TestRun = haxe4Data[haxe4Data.length - 1];
		var latestHaxeNightlyData:TestRun = haxeNightlyData[haxeNightlyData.length - 1];
		var labels:Array<String> = [
			Cpp, Csharp, Hashlink, HashlinkC, Java, Jvm, Neko, NodeJs, NodeJsEs6, Eval, Php, Python
		];

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

		var haxeNightlyDataset = {
			label: latestHaxeNightlyData.haxeVersion,
			backgroundColor: "#030027",
			borderColor: "#0000FF",
			borderWidth: 1,
			data: [for (label in labels) null]
		};

		var data = {
			labels: labels,
			datasets: [haxe3Dataset, haxe4Dataset, haxeNightlyDataset]
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
		}
		for (target in latestHaxeNightlyData.targets) {
			var index:Int = data.labels.indexOf(target.name);
			if (index < 0) {
				continue;
			}
			haxeNightlyDataset.data[index] = target.time;
		}

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
		if (!chartObjects.exists("latest")) {
			var ctx:CanvasRenderingContext2D = cast(Browser.document.getElementById("latestBenchmarks"), CanvasElement).getContext("2d");
			var chart:Any = Syntax.code("new Chart({0}, {1})", ctx, options);
			chartObjects.set("latest", chart);
			return;
		}
		var chart:Any = chartObjects.get("latest");
		untyped chart.data = data;
		Syntax.code("{0}.update()", chart);
	}

	function showLinesOfCode() {
		var inputDataset = {
			label: "Input lines",
			backgroundColor: "#FF6666",
			borderColor: "#FF0000",
			borderWidth: 1,
			fill: false,
			spanGaps: true,
			data: []
		};

		var outputDataset = {
			label: "Formatted lines",
			backgroundColor: "#6666FF",
			borderColor: "#0000FF",
			borderWidth: 1,
			fill: false,
			spanGaps: true,
			data: []
		};

		var data = {
			labels: [],
			datasets: [inputDataset, outputDataset]
		};

		for (run in haxe4Data) {
			for (runTarget in run.targets) {
				if (runTarget.name != NodeJs) {
					continue;
				}
				data.labels.push(run.date);
				inputDataset.data.push(runTarget.inputLines);
				outputDataset.data.push(runTarget.outputLines);
			}
		}
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
					text: 'LInes of Code'
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
								labelString: "lines of code"
							}
						}
					]
				}
			}
		};
		if (!chartObjects.exists("linesOfCode")) {
			var ctx:CanvasRenderingContext2D = cast(Browser.document.getElementById("linesOfCode"), CanvasElement).getContext("2d");
			var chart:Any = Syntax.code("new Chart({0}, {1})", ctx, options);
			chartObjects.set("linesOfCode", chart);
			return;
		}
		var chart:Any = chartObjects.get("linesOfCode");
		untyped chart.data = data;
		Syntax.code("{0}.update()", chart);
	}

	function showHistory(target:Target, canvasId:String) {
		var graphDataSets:Array<GraphDatasetInfo> = makeGraphDatasets(target);

		graphDataSets = graphDataSets.filter(function(info:GraphDatasetInfo):Bool {
			if ((info.type == Haxe3) && (target == Jvm || target == Eval || target == NodeJsEs6)) {
				return false;
			}
			switch showAverage {
				case JustData:
					if (info.movingAverage) {
						return false;
					}
				case OnlyAverage:
					if (!info.movingAverage) {
						return false;
					}
				case DataAndAverage:
			}
			return true;
		});

		var data = {
			labels: [],
			datasets: []
		};

		var datasetData:Array<HistoricalDataPoint> = [];
		if (withHaxe3) {
			datasetData = datasetData.concat(collectRunData(target, haxe3Data, Haxe3));
		}
		if (withHaxe4) {
			datasetData = datasetData.concat(collectRunData(target, haxe4Data, Haxe4));
		}
		if (withHaxeNightly) {
			datasetData = datasetData.concat(collectRunData(target, haxeNightlyData, HaxeNightly));
		}
		datasetData.sort(sortDate);
		datasetData = mergeTimes(datasetData);

		data.datasets = graphDataSets.map(item -> item.dataset);

		for (item in datasetData) {
			data.labels.push(item.date);
			for (graph in graphDataSets) {
				if (graph.movingAverage) {
					graph.dataset.data.push(item.sma.get(graph.type));
				} else {
					graph.dataset.data.push(item.time.get(graph.type));
				}
			}
		}

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
		if (!chartObjects.exists(target)) {
			var ctx:CanvasRenderingContext2D = cast(Browser.document.getElementById(canvasId), CanvasElement).getContext("2d");
			var chart:Any = Syntax.code("new Chart({0}, {1})", ctx, options);
			chartObjects.set(target, chart);
			return;
		}
		var chart:Any = chartObjects.get(target);
		untyped chart.data = data;
		Syntax.code("{0}.update()", chart);
	}

	function mergeTimes(datasetData:Array<HistoricalDataPoint>):Array<HistoricalDataPoint> {
		var result:Array<HistoricalDataPoint> = [];
		var lastDataPoint:Null<HistoricalDataPoint> = null;
		for (data in datasetData) {
			if (lastDataPoint == null) {
				lastDataPoint = data;
				result.push(data);
				continue;
			}
			if (lastDataPoint.date.substr(0, lastDataPoint.date.length - 2) != data.date.substr(0, data.date.length - 2)) {
				lastDataPoint = data;
				result.push(data);
				continue;
			}
			for (key => val in data.time) {
				lastDataPoint.time.set(key, val);
			}
			for (key => val in data.sma) {
				lastDataPoint.sma.set(key, val);
			}
		}
		trace(result);
		return result;
	}

	function collectRunData(target:Target, resultsData:ArchivedResults, type:DatasetType):Array<HistoricalDataPoint> {
		var average:IMovingAverage = averageFactory(windowSize);
		var datasetData:Array<HistoricalDataPoint> = [];
		for (run in resultsData) {
			var time:Null<Float> = getHistoryTime(run, target);
			if (time == null) {
				continue;
			}
			average.addValue(time);
			datasetData.push({
				time: [type => time],
				sma: [type => average.getAverage()],
				date: run.date
			});
		}
		return datasetData;
	}

	function makeGraphDatasets(target:Target):Array<GraphDatasetInfo> {
		return [
			makeGraphDataset(Haxe3, false, target + " (Haxe 3)", "#FF0000", "#FF0000"),
			makeGraphDataset(Haxe3, true, target + " (Haxe 3 avg)", "#FFCCCC", "#FFCCCC"),
			makeGraphDataset(Haxe4, false, target + " (Haxe 4)", "#0000FF", "#0000FF"),
			makeGraphDataset(Haxe4, true, target + " (Haxe 4 avg)", "#CCCCFF", "#CCCCFF"),
			makeGraphDataset(HaxeNightly, false, target + " (Haxe nightly)", "#030027", "#030027"),
			makeGraphDataset(HaxeNightly, true, target + " (Haxe nightly avg)", "#8888FF", "#8888FF"),
		];
	}

	function makeGraphDataset(type:DatasetType, movingAverage:Bool, label:String, borderColor:String, backgroundColor:String):GraphDatasetInfo {
		return {
			type: type,
			movingAverage: movingAverage,
			dataset: {
				label: label,
				backgroundColor: backgroundColor,
				borderColor: borderColor,
				borderWidth: 1,
				fill: false,
				spanGaps: true,
				data: []
			}
		}
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
	var Eval = "eval";
}

typedef HistoricalDataPoint = {
	var time:Map<DatasetType, TimeValue>;
	var sma:Map<DatasetType, TimeValue>;
	var date:String;
}

enum ShowAverage {
	JustData;
	OnlyAverage;
	DataAndAverage;
}

typedef GraphDatasetInfo = {
	var type:DatasetType;
	var movingAverage:Bool;
	var dataset:GraphDataset;
}

typedef GraphDataset = {
	var label:String;
	var backgroundColor:String;
	var borderColor:String;
	var borderWidth:Int;
	var fill:Bool;
	var spanGaps:Bool;
	var data:Array<TimeValue>;
}
