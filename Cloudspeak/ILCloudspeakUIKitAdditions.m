//
//  ILCloudspeakUIKitAdditions.m
//  Cloudspeak
//
//  Created by ∞ on 25/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILCloudspeakUIKitAdditions.h"


@implementation UIButton (ILCloudspeakUIKitAdditions)

- (NSString*) localizableNormalTitle;
{
	return [self titleForState:UIControlStateNormal];
}

- (void) setLocalizableNormalTitle:(NSString*) x;
{
	[self setTitle:x forState:UIControlStateNormal];
}

@end
