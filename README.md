Cloudspeak is a library you can add to a Cocoa application to load localization data from anywhere, change localizations at runtime and more.

Cloudspeak is very much a work in progress, and its API will change significantly; currently, it works like so:

 - You get a `ILLocalization` object from somewhere (or make one at runtime via `ILMutableLocalization`);

 - You set it like so:
		
		[ILLocalizationController sharedController].currentLocalization = l;

 - You access the localizations as follows:
	- Replace all `NSLocalizedString…()` macro uses with the corresponding `ILLocalizedString…()` macros; and
	- Use the `-localizeKeyPaths:ofObject:` to localize stuff loaded from NIBs (subject to change, but check out the additions to `UIViewController`!).
	
STUFF THAT WORKS:

 - The above.

 - … which means you can change localizations at runtime at will. The library posts appropriate notifications, and the `UIViewController` additions can catch them and provide you with a chance of either reapplying the localization, or hiding/dismissing so that the NIB can be reloaded.
	
TODO:

 - A way of localizing NIBs that doesn't force people to make tons of outlets to all possible objects (maybe examining the view hierarchy in some efficient way?).

 - A `ILLocalizationFeed` class that can fetch localizations off the Internet and auto-update them or somesuch.
