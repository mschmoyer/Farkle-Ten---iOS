//
//  farkleViewController.m
//  FarkleOnlineWeb
//
//  Created by Mike Schmoyer on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "farkleViewController.h"

@interface farkleViewController ()

@end

@implementation farkleViewController
@synthesize myWebview;

NSString *siteURL = @"http://www.farkledice.com/wwwroot";

bool webViewDidFinishLoadBool = NO;
int connectionAttempts = 0; 
bool haveUploadedToken = NO;
bool loggedIn = NO;
bool timerStarted = NO;

NSTimer *timer;
int timer_seconds;
int bannerHeight = 0;

- (void)viewDidLoad
{
    connectionAttempts = 0;

    [super viewDidLoad];
    
    [self loadFarkleWeb];
}

-(void) loadFarkleWeb {
    
    webViewDidFinishLoadBool = NO;
    //connectionAttempts = 0;
    
    //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *savedSession = Nil; //[prefs stringForKey:@"farkleSession"];
    NSURL *url;
    
    if( savedSession ) {
        NSLog(@"Session found. Using it. Sess=%@", savedSession);
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/farkle.php?device=ios_app&iossessionid=%@", siteURL, savedSession]];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/farkle.php?device=ios_app", siteURL]];
    }
    
    NSLog(@"Sending request to url: %@", url);
    
    // Go ahead and load the site in the web view. 
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [myWebview loadRequest:request];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    NSLog(@"Error=%@", error.description);
    
    connectionAttempts++;
    
    if( error.code == -1009 ) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Farkle Ten"
                                                       message: @"An internet connection is required to play Farkle Ten"
                                                      delegate: self
                                             cancelButtonTitle:Nil
                                             otherButtonTitles:@"OK",nil];
        
        
        [alert show];
        [self performSelector:@selector(loadFarkleWeb) withObject:Nil afterDelay:30.0];
        
    }else if( connectionAttempts >= 3 ) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Farkle Ten"
                                                       message: @"Uh oh...we failed to connect to Farkle Ten server."
                                                      delegate: self
                                             cancelButtonTitle:Nil
                                             otherButtonTitles:@"OK",nil];
        
        
        [alert show];
        [self performSelector:@selector(loadFarkleWeb) withObject:Nil afterDelay:30.0];
    } else {
        // Try again in a few seconds
        [self performSelector:@selector(loadFarkleWeb) withObject:Nil afterDelay:10.0];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSLog(@"webViewDidFinishLoad: Entered");
    if (connectionAttempts==0 && !haveUploadedToken && !webView.loading) {
        webViewDidFinishLoadBool = YES;
        [self performSelector:@selector(showPage) withObject:Nil afterDelay:1.0];
    }
}

-(void) showPage {
    [self.imgCover setHidden:YES];
    [self AttemptTokenUpload];
}

-(int)AttemptTokenUpload {
    
    NSLog(@"AttemptTokenUpload: Entered.");
    
    NSString *myCookies = [[myWebview stringByEvaluatingJavaScriptFromString:@"document.cookie"] copy];
    NSArray* cookies = [myCookies componentsSeparatedByString: @";"];

    NSArray *tempPieces;        
    NSString *session_id;
    
    for (id cookie in cookies) {
        // do something with object
        tempPieces = [cookie componentsSeparatedByString:@"="];

        NSString *key = [[tempPieces objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        if( [key isEqualToString:@"farklesession"] ) {
            session_id = [NSString stringWithFormat:@"%@", [tempPieces objectAtIndex:1]];
            NSLog(@"farklesession found. Value = %@", cookie);
        }
        if( [key isEqualToString:@"loggedin"] ) {
            loggedIn = [[tempPieces objectAtIndex:1] boolValue];
            NSLog(@"loggedin found. Value = %@", cookie);            
        }
    }
    //PHP says: 50020b8bbe49c
    //My Cookies say: 50020b7c24f01
    
    if( loggedIn && session_id && !haveUploadedToken ) {
        NSLog(@"User is logged in. Sessionid=%@", session_id);
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *deviceToken = [prefs stringForKey:@"farkleDeviceToken"];               
        
        if( deviceToken != Nil && session_id != Nil ) {
            
            farkleObj *fetcher = [farkleObj sharedSingleton];
            [fetcher DoFarkleRequest:self
                                 url:[NSURL URLWithString:[NSString stringWithFormat:@"%@/farkle_fetch.php", siteURL]]
                                post:[NSString stringWithFormat:@"action=iphonetoken&device=ios_app&devicetoken=%@&session_id=%@",
                                      deviceToken, session_id]
                      finishSelector:@selector(TokenHook:)
                        failSelector:Nil];
        }
        
        [prefs setObject:session_id forKey:@"farkleSession"];
        [prefs synchronize];
    } else {
        
        NSLog(@"User is not logged in or session_id is missing.");
        
        [self performSelector:@selector(AttemptTokenUpload) withObject:Nil afterDelay:5];
        //[self StartTimer];
        return 0;
    }
    
    return 1;
}

-(void)TokenHook: (NSDictionary *)jsonData {

    if( [jsonData objectForKey:@"Message"] )
    {
        NSLog(@"Device token uploaded successfully.");
        haveUploadedToken = YES;
    } else {
        // error
        NSLog(@"Token Error: %@", [jsonData objectForKey:@"Error"]);

        [self performSelector:@selector(AttemptTokenUpload) withObject:Nil afterDelay:10.0];
    }
    
    return;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        
        // Assumes the banner view is just off the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        [UIView commitAnimations];

        bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // Assumes the banner view is placed at the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        //[UIView commitAnimations];
        bannerIsVisible = NO;
        [UIView commitAnimations];
        
        bannerHeight = 0;
    }
}

- (void)viewDidUnload
{
    [self setMyWebview:nil];
    [self setImgCover:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
