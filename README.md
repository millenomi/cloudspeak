Cloudspeak is a library you can add to a Cocoa application to load localization data from anywhere, change localizations at runtime and more.

Cloudspeak is very much a work in progress, and its API will change significantly; currently, it works like so:

 - You get a ILLocalization object from somewhere (or make one at runtime via `ILMutableLocalization`);

 - You set it like so:
		
		[ILLocalizationController sharedController].currentLocalization = l;

 - You access the localizations as follows:
	- Replace all `NSLocalizedString…()` macro uses with the corresponding `ILLocalizedString…()` macros; and
	- Use the `-localizeKeyPaths:ofObject:` to localize stuff loaded from NIBs (subject to change, but check out the additions to `UIViewController`!).
	
TODO:

 - A way of localizing NIBs that doesn't force people to make tons of outlets to all possible objects (maybe examining the view hierarchy in some efficient way?).
