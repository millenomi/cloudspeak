//
//  ILLocalizationController.h
//  Cloudspeak
//
//  Created by ∞ on 23/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ILLocalization.h"

#define ILLocalizedString(key, comment) \
	ILFindLocalizedStringFromTableInBundle((key), nil, nil)
#define ILLocalizedStringFromTable(key, tableName, comment) \
	ILFindLocalizedStringFromTableInBundle((key), (tableName), nil)
#define ILLocalizedStringFromTableInBundle(key, tableName, bundle, comment) \
	ILFindLocalizedStringFromTableInBundle((key), (tableName), (comment))

#define ILFindLocalizedStringFromTableInBundle(key, tableName, bundle) \
	[[ILLocalizationController sharedController] localizedStringWithKey:(key) defaultValue:(key) table:(tableName) bundle:(bundle)]

// ------------------------------------

extern NSString* const kILLocalizationWillChangeCurrentNotification;
extern NSString* const kILLocalizationDidChangeCurrentNotification;

extern NSString* const kILLocalizationNewValueKey;

// ------------------------------------

@interface ILLocalizationController : NSObject {
	NSMutableDictionary* baseLocalizations;
}

+ (ILLocalizationController*) sharedController;

/**
 Sets or retrieves the app's current localization object.
 
 This localization object will be used to localize your app's strings (via ILLocalizedStringFromTable() or this class's methods). Changing a localization midway can be problematic unless you design your app for it, so make sure you do.
 
 Changing this property posts kILLocalizationWillChangeCurrentNotification and kILLocalizationDidChangeCurrentNotification appropriately.
 */
@property(nonatomic, copy) ILLocalization* currentLocalization;

/**
 Returns the base localization for a bundle. A base loc complements the Cocoa standard localization system by resupplying strings that get overwritten by the current localization in case the current localization is later set to nil (that is, when you turn off Cloudspeak and return to the base Cocoa localizations).
 
 This is useful if you're localizing key paths (as per #localizeKeyPaths:ofObject:table:bundle:), since the original values are overwritten by Cloudspeak and may not be reloadable through the standard Cocoa localization system (in the case of NIBs, for example).
 
 To give a bundle a base localization automatically, save its ILLocalization's property list representation as a file called 'Base.l10n' in the appropriate .lproj folder of your bundle.
 */
- (ILLocalization*) baseLocalizationForBundle:(NSBundle*) bundle;
- (void) setLocalization:(ILLocalization*) loc forBundle:(NSBundle*) bundle;

/**
 Returns a string from the current localization. Strings are stored by bundle (more accurately, by bundle identifier); each bundle can have one or more tables, which contain key-value pairs for translation. This works just like Cocoa's localization system, except Cloudspeak can augment it with localizations coming from other sources.
 
 This method looks for the value in the current localization (if set), then looks for the value in the base localization (if any), then defers to the standard Cocoa localization system.
 
 @param key The key to localize.
 @param defaultValue A value to return if the key is not found.
 @param table The table to look in. It can be nil or @"", in which case the table called <code>Localizable</code> is used.
 @param bundle The bundle that contains the table. It can be nil, and in this case the main bundle is used instead.
 */
- (NSString *) localizedStringForKey:(NSString *)key defaultValue:(NSString *)defaultValue table:(NSString *)table bundle:(NSBundle *)bundle;

/**
 Localizes the given key paths of an object. Same as #localizeKeyPaths:ofObject:table:bundle:, except it uses the object's class's name as the table name, and the bundle for the object's class as the bundle.
 */
- (void) localizeKeyPaths:(NSSet*) keyPaths ofObject:(id) object;

/**
 Localizes the given key paths of an object. This looks up the key paths (verbatim as you pass them) as keys in the given table, then set the result (if found) as the value of that key path from the object via Key-Value Coding.
 
 This method is used to localize NIB files through Cloudspeak. See the UIViewController#localize method and ILLocalizableViewController class for a simpler way of localizing views (including views loaded from NIB files) when using view controllers.
 */
- (void) localizeKeyPaths:(NSSet*) keyPaths ofObject:(id) object table:(NSString*) table bundle:(NSBundle*) bundle;

@end
