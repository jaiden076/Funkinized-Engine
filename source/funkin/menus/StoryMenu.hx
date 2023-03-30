package funkin.menus;

#if discord_rpc
import dependency.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import haxe.xml.Access;
import funkin.system.*;
import funkin.system.dependency.*;
import funkin.menus.StoryItem;
import funkin.menus.MenuCharacter;
import funkin.game.*;
import flixel.graphics.FlxGraphic;
import funkin.utils.*;
class StoryMenu extends MusicBeatState {
	
	var scoreText:FlxText;
	var curDifficulty:Int = 1;
	var curDifficultyArray = ["Easy", "Normal", "Hard"];
	var txtWeekTitle:FlxText;
	var curWeek:Int = 0;
	var txtTracklist:FlxText;
	var grpWeekText:FlxTypedGroup<StoryItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;
	var grpLocks:FlxTypedGroup<FlxSprite>;
	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var weekData:Array<Dynamic> = [
		['Tutorial'],
		['Bopeebo', 'Fresh', 'Dadbattle'],
		['Spookeez', 'South', 'Monster'],
		['Pico', 'Philly-Nice', 'Blammed'],
		['Satin-Panties', 'High', 'Milf'],
		['Cocoa', 'Eggnog', 'Winter-Horrorland'],
		['Senpai', 'Roses', 'Thorns'],
		['Ugh', 'Guns', 'Stress']
	];

	
	var weekCharacters:Array<Dynamic> = [
		['dad', 'bf', 'gf'], // tutorial
		['dad', 'bf', 'gf'], // week 1
		['spooky', 'bf', 'gf'], // week 2
		['pico', 'bf', 'gf'], // week 3
		['mom', 'bf', 'gf'], // week 4
		['parents-christmas', 'bf', 'gf'], // week 5
		['senpai', 'bf', 'gf'], // week 6
		['tankman', 'bf', 'gf'] // week 7
	];

	var weekNames:Array<String> = [
		"Tutorial", // tutorial
		"Daddy Dearest", // week 1
		"Spooky Month", // week 2
		"PICO", // week 3
		"MOMMY MUST MURDER", // week 4
		"RED SNOW", // week 5
		"hating simulator ft. moawling", // week 6
		"Tankman" // week 7
	];

	public static var weekUnlocked:Array<Bool> = 
	[
		true, // tutorial
		true, // week 1
		true, // week 2
		true, // week 3
		true, // week 4
		true, // week 5
		true,  // week 6
		true // week 7
	];

	override function create() {
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		FlxG.mouse.useSystemCursor = true;

		if (FlxG.sound.music != null) {
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('menus/freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, 'SCORE: ', 36);
		scoreText.setFormat('VCR OSD Mono', 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, '', 32);
		txtWeekTitle.setFormat('VCR OSD Mono', 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var ui_tex = Paths.getSparrowAtlas('menuObjects/storymenu/menu_assets');
		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		grpWeekText = new FlxTypedGroup<StoryItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		trace('Line 70');

		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence('In the Menus', null);
		#end

		for (i in 0...weekData.length) {
			var weekThing:StoryItem = new StoryItem(0, yellowBG.y + yellowBG.height + 10, i);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);

			// Needs an offset thingie
			if (!weekUnlocked[i]) {
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				grpLocks.add(lock);
			}
		}

		trace('Line 96');

		for (char in 0...3) {
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, weekCharacters[curWeek][char]);
			weekCharacterThing.y += 70;
			switch (weekCharacterThing.character) {
				case 'bf':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.9));
					weekCharacterThing.updateHitbox();
					weekCharacterThing.x -= 80;
				case 'dad':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.5));
					weekCharacterThing.updateHitbox();
				case 'gf':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.5));
					weekCharacterThing.updateHitbox();
				case 'parents-christmas':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.9));
					weekCharacterThing.updateHitbox();
				case 'pico':
					weekCharacterThing.flipX = true;
			}

			grpWeekCharacters.add(weekCharacterThing);
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		trace('Line 124');

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);
		trace('Line 150');

		add(yellowBG);
		add(grpWeekCharacters);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, 'Tracks', 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = scoreText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		add(scoreText);
		add(txtWeekTitle);

		updateText();

		trace('Line 165');

		super.create();
	}

	override function update(elapsed:Float) {
		lerpScore = MathFunctions.fixedLerp(lerpScore, intendedScore, 0.5);

		scoreText.text = 'WEEK SCORE:' + Math.round(lerpScore);

		txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);


		difficultySelectors.visible = weekUnlocked[curWeek];

		grpLocks.forEach(function(lock:FlxSprite) {
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack) {
			if (!selectedWeek) {
				if (controls.UI_UP_P) {
					changeWeek(-1);
				}

				if (controls.UI_DOWN_P) {
					changeWeek(1);
				}

				if (controls.UI_RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.UI_LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.UI_RIGHT_P)
					changeDifficulty(1);
				if (controls.UI_LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT) {
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenu());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek() {
		if (weekUnlocked[curWeek]) {
			if (stopspamming == false) {
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				grpWeekCharacters.members[1].animation.play('bfConfirm');
				stopspamming = true;
			}

			PlayState.storyPlaylist = weekData[curWeek];
			PlayState.isStoryMode = true;
			selectedWeek = true;

			PlayState.storyDifficulty = curDifficulty;
			var formatSong = CoolUtil.formatSong(PlayState.storyDifficulty);

			PlayState.SONG = Song.loadFromJson(formatSong, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer) {
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void
		{
			curDifficulty = FlxMath.wrap(curDifficulty + change, 0, CoolUtil.difficultyArray.length - 1);

			sprDifficulty.offset.x = 0;

			sprDifficulty.loadGraphic(Paths.image("menuObjects/storymenu/difficulties/" + CoolUtil.difficultyArray[curDifficulty].toLowerCase()));
	
			sprDifficulty.alpha = 0;

			sprDifficulty.y = leftArrow.y - 15;
			intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

			#if !switch
			intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
			#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
		}
	var lerpScore:Float = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void {
		curWeek += change;

		if (curWeek >= weekData.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData.length - 1;

		var bullShit:Int = 0;

		for (item in grpWeekText.members) {
			item.targetY = bullShit - curWeek;
			if (item.targetY == 0 && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function updateText() {
		grpWeekCharacters.members[0].animation.play(weekCharacters[curWeek][0]);
		grpWeekCharacters.members[1].animation.play(weekCharacters[curWeek][1]);
		grpWeekCharacters.members[2].animation.play(weekCharacters[curWeek][2]);
		txtTracklist.text = 'Tracks\n';

		switch (grpWeekCharacters.members[0].animation.curAnim.name) {
			case 'dad':
				grpWeekCharacters.members[0].offset.set(120, 200);
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 1));

			case 'mom':
				grpWeekCharacters.members[0].offset.set(100, 200);
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 1));

			case 'parents-christmas':
				grpWeekCharacters.members[0].offset.set(200, 200);
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 0.99));

			case 'senpai':
				grpWeekCharacters.members[0].offset.set(130, 0);
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 1.4));

			case 'tankman':
				grpWeekCharacters.members[0].offset.set(60, -20);
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 1));

			default:
				grpWeekCharacters.members[0].offset.set(100, 100);
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 1));
				// grpWeekCharacters.members[0].updateHitbox();
		}

		var stringThing:Array<String> = weekData[curWeek];

		for (i in stringThing) {
			txtTracklist.text += '\n' + i;
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}
}
