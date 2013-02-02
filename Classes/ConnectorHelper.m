//
//  ConnectorHelper.m
//  Dolphin6
//
//  Created by Alex Trofimov on 11/03/11.
//  Copyright 2011 BoonEx. All rights reserved.
//

#import "ConnectorHelper.h"
#import "Connector.h"
#import "config.h"

@implementation ConnectorHelper

- (id)initWithConnector:(BxConnector *)aConnector params:(NSArray *)arrParams selector:(SEL)anOperation selectorObject:(id)idObject selectorData:(id)idData {
    if ((self = [super init])) {
        params = [arrParams retain];
        operation = anOperation;
        object = [idObject retain];
        data = [idData retain];
        conn = [aConnector retain];
    }
    return self;
}

- (void)connection: (XMLRPCConnection *)xmlrpcConnection didReceiveResponse: (XMLRPCResponse *)response forMethod: (NSString *)method {
    
    [conn callbackExecAsyncMethod:[response object] 
                           params:params 
                         selector:operation 
                   selectorObject:object 
                     selectorData:data 
                       connection:xmlrpcConnection 
                 connectionHelper:self];
    
}

- (void)connection: (XMLRPCConnection *)xmlrpcConnection didFailWithError: (NSError *)error forMethod: (NSString *)method {
    
    [conn callbackExecAsyncMethod:(XMLRPCResponse *)error 
                           params:params 
                         selector:operation 
                   selectorObject:object 
                     selectorData:data 
                       connection:xmlrpcConnection 
                 connectionHelper:self];
    
}

- (void)dealloc {
	[params release];
	[object release];
    [data release];
    [conn release];
	[super dealloc];
}

@end
