//
//  farkleFetcher.h
//  Farkle Online
//
//  Created by Mike Schmoyer on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON/JSON.h"
#import "NSString+MD5.h"

@interface farkleObj : NSObject {
    NSMutableData *responseData;
    //NSURLConnection *theConnection;
    id theDelegate;
    SEL theFinishSelector;
    SEL theFailSelector;
    NSURL *theURL;
}

+ (farkleObj *)sharedSingleton;

- (void) DoFarkleRequest: (id)aDelegate
                     url:(NSURL *)aURL
                    post:(NSString*)aPost
          finishSelector:(SEL)finish
            failSelector:(SEL)fail;

- (void) LoginWithFarkle: (id)aDelegate
                    user:(NSString*)theUser
                     pwd:(NSString*)thePwd
          finishSelector:(SEL)finish
            failSelector:(SEL)fail;

@end
