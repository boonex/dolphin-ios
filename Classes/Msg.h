//
//  User.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 8/21/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Connector.h"

@interface BxMsg : NSObject {
	NSString *strSubj;
	NSString *strBody;
	NSInteger intId;
}

@property (nonatomic, copy) NSString *strSubj;
@property (nonatomic, copy) NSString *strBody;
@property (nonatomic, assign) NSInteger intId;

- (id) initWithDataId:(NSInteger)integerId subject:(NSString*)stringSubj andBody:(NSString*) stringBody;
- (void) setDataId:(NSInteger)integerId subject:(NSString*)stringSubj andBody:(NSString*) stringBody;

@end
