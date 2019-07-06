package data;

using StringTools;

class CSVReader {
	private static var quote:Int = '"'.fastCodeAt(0);
	private static var escape:Int = "\\".fastCodeAt(0);
	private static var semikolon:Int = ";".fastCodeAt(0);
	private static var comma:Int = ",".fastCodeAt(0);
	private static var tab:Int = "\t".fastCodeAt(0);
	private static var endR:Int = "\r".fastCodeAt(0);
	private static var endN:Int = "\n".fastCodeAt(0);

	private var csvData:String;
	private var csvDataLen:Int;
	private var pos:Int;
	private var lineBreakConsumed:Bool;
	private var delimiter:Int;
	private var trimFields:Bool;

	public function new(csvData:String, trimFields:Bool = true) {
		pos = 0;
		delimiter = -1;
		lineBreakConsumed = true;
		this.trimFields = trimFields;
		if (csvData == null) {
			return;
		}
		csvDataLen = csvData.length;
		if (trimFields) {
			this.csvData = StringTools.trim(csvData);
		} else {
			this.csvData = csvData;
		}
		if (this.csvData == "") {
			this.csvData = null;
		}
		detectDelimiter();
	}

	public function setDelimiterChar(delim:String):Void {
		delimiter = delim.fastCodeAt(0);
	}

	public function detectDelimiter():Void {
		delimiter = -1;
		if (csvData == null) {
			return;
		}
		var index:Int = csvData.indexOf("\n");
		var firstLine:String;
		if (index > 0) {
			firstLine = csvData.substring(0, index);
		} else {
			firstLine = csvData;
		}
		var token:Array<String> = firstLine.split(";");
		var countSemikolon:Int = token.length;
		token = firstLine.split(",");
		var countKomma:Int = token.length;
		token = firstLine.split("\t");
		var countTab:Int = token.length;

		if (countTab > countKomma) {
			if (countTab > countSemikolon) {
				delimiter = tab;
			} else {
				delimiter = semikolon;
			}
		} else {
			if (countKomma > countSemikolon) {
				delimiter = comma;
			} else {
				delimiter = semikolon;
			}
		}
	}

	public function nextLine():Array<String> {
		var field:String;
		var fields:Array<String> = [];

		if (csvData == null) {
			return fields;
		}
		while ((field = readField()) != null) {
			if (trimFields) {
				field = StringTools.trim(field);
			}
			fields.push(field);
		}
		return fields;
	}

	private function readField():String {
		if (pos > csvDataLen) {
			return null;
		}
		var c:Int = csvData.fastCodeAt(pos);
		if (c == quote) {
			return parseQotedField();
		} else {
			return parseUnqotedField();
		}
	}

	private function parseQotedField():String {
		var c:Int;

		pos++;
		var start:Int = pos;
		var end:Int = pos;
		var escaped:Bool = false;
		while (pos <= csvDataLen) {
			c = csvData.fastCodeAt(pos);
			if (c == escape) {
				escaped = true;
			}
			if (c != quote) {
				pos++;
				end = pos;
				continue;
			}
			if (escaped) {
				escaped = false;
				pos++;
				end = pos;
				continue;
			} else {
				if (pos + 1 < csvDataLen) {
					c = csvData.fastCodeAt(pos + 1);
					if (c == quote) {
						escaped = true;
						pos++;
						end = pos;
						continue;
					}
				}
			}
			break;
		}
		pos++;
		while (pos <= csvDataLen) {
			c = csvData.fastCodeAt(pos);
			if (c == delimiter) {
				pos++;
				break;
			}
			if ((c == endR) || (c == endN)) {
				lineBreakConsumed = false;
				break;
			}
			pos++;
		}
		var field:String = csvData.substring(start, end);
		field = StringTools.replace(field, '""', '"');
		field = StringTools.replace(field, '\\"', '"');
		return field;
	}

	private function parseUnqotedField():String {
		var c:Int;
		var start:Int = pos;
		while (pos <= csvDataLen) {
			c = csvData.fastCodeAt(pos);
			if (c == delimiter) {
				return csvData.substring(start, pos++);
			}
			if ((c == endR) || (c == endN)) {
				if (!lineBreakConsumed) {
					if (start != pos) {
						return csvData.substring(start, pos);
					}
					while (pos <= csvDataLen) {
						c = csvData.fastCodeAt(pos);
						if ((c != endR) && (c != endN)) {
							break;
						}
						pos++;
					}
					lineBreakConsumed = true;
					return null;
				}
				lineBreakConsumed = false;
				return csvData.substring(start, pos);
			}
			pos++;
		}
		if (start == pos) {
			return null;
		}
		return csvData.substring(start, pos);
	}

	public function hasMore():Bool {
		if (csvData == null) {
			return false;
		}
		return (pos < csvDataLen);
	}
}
