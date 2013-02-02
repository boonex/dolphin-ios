//
//  ConnectorHelper.h
//  Dolphin6
//
//  Created by Alex Trofimov on 11/03/11.
//  Copyright 2011 BoonEx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLRPCConnection.h"

@class BxConnector;

@interface ConnectorHelper : NSObject {
    NSArray *params;
    SEL operation;
    id object;
    id data;
    BxConnector *conn;
}

- (id)initWithConnector:(BxConnector *)aConnector params:(NSArray *)arrParams selector:(SEL)anOperation selectorObject:(id)idObject selectorData:(id)idData;

@end
