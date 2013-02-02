//
//  HomeButton3rdPartyView.h
//  Dolphin6
//
//  Created by Alex Trofimov on 5/07/11.
//  Copyright 2011 BoonEx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomeButtonView.h"

@interface HomeButton3rdPartyView : HomeButtonView {
    NSString *sData;
}

- (id)initWithOrigin:(CGPoint)anOrigin text:(NSString*)aText imageResource:(NSString*)anImageRes index:(NSInteger)anIndex indexAction:(NSInteger)anIndexAction data:(NSString*)aData delegate:(NSObject<HomeButtonViewDelegate> *)aDelegate;

- (NSString*)getData;

@end
