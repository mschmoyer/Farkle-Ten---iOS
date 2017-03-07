//
//  farkleViewController.h
//  FarkleOnlineWeb
//
//  Created by Mike Schmoyer on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
//#import <FacebookSDK/FacebookSDK.h>
#import "farkleObj.h"

@interface farkleViewController : UIViewController <ADBannerViewDelegate> {
    ADBannerView *adView;
    BOOL bannerIsVisible;
    //FBSession *fbSession;
}
@property (weak, nonatomic) IBOutlet UIWebView *myWebview;
@property (weak, nonatomic) IBOutlet UIImageView *imgCover;

@end
