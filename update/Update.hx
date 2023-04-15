import haxe.Json;
import sys.io.File;
import sys.FileSystem;

class Update {
    public static function main() {
        // Update hx code by YoshiCrafter29 (with permission given)
        if (!FileSystem.exists('.haxelib'))
            FileSystem.createDirectory('.haxelib');

        var json:Array<Library> = Json.parse(File.getContent('./haxelibs.json')).dependencies;
        prettyPrint("Preparing installation...");
        for(lib in json) {
            // install libs
            switch(lib.type) {
                case "haxelib":
                    prettyPrint('Installing "${lib.name}"...');             
                    Sys.command('haxelib install ${lib.name} ${lib.version != null ? " " + lib.version : " "}');
                case "git":
                    prettyPrint('Installing "${lib.name}" from git url "${lib.url}"');
                    Sys.command('haxelib git ${lib.name} ${lib.url}');
                default:
                    prettyPrint('Cannot resolve library of type "${lib.type}"');
            }
        }
    }

    public static function prettyPrint(text:String) {
        var header = "══════";
        for(i in 0...text.length)
            header += "═";
        Sys.println("");
        Sys.println('╔$header╗');
        Sys.println('║   $text   ║');
        Sys.println('╚$header╝');
    }
}

typedef Library = {
    var name:String;
    var type:String;
    var version:String;
    var dir:String;
    var ref:String;
    var url:String;
}