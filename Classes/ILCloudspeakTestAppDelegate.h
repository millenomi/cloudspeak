//
//  CloudspeakAppDelegate.h
//  Cloudspeak
//
//  Created by ∞ on 23/08/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController-ILLocalization.h"

@interface ILCloudspeakTestFirstVC : ILLocalizableViewController
@end

@interface ILCloudspeakTestSecondVC : ILLocalizableViewController
@end


@interface ILCloudspeakTestAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

