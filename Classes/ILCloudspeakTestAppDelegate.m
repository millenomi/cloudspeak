//
//  CloudspeakAppDelegate.m
//  Cloudspeak
//
//  Created by ∞ on 23/08/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "ILCloudspeakTestAppDelegate.h"

#import "ILLocalizationController.h"
#import "ILLocalizationController-ILLanguagePicker.h"

#define ILAssertThat(x) NSAssert(x, @#x)


@implementation ILCloudspeakTestFirstVC

- (NSSet *) localizableKeyPaths;
{
	return [NSSet setWithObjects:
			@"title",
			@"label.text",
			nil];
}

- (BOOL) canChangeCurrentLocalizationByReapplying { return YES; }

@end

@implementation ILCloudspeakTestSecondVC

- (NSSet *) localizableKeyPaths;
{
	return [NSSet setWithObjects:
			@"title",
			@"button.localizableNormalTitle",
			nil];
}

- (BOOL) canChangeCurrentLocalizationByReapplying { return YES; }

@end


@implementation ILCloudspeakTestAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	
	NSString* lang = @"zh_TW-Hant",
		* exactMatch = @"zh_TW-Hant",
		* betterMatch = @"zh-Hant", 
		* goodMatch = @"zh_TW", 
		* decentMatch = @"zh", 
		* noMatch = @"it";
	
	NSInteger
		exactMatchDegree = ILLanguageMatchDegree(exactMatch, lang),
		betterMatchDegree = ILLanguageMatchDegree(betterMatch, lang),
		goodMatchDegree = ILLanguageMatchDegree(goodMatch, lang),
		decentMatchDegree = ILLanguageMatchDegree(decentMatch, lang),
		noMatchDegree = ILLanguageMatchDegree(noMatch, lang);
	
	ILAssertThat(exactMatchDegree == kILIdentifierComponentsPerfectMatch);
	ILAssertThat(betterMatchDegree < exactMatchDegree);
	ILAssertThat(goodMatchDegree < betterMatchDegree);
	ILAssertThat(decentMatchDegree < goodMatchDegree);
	ILAssertThat(noMatchDegree < goodMatchDegree);
	ILAssertThat(noMatchDegree == kILIdentifierComponentsNoMatch);
	
	// --------------------------
	
	NSArray* available = [NSArray arrayWithObjects:
						  @"it", @"en", @"de", @"zh-Hant",
						  nil];
	
	NSInteger x = [[ILLocalizationController sharedController] indexOfPreferredLanguageAmongLanguages:available];
	NSLog(@"index found --> %d", x);
	
    [window makeKeyAndVisible];
	
	[self performSelector:@selector(tryChangingLocalization) withObject:nil afterDelay:3.0];
	
	return YES;
}

- (void) tryChangingLocalization;
{
	ILMutableLocalization* ml = [[ILMutableLocalization new] autorelease];
	
	[ml setLocalizedString:@"Uno" forKey:@"title" table:@"ILCloudspeakTestFirstVC" bundle:nil];
	[ml setLocalizedString:@"Due" forKey:@"title" table:@"ILCloudspeakTestSecondVC" bundle:nil];
	
	[ml setLocalizedString:@"Etichetta" forKey:@"label.text" table:@"ILCloudspeakTestFirstVC" bundle:nil];
	[ml setLocalizedString:@"Pulsante!" forKey:@"button.localizableNormalTitle" table:@"ILCloudspeakTestSecondVC" bundle:nil];
	
	[ILLocalizationController sharedController].currentLocalization = ml;
}

@end
