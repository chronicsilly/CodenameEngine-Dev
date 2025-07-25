package funkin.options;

import flixel.FlxState;
import flixel.tweens.FlxTween;
import flixel.util.typeLimit.OneOfTwo;
import flixel.util.typeLimit.OneOfThree;
import funkin.backend.FunkinText;
import funkin.editors.ui.UIState;
import funkin.menus.MainMenuState;
import funkin.options.type.OptionType;
import funkin.options.type.TextOption;
import funkin.backend.system.framerate.Framerate;

class TreeMenu extends UIState {
	public var main:OptionsScreen;
	public var optionsTree:OptionsTree;
	public var pathLabel:FunkinText;
	public var pathDesc:FunkinText;
	public var pathBG:FlxSprite;

	public var screenScroll(default, set):Float;
	private inline function set_screenScroll(val:Float) {
		FlxG.camera.scroll.x = val * FlxG.camera.width;
		return screenScroll = val;
	}

	public static var lastState:Class<FlxState> = null;  // Static for fixing the softlock bugs when resetting the state  - Nex

	public function new(scriptsAllowed:Bool = true, ?scriptName:String) {
		if (lastState == null) lastState = Type.getClass(FlxG.state);
		super(scriptsAllowed, scriptName);
	}

	public override function createPost() {
		if (main == null) main = new OptionsScreen("Fallback Treemenu", "Please set the \"main\" variable in your extended class before createPost", [new TextOption("Oops! No Options", "This doesn't look like it was supposed to happen...", () -> FlxG.resetState() ) ]);

		screenScroll = -1;

		pathLabel = new FunkinText(4, 4, FlxG.width - 8, "> Tree Menu", 32, true);
		pathLabel.borderSize = 1.25;
		pathLabel.scrollFactor.set();

		pathDesc = new FunkinText(4, pathLabel.y + pathLabel.height + 2, FlxG.width - 8, "Current Tree Menu Description", 16, true);
		pathDesc.scrollFactor.set();

		pathBG = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
		pathBG.scale.set(FlxG.width, pathDesc.y + pathDesc.height + 2);
		pathBG.updateHitbox();
		pathBG.alpha = 0.25;
		pathBG.scrollFactor.set();

		optionsTree = new OptionsTree();
		optionsTree.onMenuChange = onMenuChange;
		optionsTree.onMenuClose = onMenuClose;
		optionsTree.treeParent = this;
		optionsTree.add(main);


		add(optionsTree);
		add(pathBG);
		add(pathLabel);
		add(pathDesc);


		super.createPost();
	}

	public function onMenuChange() {
		if (optionsTree.members.length <= 0) {
			exit();
		} else {
			if (menuChangeTween != null)
				menuChangeTween.cancel();

			menuChangeTween = FlxTween.num(screenScroll, Math.max(0, (optionsTree.members.length-1)), 1.5, {ease: menuTransitionEase, onComplete: function(t) {
				optionsTree.clearLastMenu();
				menuChangeTween = null;
			}}, (val:Float) -> screenScroll = val);

			reloadLabels();
		}
	}

	public function onMenuClose(m:OptionsScreen) {
		CoolUtil.playMenuSFX(CANCEL);
	}

	public function reloadLabels() {
		var t = "";
		for(o in optionsTree.members)
			t += '${o.name} > ';
		pathLabel.text = t;

		var idk:OptionsScreen = optionsTree.members.last();
		if (idk.members.length > 0) updateDesc(idk.members[idk.curSelected].desc);
	}

	public function updateDesc(moreTxt:String = '') {
		pathDesc.text = optionsTree.members.last().desc;
		if (moreTxt != null && moreTxt.length > 0) pathDesc.text += '\n' + moreTxt;
		pathBG.scale.set(FlxG.width, pathDesc.y + pathDesc.height + 2);
		pathBG.updateHitbox();
	}

	public function exit() {
		FlxG.switchState((lastState != null) ? Type.createInstance(lastState, []) : new MainMenuState());
		lastState = null;
	}

	var menuChangeTween:FlxTween;
	public override function update(elapsed:Float) {
		super.update(elapsed);
		Framerate.offset.y = pathBG.height;

		// in case path gets so long it goes offscreen
		pathLabel.x = lerp(pathLabel.x, Math.max(0, FlxG.width - 4 - pathLabel.width), 0.125);
	}

	public override function onResize(width:Int, height:Int) {
		super.onResize(width, height);
		if (!UIState.resolutionAware) return;

		if (width < FlxG.initialWidth || height < FlxG.initialHeight) {
			width = FlxG.initialWidth; height = FlxG.initialHeight;
		}

		screenScroll = screenScroll;  // Updating the cam position  - Nex

		if (pathDesc != null && pathLabel != null)
			pathDesc.width = pathLabel.width = width - 8;
	}

	public static inline function menuTransitionEase(e:Float)
		return FlxEase.quintInOut(FlxEase.cubeOut(e));
}

typedef OptionCategory = {
	var name:String;
	var desc:String;
	var state:OneOfThree<OptionsScreen, Class<OptionsScreen>, (name:String, desc:String) -> OptionsScreen>;
	var ?substate:OneOfThree<MusicBeatSubstate, Class<MusicBeatSubstate>, (name:String, desc:String) -> MusicBeatSubstate>;
	var ?suffix:String;
}

typedef OptionTypeDef = {
	var type:Class<OptionType>;
	var args:Array<Dynamic>;
}
