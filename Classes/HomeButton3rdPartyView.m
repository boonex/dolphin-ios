//
//  HomeButton3rdPartyView.m
//  Dolphin6
//
//  Created by Alex Trofimov on 5/07/11.
//  Copyright 2011 BoonEx. All rights reserved.
//

#import "HomeButton3rdPartyView.h"

@implementation HomeButton3rdPartyView

- (id)initWithOrigin:(CGPoint)anOrigin text:(NSString*)aText imageResource:(NSString*)anImageRes index:(NSInteger)anIndex indexAction:(NSInteger)anIndexAction data:(NSString*)aData delegate:(NSObject<HomeButtonViewDelegate> *)aDelegate {
    
	if ((self = [super initWithOrigin:anOrigin text:aText imageResource:anImageRes index:anIndex indexAction:anIndexAction delegate:aDelegate])) {
        sData = [aData retain];
	}
	
	return self; 
}

- (void)dealloc {	
    [sData release];
    [super dealloc];
}
                 

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

- (NSString*)getData {
    return sData;
}

@end
