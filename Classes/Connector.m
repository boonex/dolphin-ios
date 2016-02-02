//
//  Connector.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 8/21/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "config.h"
#import "Connector.h"
#import "ConnectorHelper.h"

@implementation BxConnector

@synthesize urlServerXMLRPC, operationsQueue;

- (NSString *)getXmlRpcUrlForSite:(NSString*)strSite {
	
	NSString *strTmp = nil;
	NSString *strReturn = nil;
	
	if (NO == [strSite hasPrefix:@"http://"] && NO == [strSite hasPrefix:@"https://"])
		strTmp = [[NSString alloc] initWithFormat:@"%@%@", @"http://", strSite];
	else
		strTmp = [[NSString alloc] initWithFormat:@"%@", strSite];
	
	if (YES == [strTmp hasSuffix:@"/"])	
		strReturn = [strTmp stringByAppendingString:@"xmlrpc/"];	
	else
		strReturn = [strTmp stringByAppendingString:@"/xmlrpc/"];	
	
	[strTmp release];
	
	NSLog(@"XMLRPC server url: %@", strReturn); 
	
	return strReturn;
}

- (id)initWithSite:(NSString*)strSite {
    if ((self = [super init])) {
		NSString * strServerUrl = [self getXmlRpcUrlForSite:strSite];
		NSLog (@"SERVER URL: %@", strServerUrl);
		urlServerXMLRPC = [[NSURL alloc] initWithString:strServerUrl]; 
		operationsQueue = [[NSOperationQueue alloc] init];
		[operationsQueue setMaxConcurrentOperationCount:2];		
    }
    return self;
}

/**
 * show error alert when internet connection error occured
 */
- (BOOL)handleError:(NSError *)err
{
	UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Communication Error"
													 message:[err localizedDescription]
													delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[al show];
	[al release];
	return YES;
}

/**
 * build defualt error object
 */
- (NSError *)defaultError
{
	NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Failed to request XMLRPC server.", NSLocalizedDescriptionKey, nil];
	return [NSError errorWithDomain:@"com.boonex.iphone.dolphin6" code:-1 userInfo:usrInfo];
}

/**
 * build error object from XMLRPC responce object
 */
- (NSError *)errorWithResponse:(XMLRPCResponse *)res shouldHandle:(BOOL)shouldHandleFlag
{
	NSError *err = nil;
	if( !res )
		err = [self defaultError];
	
	if ( [res isKindOfClass:[NSError class]] )
		err = (NSError *)res;
	else
	{
		if ( [res isFault] )
		{
			NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:[res fault], NSLocalizedDescriptionKey, nil];
			err = [NSError errorWithDomain:@"com.boonex.iphone.dolphin6" code:[[res code] intValue] userInfo:usrInfo];
		}
		
		if ( [res isParseError] )
		{
			err = [res object];
		}		
	}
	
	if( err && shouldHandleFlag )
	{		
		NSString *zeroPostsError = @"Something wrong with XMLRPC service.";
		NSRange range = [[err description] rangeOfString:zeroPostsError options:NSBackwardsSearch];
		if (range.location == NSNotFound)
			[self handleError:err];
	}
	
	return err;
}

/**
 * callback function on async XMLRPC request
 */
- (void)callbackExecAsyncMethod:(id)response 
                         params:(NSArray *)params 
                       selector:(SEL)operation 
                 selectorObject:(id)object 
                   selectorData:(id)data 
                     connection:(XMLRPCConnection*)xmlrpcConn 
               connectionHelper:(ConnectorHelper*)connHelper {
    
    [xmlrpcConn release];
    
    id idResp = response;
    
	NSMethodSignature * sig = nil;
	sig = [[object class] instanceMethodSignatureForSelector:operation];
	
	NSInvocation * myInvocation = nil;
	myInvocation = [NSInvocation invocationWithMethodSignature:sig];
	[myInvocation setTarget:object];
	[myInvocation setSelector:operation];
        
    if (nil == data)
	{
		data = [NSMutableDictionary dictionary];	
		[data setObject:idResp forKey:BX_KEY_RESP];
	}
	else if ([data isKindOfClass:[NSMutableDictionary class]])
    {
        [data setObject:idResp forKey:BX_KEY_RESP];
    }

    
	id o = [myInvocation target];
	[o performSelectorOnMainThread:[myInvocation selector] withObject:data waitUntilDone:NO];
    
    // http://theocacao.com/document.page/264
}

/**
 * exec async request to XMLRPC server
 */
- (id)execAsyncMethod:(NSString *)strMethod 
           withParams:(NSArray *)arrParams 
         withSelector:(SEL)anOperation 
    andSelectorObject:(id)idObject 
      andSelectorData:(id)idData 
         useIndicator:(UIActivityIndicatorView*)indicator {
	

	// fool checking
	if( ![idObject respondsToSelector:anOperation] )
	{
		NSLog(@"ERROR: %@ can't respond to the Operation %@.", idObject, NSStringFromSelector(anOperation));
		return nil;
	}
	
	if(idData != nil && ![idData isKindOfClass:[NSMutableDictionary class]])
	{
		NSLog(@"ERROR: idData must be subclass of NSMutableDictionary or nil");
		return nil;
	}

    // create request 
	XMLRPCRequest *req = [[XMLRPCRequest alloc] initWithHost:urlServerXMLRPC]; // TODO: check if req is released
	[req setMethod:strMethod withObjects:arrParams];
    
	// send request
    ConnectorHelper *connHelper = [[ConnectorHelper alloc] initWithConnector:self 
                                                                      params:arrParams 
                                                                    selector:anOperation 
                                                              selectorObject:idObject 
                                                                selectorData:idData];
    
    [[XMLRPCConnection alloc] initWithXMLRPCRequest:req delegate:connHelper];
    
    [req release];
    [connHelper release];
    
    return nil;
}

- (void)dealloc {
	[urlServerXMLRPC release];
	[operationsQueue release];
	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    urlServerXMLRPC = [[coder decodeObjectForKey:@"MVServerUrl"] retain];
	operationsQueue = [[NSOperationQueue alloc] init];
	[operationsQueue setMaxConcurrentOperationCount:2];
    return self;	
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:urlServerXMLRPC forKey:@"MVServerUrl"];
}

+ (void)showErrorAlertWithDelegate:(id)aDelegate {
	UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Title", @"Error Alert Title") message:NSLocalizedString(@"Connection Error", @"Error Alert Text") delegate:aDelegate cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button Title") otherButtonTitles:nil];
	[al show];
	[al release];	
}

+ (void)showErrorAlertWithDelegate:(id)aDelegate responce:(id)aResp {
#ifdef DEBUG
	UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Title", @"Error Alert Title") message:[((NSError*)aResp) localizedDescription] delegate:aDelegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
#else
	UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Title", @"Error Alert Title") message:NSLocalizedString(@"Connection Error", @"Error Alert Text") delegate:aDelegate cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button Title") otherButtonTitles:nil];
#endif
	[al show];
	[al release];	
}

+ (void)showDictErrorAlertWithDelegate:(id)aDelegate responce:(id)aResp {    
    NSDictionary *dict = (NSDictionary *)aResp;    
#ifdef DEBUG    
    NSString *s = [dict objectForKey:@"faultString"];
    if (nil == s && nil != [dict objectForKey:@"error"])
        s = NSLocalizedString(@"Error occured", @"Error occured alert text");
    if (nil == s)
        s = NSLocalizedString(@"Connection Error", @"Error Alert Text");    
	UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Title", @"Error Alert Title") message:s delegate:aDelegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
#else
    NSString *s = NSLocalizedString(@"Connection Error", @"Error Alert Text");
    if (nil != [dict objectForKey:@"error"])
        s = NSLocalizedString(@"Error occured", @"Error occured alert text"); 
	UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Title", @"Error Alert Title") message:s delegate:aDelegate cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button Title") otherButtonTitles:nil];
#endif
	[al show];
	[al release];	
}

@end
