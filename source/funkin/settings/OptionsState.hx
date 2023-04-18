package funkin.settings;

import flixel.FlxG;
import flixel.FlxSprite;
import haxe.ds.EnumValueMap;
import funkin.backend.system.MusicBeatState;
import funkin.settings.OptionsMenu;
import funkin.settings.Options;
import funkin.settings.ControlsMenu;
import funkin.objects.menus.MainMenu;
import funkin.objects.ui.PageName;
import funkin.objects.ui.Page;
import funkin.backend.system.Paths;

class OptionsState extends MusicBeatState {
	public var pages:EnumValueMap<PageName, Page> = new EnumValueMap();
	public var currentName:PageName = Options;
	public var currentPage(get, never):Page;

	inline function get_currentPage()
		return pages.get(currentName);

	override function create() {
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuObjects/main_menu/menuDesat'));
		bg.color = 0xFF404183;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set(0, 0);
		add(bg);
		var optionsmenu:OptionsMenu = addPage(Options, new OptionsMenu(false));
		var preferencesmenu:Options = addPage(Preferences, new Options());
		var controlsmenu:ControlsMenu = addPage(Controls, new ControlsMenu());
		if (optionsmenu.hasMultipleOptions()) {
			optionsmenu.onExit.add(exitToMainMenu);
			controlsmenu.onExit.add(function() {
				switchPage(Options);
			});
			preferencesmenu.onExit.add(function() {
				switchPage(Options);
			});
		} else {
			controlsmenu.onExit.add(exitToMainMenu);
			setPage(Controls);
		}
		currentPage.enabled = false;
		super.create();
	}

	function addPage(name:PageName, page:Page):Dynamic {
		page.onSwitch.add(switchPage);
		pages.set(name, page);
		add(page);
		page.exists = name == currentName;
		return page;
	}

	function setPage(name:PageName) {
		if (pages.exists(currentName)) {
			currentPage.exists = false;
		}
		currentName = name;
		if (pages.exists(currentName)) {
			currentPage.exists = true;
		}
	}

	override function finishTransIn() {
		super.finishTransIn();
		currentPage.enabled = true;
	}

	function switchPage(name:PageName) {
		setPage(name);
	}

	function exitToMainMenu() {
		currentPage.enabled = false;
		FlxG.switchState(new MainMenu());
	}
}
