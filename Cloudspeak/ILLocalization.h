//
//  ILLocalization.h
//  Cloudspeak
//
//  Created by ∞ on 23/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


// TODO Move these functions somewhere better.

static inline NSBundle* ILLocalizationBundleForValue(NSBundle* b) {
	return b?: [NSBundle mainBundle];
}

static inline NSString* ILLocalizationBundleIdentifierForValue(NSBundle* b) {
	return [ILLocalizationBundleForValue(b) bundleIdentifier] ?: @"";
}

static inline NSString* ILLocalizationTableForValue(NSString* table) {
	if (!table || [table isEqual:@""])
		return @"Localizable";
	
	return table;
}


@interface ILLocalization : NSObject <NSCopying, NSMutableCopying> {
	NSDictionary* actualContents;
}

+ localization;

- (id) initWithPropertyListRepresentation:(id) plist;

@property(readonly, retain) NSLocale* locale;

- (NSString *) localizedStringForKey:(NSString *)key defaultValue:(NSString *)defaultValue table:(NSString *)table bundle:(NSBundle *)bundle;

@property(readonly) NSDictionary* propertyListRepresentation;

@end


@interface ILMutableLocalization : ILLocalization {
	NSMutableDictionary* contentsHolder;
}

- (void) setLocalization:(ILLocalization*) l;

- (void) setLocalizedString:(NSString*) string forKey:(NSString *)key table:(NSString *)table bundle:(NSBundle *)bundle;
- (void) removeLocalizedStringForKey:(NSString *)key table:(NSString *)table bundle:(NSBundle *)bundle;

@end