//
//  ILLocalizationController-ILLanguagePicker.h
//  Cloudspeak
//
//  Created by ∞ on 23/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ILLocalizationController.h"

@interface ILLocalizationController (ILLanguagePicker)

- (NSInteger) indexOfPreferredLanguageAmongLanguages:(NSArray*) langs;

@end

enum {
	kILIdentifierComponentsPerfectMatch = 1000,
	kILIdentifierComponentsNoMatch = 0,
};

extern NSInteger ILLanguageMatchDegree(NSString* candidate, NSString* match);
extern NSInteger ILIdentifierComponentsMatchDegree(NSDictionary* candidate, NSDictionary* match);
