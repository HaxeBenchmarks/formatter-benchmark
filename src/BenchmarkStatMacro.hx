import haxe.io.Path;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;

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

		var target:String = mapOutput2Target();

		newFields.push((macro class {
			function printStats(duration:Float) {
				var version:String = FormatterVersion.getFormatterVersion();
				Sys.println($v{target} + ";" + version + ";" + Std.string(formatter.FormatStats.totalLinesOrig) + ";"
					+ Std.string(formatter.FormatStats.totalLinesFormatted) + ";" + Std.string(duration));
			}
		}).fields[0]);

		return newFields;
	}

	static function mapOutput2Target():String {
		var output = Compiler.getOutput();

		if (~/\.n$/.match(output)) {
			return "Neko";
		}
		if (~/\.es6\.js$/.match(output)) {
			return "NodeJS (ES6)";
		}
		if (~/\.js$/.match(output)) {
			return "NodeJS";
		}
		if (~/\.hl$/.match(output)) {
			return "Hashlink";
		}
		if (~/\.c$/.match(output)) {
			return "Hashlink/C";
		}
		if (~/cpp$/.match(output)) {
			return "C++";
		}
		if (~/cs$/.match(output)) {
			return "C#";
		}
		if (~/java$/.match(output)) {
			return "Java";
		}
		if (~/jvm$/.match(output)) {
			return "JVM";
		}
		if (~/php$/.match(output)) {
			return "PHP";
		}
		if (~/\.py$/.match(output)) {
			return "Python";
		}
		return "eval";
	}
	#end

	macro public static function macroMapOutput2Target():Expr {
		var output = Compiler.getOutput();

		if (~/\.n$/.match(output)) {
			return macro "Neko";
		}
		if (~/\.es6\.js$/.match(output)) {
			return macro "NodeJS (ES6)";
		}
		if (~/\.js$/.match(output)) {
			return macro "NodeJS";
		}
		if (~/\.hl$/.match(output)) {
			return macro "Hashlink";
		}
		if (~/\.c$/.match(output)) {
			return macro "Hashlink/C";
		}
		if (~/cpp$/.match(output)) {
			return macro "C++";
		}
		if (~/cs$/.match(output)) {
			return macro "C#";
		}
		if (~/java$/.match(output)) {
			return macro "Java";
		}
		if (~/jvm$/.match(output)) {
			return macro "JVM";
		}
		if (~/php$/.match(output)) {
			return macro "PHP";
		}
		if (~/\.py$/.match(output)) {
			return macro "Python";
		}
		return macro "eval";
	}

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
