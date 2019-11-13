import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import haxe.Timer;
import formatter.Formatter;
import formatter.config.Config;
import tokentree.TokenTreeBuilder.TokenTreeEntryPoint;

class NoIOMain {
	public function new() {
		// segmentation faults in C++
		// var sources:Array<String> = BenchmarkStatMacro.getSources("dataNoIO");

		var sources:Array<String> = getSources("dataNoIO");
		var config:Config = new Config();
		var config2:Config = new Config();
		config2.lineEnds.leftCurly = Both;

		var startTime = Timer.stamp();
		for (i in 0...30) {
			for (src in sources) {
				Formatter.format(Code(src), config, null, TokenTreeEntryPoint.TYPE_LEVEL);
				Formatter.format(Code(src), config2, null, TokenTreeEntryPoint.TYPE_LEVEL);
			}
		}
		printStats(Timer.stamp() - startTime);
	}

	function getSources(path:String):Array<String> {
		var sources:Array<String> = [];

		var folderFunc:(path:String) -> Void;
		folderFunc = function(path:String):Void {
			for (f in FileSystem.readDirectory(path)) {
				var fileName:String = Path.join([path, f]);
				if (FileSystem.isDirectory(fileName)) {
					folderFunc(fileName);
					continue;
				}
				sources.push(File.getContent(fileName));
			}
		}
		folderFunc(path);
		return sources;
	}

	function printStats(duration:Float) {
		var target = BenchmarkStatMacro.mapOutput2Target();
		var version:String = FormatterVersion.getFormatterVersion();
		Sys.println('$target;$version;${Std.string(formatter.FormatStats.totalLinesOrig)};'
			+ '${Std.string(formatter.FormatStats.totalLinesFormatted)};${Std.string(duration)}');
	}

	static function main() {
		try {
			new NoIOMain();
		} catch (e:Any) {
			trace(e);
		}
	}
}
