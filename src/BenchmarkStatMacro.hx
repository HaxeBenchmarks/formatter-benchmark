import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;

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
		if (~/\.js$/.match(output)) {
			return "NodeJS";
		}
		if (~/\.hl$/.match(output)) {
			return "Hashlink";
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

		return "unknown";
	}
	#end
}
