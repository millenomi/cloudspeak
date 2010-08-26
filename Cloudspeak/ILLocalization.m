//
//  ILLocalization.m
//  Cloudspeak
//
//  Created by ∞ on 23/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILLocalization.h"

static id ILCreateDeepClone(id objOrContainer, BOOL mutable);


@interface ILLocalization ()

- (id) initWithActualContents:(NSDictionary *)md locale:(NSLocale *)locale;

@property(copy, nonatomic) NSDictionary* actualContents;
@property(retain) NSLocale* locale;

- (BOOL) setLocalizationFromPropertyListRepresentation:(id)plist;

@end


@implementation ILLocalization

+ localization;
{
	return [[[self alloc] init] autorelease];
}

- (id) init;
{
	if ((self = [super init])) {
		self.actualContents = [NSDictionary dictionary];
		self.locale = [NSLocale systemLocale];
	}
	
	return self;
}

- (id) initWithActualContents:(NSDictionary*) md locale:(NSLocale*) locale;
{
	if ((self = [super init])) {
		self.actualContents = md;
		self.locale = locale;
	}
	
	return self;
}

- (void) dealloc
{
	self.actualContents = nil;
	[super dealloc];
}

@synthesize actualContents;
- (void) setActualContents:(NSDictionary *) d;
{
	if (d != actualContents) {
		[actualContents release];
		actualContents = [ILCreateDeepClone(d, NO) retain];
	}
}

@synthesize locale;

- (NSString *) localizedStringForKey:(NSString *)key defaultValue:(NSString *)defaultValue table:(NSString *)table bundle:(NSBundle *)bundle;
{
	bundle = ILLocalizationBundleForValue(bundle);
	table = ILLocalizationTableForValue(table);
	
	id x = [[[self.actualContents objectForKey:[bundle bundleIdentifier] ?: @""] objectForKey:table] objectForKey:key];
	
	return x ?: defaultValue;
}

// ---------------------

- (id) copyWithZone:(NSZone *)zone;
{
	if ([self class] == [ILLocalization class] && NSShouldRetainWithZone(self, zone))
		return [self retain];
	else
		return [[ILLocalization alloc] initWithActualContents:self.actualContents locale:locale];
}

- (id) mutableCopyWithZone:(NSZone *)zone;
{
	return [[ILMutableLocalization alloc] initWithActualContents:self.actualContents locale:locale];
}

- (id) propertyListRepresentation;
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			@"Contents", self.actualContents,
			@"Locale", self.locale? [self.locale localeIdentifier] : @"",
			nil];
}

- (id) initWithPropertyListRepresentation:(id) plist;
{
	if ((self = [super init])) {
		if (![self setLocalizationFromPropertyListRepresentation:plist]) {
			[self release];
			return nil;
		}
	}
	
	return self;
}

- (BOOL) setLocalizationFromPropertyListRepresentation:(id) plist;
{
	// sanity check!
	if (![plist isKindOfClass:[NSDictionary class]])
		return NO;
	
	id contents = [plist objectForKey:@"Contents"];
	if (![contents isKindOfClass:[NSDictionary class]])
		return NO;
	
	id localeIdentifier = [plist objectForKey:@"Locale"];
	if (![localeIdentifier isKindOfClass:[NSString class]])
		return NO;
	
	NSLocale* loc = nil;
	if (![localeIdentifier isEqual:@""]) {
		loc = [[[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier] autorelease];
		if (!loc)
			return NO;
	}
	
	for (id key in contents) {
		if (![key isKindOfClass:[NSString class]])
			return NO;
		
		id value = [plist objectForKey:key];
		if (![value isKindOfClass:[NSDictionary class]])
			return NO;
		
		for (id tableKey in value) {
			if (![tableKey isKindOfClass:[NSString class]])
				return NO;
			
			id tableValue = [value objectForKey:tableKey];
			if (![tableValue isKindOfClass:[NSDictionary class]])
				return NO;
			
			for (id tableEntryKey in tableValue) {
				if (![tableEntryKey isKindOfClass:[NSString class]])
					return NO;
				
				if (![[tableValue objectForKey:tableEntryKey] isKindOfClass:[NSString class]])
					return NO;
			}
		}
	}
	
	self.actualContents = plist;
	self.locale = loc;
	return YES;
}

@end


@implementation ILMutableLocalization

- (NSDictionary*) actualContents;
{
	return contentsHolder;
}
- (void) setActualContents:(NSDictionary *) d;
{
	if (d != actualContents) {
		[contentsHolder release];
		contentsHolder = [ILCreateDeepClone(d, YES) retain];
	}
}

- (NSMutableDictionary*) mutableDictionaryForTable:(NSString*) table bundle:(NSBundle*) bundle;
{	
	bundle = ILLocalizationBundleForValue(bundle);
	table = ILLocalizationTableForValue(table);
	
	// bundle
	NSMutableDictionary* bundleDictionary = [contentsHolder objectForKey:[bundle bundleIdentifier] ?: @""];
	if (!bundleDictionary) {
		bundleDictionary = [NSMutableDictionary dictionary];
		[contentsHolder setObject:bundleDictionary forKey:[bundle bundleIdentifier] ?: @""];
	}
	
	// table
	NSMutableDictionary* tableDictionary = [bundleDictionary objectForKey:table];
	if (!tableDictionary) {
		tableDictionary = [NSMutableDictionary dictionary];
		[bundleDictionary setObject:tableDictionary forKey:table];
	}
	
	return tableDictionary;
}

- (void) setLocalizedString:(NSString*) string forKey:(NSString *)key table:(NSString *)table bundle:(NSBundle *)bundle;
{
	[[self mutableDictionaryForTable:table bundle:bundle] setObject:string forKey:key];
}

- (void) removeLocalizedStringForKey:(NSString *)key table:(NSString *)table bundle:(NSBundle *)bundle;
{
	[[self mutableDictionaryForTable:table bundle:bundle] removeObjectForKey:key];
}

- (BOOL) setLocalizationFromPropertyListRepresentation:(id) plist;
{
	return [super setLocalizationFromPropertyListRepresentation:plist];
}

- (void) setLocalization:(ILLocalization*) l;
{
	[self setLocalizationFromPropertyListRepresentation:l.propertyListRepresentation];
}

@end


static id ILCreateDeepClone(id objOrContainer, BOOL mutable) {
	if (!objOrContainer)
		return nil;
	
	if ([objOrContainer isKindOfClass:[NSArray class]]) {

		NSMutableArray* a = [NSMutableArray arrayWithCapacity:[objOrContainer count]];
		for (id obj in objOrContainer) {
			id x = ILCreateDeepClone(obj, mutable);
			if (x)
				[a addObject:x];
		}
		
		return mutable? a : [[a copy] autorelease];
	
	} else if ([objOrContainer isKindOfClass:[NSDictionary class]]) {

		NSMutableDictionary* a = [NSMutableDictionary dictionaryWithCapacity:[objOrContainer count]];
		for (id key in objOrContainer) {
			id x = ILCreateDeepClone([objOrContainer objectForKey:key], mutable);
			if (x)
				[a setObject:x forKey:key];
		}
		
		return mutable? a : [[a copy] autorelease];		
	
	} else if ([objOrContainer isKindOfClass:[NSSet class]]) {

		NSMutableSet* a = [NSMutableSet setWithCapacity:[objOrContainer count]];
		for (id obj in objOrContainer) {
			id x = ILCreateDeepClone(obj, mutable);
			if (x)
				[a addObject:x];
		}
		
		return mutable? a : [[a copy] autorelease];
		
	} else {
		
		if (mutable && [objOrContainer conformsToProtocol:@protocol(NSMutableCopying)]) {
			return [[objOrContainer mutableCopy] autorelease];
		} else if (!mutable && [objOrContainer conformsToProtocol:@protocol(NSCopying)]) {
			return [[objOrContainer copy] autorelease];
		} else
			return objOrContainer;
		
	}
}
