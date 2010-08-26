//
//  ILLocalizationController.m
//  Cloudspeak
//
//  Created by ∞ on 23/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILLocalizationController.h"

NSString* const kILLocalizationWillChangeCurrentNotification = @"ILLocalizationWillChangeCurrentNotification";
NSString* const kILLocalizationDidChangeCurrentNotification = @"ILLocalizationDidChangeCurrentNotification";

NSString* const kILLocalizationNewValueKey = @"ILLocalizationNewValue";

// -----------------------------------------------

@implementation ILLocalizationController

L0ObjCSingletonMethod(sharedController)

- (id) init;
{
	if ((self = [super init])) {
		baseLocalizations = [NSMutableDictionary new];
	}
	
	return self;
}

- (ILLocalization*) baseLocalizationForBundle:(NSBundle*) bundle;
{
	NSString* key = [bundle bundleIdentifier];
	
	if (![baseLocalizations objectForKey:key]) {
		
		ILLocalization* loc = nil;
		
		NSString* l10n = [bundle pathForResource:@"Base" ofType:@"l10n"];
		
		if (l10n) {
			NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:l10n];
			if (dict) {
				loc = [[[ILLocalization alloc] initWithPropertyListRepresentation:dict] autorelease];
			}
		}
		
		[baseLocalizations setObject:((id) loc ?: [NSNull null]) forKey:key];
	}
	
	id x = [baseLocalizations objectForKey:key];
	if (x == [NSNull null])
		x = nil;
	
	return x;
}

- (void) setLocalization:(ILLocalization*) loc forBundle:(NSBundle*) bundle;
{
	if (!loc)
		[baseLocalizations setObject:[NSNull null] forKey:[bundle bundleIdentifier]];
	else
		[baseLocalizations setObject:loc forKey:[bundle bundleIdentifier]];
}

@synthesize currentLocalization;
- (void) setCurrentLocalization:(ILLocalization *) loc;
{
	if (loc != currentLocalization) {
		loc = [loc copy];
		
		NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
		NSDictionary* userInfo = loc? [NSDictionary dictionaryWithObject:loc forKey:kILLocalizationNewValueKey] : [NSDictionary dictionary];
				
		[dc postNotificationName:kILLocalizationWillChangeCurrentNotification object:self userInfo:userInfo];
		
		[currentLocalization release];
		currentLocalization = loc;
		
		[dc postNotificationName:kILLocalizationDidChangeCurrentNotification object:self];
	}
}

- (NSString *) localizedStringForKey:(NSString *)key defaultValue:(NSString *)defaultValue table:(NSString *)table bundle:(NSBundle *)bundle;
{
	bundle = ILLocalizationBundleForValue(bundle);
	
	// Check if we know of it.
	id x = [self.currentLocalization localizedStringForKey:key defaultValue:nil table:table bundle:bundle];
	
	if (x)
		return x;
	
	// Check if it's not in the base localization.
	x = [[self baseLocalizationForBundle:bundle] localizedStringForKey:key defaultValue:nil table:table bundle:bundle];
	if (x)
		return x;
	
	// Defer to Cocoa localization system if unknown.
	x = [ILLocalizationBundleForValue(bundle) localizedStringForKey:key value:defaultValue table:table];
	if ([x isEqual:key] || [x isEqual:@""])
		return defaultValue;
	else
		return x;
}

- (void) localizeKeyPaths:(NSSet*) keyPaths ofObject:(id) object table:(NSString*) table bundle:(NSBundle*) bundle;
{
	bundle = ILLocalizationBundleForValue(bundle);
	table = ILLocalizationTableForValue(table);
	
	for (NSString* keyPath in keyPaths) {
		id x = [self localizedStringForKey:keyPath defaultValue:nil table:table bundle:bundle];
		if (x)
			[object setValue:x forKeyPath:keyPath];
	}
}

- (void) localizeKeyPaths:(NSSet*) keyPaths ofObject:(id) object;
{
	[self localizeKeyPaths:keyPaths ofObject:object table:NSStringFromClass([object class]) bundle:[NSBundle bundleForClass:[object class]]];
}

- (void) dealloc;
{
	[baseLocalizations release];
	[currentLocalization release];
	[super dealloc];
}

@end
