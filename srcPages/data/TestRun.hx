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
	var time:Float;
}
