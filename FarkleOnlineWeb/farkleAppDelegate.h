//
//  farkleAppDelegate.h
//  FarkleOnlineWeb
//
//  Created by Mike Schmoyer on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface farkleAppDelegate : UIResponder <UIApplicationDelegate> {
    NSMutableDictionary *userPermissions;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSMutableDictionary *userPermissions;

@end
