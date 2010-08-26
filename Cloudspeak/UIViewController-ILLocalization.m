//
//  UIViewController-ILLocalization.m
//  Cloudspeak
//
//  Created by ∞ on 23/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIViewController-ILLocalization.h"
#import "ILLocalizationController.h"

@implementation UIViewController (ILLocalization)

- (NSSet*) localizableKeyPaths;
{
	return [NSSet set];
}

- (BOOL) canChangeCurrentLocalizationByReapplying;
{
	return NO;
}

// -------------------------------------------------

- (void) localize;
{
	NSSet* kps = self.localizableKeyPaths;
	
	if ([kps count] > 0)
		[[ILLocalizationController sharedController] localizeKeyPaths:kps ofObject:self table:self.nibName ?: NSStringFromClass([self class]) bundle:self.nibBundle];
}

// -------------------------------------------------

- (void) beginObservingLocalizationChangeNotifications;
{
	NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
	ILLocalizationController* il = [ILLocalizationController sharedController];
	
	[dc addObserver:self selector:@selector(_cloudspeak_willChangeLocalization:) name:kILLocalizationWillChangeCurrentNotification object:il];
	[dc addObserver:self selector:@selector(_cloudspeak_didChangeLocalization:) name:kILLocalizationDidChangeCurrentNotification object:il];
}

- (void) endObservingLocalizationChangeNotifications;
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kILLocalizationWillChangeCurrentNotification object:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kILLocalizationDidChangeCurrentNotification object:self];
}

- (void) _cloudspeak_willChangeLocalization:(NSNotification*) n;
{
	[self willChangeCurrentLocalization:[[n userInfo] objectForKey:kILLocalizationNewValueKey]];
}

- (void) _cloudspeak_didChangeLocalization:(NSNotification *)n;
{
	if (self.canChangeCurrentLocalizationByReapplying && [self isViewLoaded])
		[self localize];
	
	[self didChangeCurrentLocalization];
}

- (void) willChangeCurrentLocalization:(ILLocalization*) l {}

- (void) didChangeCurrentLocalization {}

@end

@implementation ILLocalizableViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
		[self beginObservingLocalizationChangeNotifications];
	
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder;
{
	if ((self = [super initWithCoder:aDecoder]))
		[self beginObservingLocalizationChangeNotifications];
	
	return self;
}

- (void) setValue:(id)value forUndefinedKey:(NSString *)key;
{
	if (!extraOutlets)
		extraOutlets = [NSMutableDictionary new];
	
	[extraOutlets setObject:value forKey:key];
}

- (id) valueForUndefinedKey:(NSString*) key;
{
	return [extraOutlets objectForKey:key];
}

- (void) viewDidLoad;
{
	[super viewDidLoad];
	[self localize];
}

- (void) viewDidUnload;
{
	[super viewDidUnload];
	[extraOutlets release]; extraOutlets = nil;
}

- (void) dealloc
{
	[self endObservingLocalizationChangeNotifications];
	[extraOutlets release];
	[super dealloc];
}

@end
