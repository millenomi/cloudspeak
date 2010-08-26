//
//  UIViewController-ILLocalization.h
//  Cloudspeak
//
//  Created by ∞ on 23/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ILLocalization.h"

@interface UIViewController (ILLocalization)

@property(readonly) NSSet* localizableKeyPaths;

@property(readonly) BOOL canChangeCurrentLocalizationByReapplying;

// --------------------------------

- (void) localize;

- (void) willChangeCurrentLocalization:(ILLocalization*) l;
- (void) didChangeCurrentLocalization;

@end

@interface ILLocalizableViewController : UIViewController {
	NSMutableDictionary* extraOutlets;
}

// This class can store undefined keys (ie outlets you make up in IB). They corresponding values are all retained, and get released whenever the view is unloaded (or the view controller is deallocated).
// To avoid this class having one thousand outlets -- subclass it. IB and your sanity will thank you.
- (id) valueForUndefinedKey:(NSString*) key;
- (void) setValue:(id)value forUndefinedKey:(NSString *)key;

@end
