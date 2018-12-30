# README

Ramen is a 2D game engine written in standard Forth.

[1.0 Documentation](https://rogerlevy.gitbook.io/ramen)

Status:

2.0 is in development and it fixes and improves on a ***lot***.  I am working on a [rewrite of my Zelda clone](https://github.com/RogerLevy/RamenEngine/tree/zelda) which runs on 2.0.

## Setup (new)

This is the package repo, which depends on other packages.  Grab the [Distribution](https://github.com/RogerLevy/RamenEngine) which includes all the dependencies at the correct versions.

Download [SwiftForth](https://www.forth.com/swiftforth/)

(GForth support is working on Linux, if anyone can help get it working on Windows please get in touch (post an issue or send me a message on [Twitter](https://twitter.com/RamenEngine).)

## Features

* Built with Allegro 5, using [AllegroForthKit](https://github.com/RogerLevy/AllegroForthKit).
* [Tiled](https://www.mapeditor.org/) map support \(partial\)
* Sprite animation
* Multiple display list support
* Interactive commandline console
* ColorForth-inspired, minimalist code emphasizing flat data design.
* Fast rectangle collision detection
* Roundrobin multitasking
* Graphics primitives such as line, rectangle, ellipse, blit, text, etc.
* Publish facility
* Z-sorted rendering
* Basic sound support
* Data structure extensions - 2D arrays, stacks, node trees

## See Ramen in Action

Want to watch some videos? Here's footage of examples from Ramen's predecessor. They're being updated to work on Ramen.

[https://www.youtube.com/playlist?list=PLO8m1cHe8erpbejS5yZVJAsQNI4Lmpo\_Y](https://www.youtube.com/playlist?list=PLO8m1cHe8erpbejS5yZVJAsQNI4Lmpo_Y)

Also check out [The Lady](https://store.steampowered.com/app/341060/The_Lady/%20), a commercial game I wrote in Forth to prove it can be done. Large chunks of this game's engine live on in Ramen.

## Getting Started (OLD!!! will update when 2.0 releases)

1. Download [SwiftForth](https://www.forth.com/swiftforth/). After installing add the bin folder to your path.
2. Download or clone [ramenExamples](https://github.com/RogerLevy/ramenExamples)
3. \(If you download a release directly into your project, rename the folder to just `ramen`\).
4. Copy and rename `afkit/kitconfig.f_` and `afkit/allegro5.cfg_` to the project root, removing the underscores.  Edit them if needed.
5. Optionally get [Komodo Edit](https://www.activestate.com/komodo-ide/downloads/edit) and loading the project file - just hit F5 and the IDE should start.
6. Otherwise load up SwiftForth, navigate to the project directory with `cd` and `include session.f` - the IDE should start.  
7. You can `ld` any of these: `depth` `flies` `rectland` `island` `stickerknight`
8. Hit Tab to toggle between IDE and the running demo.  Only `rectland` has any controls.
9. For a more advanced example check out [LinkGoesForth](https://github.com/RogerLevy/linkgoesforth).  Note the IDE is active by default.  The game won't receive input until you toggle out of it.

## Help

* Submit [Issues](https://github.com/RogerLevy/ramen/issues)
* Tweet [@RamenEngine](https://twitter.com/RamenEngine) 

## Links and Resources

* [Forth: The Hacker's Language on HACKADAY](https://hackaday.com/2017/01/27/forth-the-hackers-language/)
* [Programming Forth by Stephen Pelc](http://www.mpeforth.com/arena/ProgramForth.pdf)
* [Forth Programming 21st Century on Facebook](https://www.facebook.com/groups/PROGRAMMINGFORTH/) - The current active and growing forum on the web for modern desktop Forth programming \(as opposed to on embedded or classic computers.\) 
* [Allegro 5.2.3 Documentation](http://liballeg.org/a5docs/5.2.3/)
* [Allegro.cc forum](https://www.allegro.cc/forums) - A very helpful and fairly active community.  And gladly, language-agnostic.
* [The DPANS94 Forth Standard](http://dl.forth.com/sitedocs/dpans94.pdf)

## Projects

* [Zelda clone](https://github.com/RogerLevy/linkgoesforth)
* [Starfox-like Dogfighting game](https://github.com/RogerLevy/triplestrength)
* [3D Packet](https://github.com/RogerLevy/3dpack)
* [Bento 2D Physics Packet](https://github.com/RogerLevy/bento)
