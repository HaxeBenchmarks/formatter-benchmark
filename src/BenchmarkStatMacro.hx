class BenchmarkStatMacro {
	#if macro
	public static function init() {
		Compiler.addMetadata('@:build(BenchmarkStatMacro.benchmarkCli())', "formatter.Cli");
	}

	public static function benchmarkCli():Array<Field> {
		var fields = Context.getBuildFields();
		var newFields:Array<Field> = [];
		for (field in fields) {
			if (field.name == "printStats") {
				continue;
			}
			newFields.push(field);
		}

		var target:String = HaxeVersionsMacro.mapOutput2Target();

		newFields.push((macro class {
			function printStats(duration:Float) {
				var version:String = FormatterVersion.getFormatterVersion();
				Sys.println($v{target} + ";" + version + ";" + Std.string(formatter.FormatStats.totalLinesOrig) + ";"
					+ Std.string(formatter.FormatStats.totalLinesFormatted) + ";" + Std.string(duration));
			}
		}).fields[0]);

		return newFields;
	}
	#end

	macro public static function getSources(path:String):Expr {
		#if !display
		try {
			var sources:Array<String> = [];

			var folderFunc:String->Void;
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

			return macro $v{sources};
		} catch (e:Any) {
			var version:String = "dev";
			return macro $v{version};
		}
		#else
		return macro [
			"
class Main {
	public function new() {
    }
}"
		];
		#end
	}
}
