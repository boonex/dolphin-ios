//
//  ProfileBlock.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/6/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileIconBlock.h"

@class BxUser;

@interface ProfileBlock : ProfileIconBlock {

}

- (id)initWithData:(id)aData reuseIdentifier:(NSString *)reuseIdentifier;

@end
