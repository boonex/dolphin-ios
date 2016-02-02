//
//  Connector.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 8/21/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMLRPCResponse.h"
#import "XMLRPCRequest.h"
#import "XMLRPCConnection.h"
#import "ConnectorHelper.h"

@interface BxConnector : NSObject {
	NSURL *urlServerXMLRPC;
	NSOperationQueue *operationsQueue;
}

@property (nonatomic, retain) NSURL *urlServerXMLRPC;
@property (nonatomic, retain) NSOperationQueue *operationsQueue;

- (id)initWithSite:(NSString*)strSite;

- (NSString *)getXmlRpcUrlForSite:(NSString*)strSite;
    
- (id)execAsyncMethod:(NSString *)strMethod 
           withParams:(NSArray *)arrParams 
         withSelector:(SEL)anOperation 
    andSelectorObject:(id)idObject 
      andSelectorData:(id)idData 
         useIndicator:(UIActivityIndicatorView*)indicator;

- (void)callbackExecAsyncMethod:(id)response 
                         params:(NSArray *)params 
                       selector:(SEL)operation 
                 selectorObject:(id)object 
                   selectorData:(id)data 
                     connection:(XMLRPCConnection*)xmlrpcConn 
               connectionHelper:(ConnectorHelper*)connHelper;


+ (void)showErrorAlertWithDelegate:(id)aDelegate;
+ (void)showErrorAlertWithDelegate:(id)aDelegate responce:(id)aResp;
+ (void)showDictErrorAlertWithDelegate:(id)aDelegate responce:(id)aResp;

@end
