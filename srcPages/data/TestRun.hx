package data;

typedef ArchivedResults = Array<TestRun>;

typedef TestRun = {
	var haxeVersion:String;
	var date:String;
	var targets:Array<TargetResult>;
}

typedef TargetResult = {
	var name:String;
	var inputLines:Int;
	var outputLines:Int;
	var time:TimeValue;
}

enum DatasetType {
	Haxe3;
	Haxe4;
	HaxeNightly;
}

abstract TimeValue(Float) to Float {
	function new(value:Float) {
		this = value;
	}

	@:from
	public static function fromFloat(value:Null<Float>):Null<TimeValue> {
		if (value == null) {
			return null;
		}
		return new TimeValue(Math.round(value * 1000) / 1000);
	}
}
