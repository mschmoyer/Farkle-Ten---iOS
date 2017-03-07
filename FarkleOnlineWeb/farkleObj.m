//
//  farkleFetcher.m
//  Farkle Online
//
//  Created by Mike Schmoyer on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "farkleObj.h"

static farkleObj *shared = NULL;

bool ACTIVE_REQUEST = NO;


@implementation farkleObj

- (id)init
{
    if ( self = [super init] )
    {
        //self.keys = [[NSMutableDictionary alloc] init];
        responseData = [[NSMutableData alloc] init];
    }
    return self;
    
}

+ (farkleObj *)sharedSingleton
{
    @synchronized(shared)
    {
        if ( !shared || shared == NULL )
        {
            // allocate the shared instance, because it hasn't been done yet
            shared = [[farkleObj alloc] init];
        }
        
        return shared;
    }
}



- (void) LoginWithFarkle: (id)aDelegate user:(NSString*)theUser pwd:(NSString*)thePwd 
          finishSelector:(SEL)finish 
            failSelector:(SEL)fail {
    
    theDelegate = aDelegate;
    theFinishSelector = finish;
    theFailSelector = fail;
    
    NSString *hashedPass = [thePwd MD5];
    NSString *hashedUser = [theUser MD5];
    
    [self farkleFetcherPost:[NSString stringWithFormat:@"action=login&user=%@&pass=%@&remember=1",hashedUser,hashedPass]];
}

- (void) DoFarkleRequest: (id)aDelegate
                     url:(NSURL *)aURL
                    post:(NSString*)aPost
          finishSelector:(SEL)finish 
            failSelector:(SEL)fail {
    
    theURL = aURL;
    theDelegate = aDelegate;
    theFinishSelector = finish;
    theFailSelector = fail;    
    
    [self farkleFetcherPost:aPost];
}

- (void) farkleFetcherPost: (NSString *)post {
    
    NSLog(@"Farkle Request. PostData = [%@]", post);
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding];    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:theURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
	//theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSURLConnection *aConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (aConnection) {
        
        // Create the NSMutableData to hold the received data.
        
        // receivedData is an instance variable declared elsewhere.
        
        //receivedData = [[NSMutableData data] retain];
        
    } else {
        
        // Inform the user that the connection failed.
        
    }
}



- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"%@", [NSString stringWithFormat:@"Connection failed: %@", [error description]]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"ResponseString = [%@]" , responseString);
    
	NSDictionary *json = [responseString JSONValue];
    
	//NSMutableString *text = [NSMutableString stringWithString:@"Lucky numbers:\n"];
    
    NSLog(@"Farkle Request - Finished Loading. JSON=%@", json);
    
    [theDelegate performSelector:theFinishSelector withObject:json];
}

- (void)dealloc
{
    NSLog(@"Deallocating farkleFetcher...");
}

@end
