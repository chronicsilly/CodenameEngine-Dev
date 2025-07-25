package funkin.options.type;

/**
 * Option type that allows you to select an array of options.
**/
class ArrayOption extends OptionType {
	public var selectCallback:String->Void;

	private var __text:Alphabet;
	private var __selectiontext:Alphabet;

	public var options:Array<Dynamic>;
	public var displayOptions:Array<String>;

	public var currentSelection:Int;

	var optionName:String;

	public var parent:Dynamic;

	private var rawText(default, set):String;

	public var text(get, set):String;
	private function get_text() {return __text.text;}
	private function set_text(v:String) {return __text.text = v;}

	public function new(text:String, desc:String, options:Array<Dynamic>, displayOptions:Array<String>, optionName:String, ?selectCallback:String->Void = null, ?parent:Dynamic) {
		super(desc);
		this.selectCallback = selectCallback;
		this.displayOptions = displayOptions;
		this.options = options;
		if (parent == null)
			parent = Options;

		this.parent = parent;

		var fieldValue = Reflect.field(parent, optionName);
		if(fieldValue != null)
			this.currentSelection = CoolUtil.maxInt(0, options.indexOf(fieldValue));

		this.optionName = optionName;

		add(__text = new Alphabet(100, 20, text, "bold"));
		add(__selectiontext = new Alphabet(__text.width + 120, 20, formatTextOption(), "normal"));

		rawText = text;
	}

	override function reloadStrings() {
		super.reloadStrings();
		this.rawText = rawText;
	}

	function set_rawText(v:String) {
		rawText = v;
		__text.text = TU.exists(rawText) ? TU.translate(rawText) : rawText;
		return v;
	}

	public override function draw() {
		super.draw();
	}

	public override function onChangeSelection(change:Float):Void
	{
		if(currentSelection <= 0 && change == -1 || currentSelection >= options.length - 1 && change == 1) return;
		currentSelection += Math.round(change);
		__selectiontext.text = formatTextOption();
		Reflect.setField(parent, optionName, options[currentSelection]);
		if(selectCallback != null)
			selectCallback(options[currentSelection]);
	}

	private function formatTextOption() {
		var currentOptionString = ": ";
		if((currentSelection > 0))
			currentOptionString += "< ";
		else
			currentOptionString += "  ";

		currentOptionString += displayOptions[currentSelection];

		if(!(currentSelection >= options.length - 1))
			currentOptionString += " >";

		return currentOptionString;
	}
}