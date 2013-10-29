//
//  BackgroundView.h
//  Dolphin6
//
//  Created by Alex Trofimov on 24/02/11.
//  Copyright 2011 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BackgroundView : UIView {
	Boolean withSpaces;
    
    CGFloat fRed;
    CGFloat fGreen;
    CGFloat fBlue;
    CGFloat fAlpha;
}

- (id)initWithFrame:(CGRect)frame selected:(Boolean)isSelected withSpaces:(Boolean)isWithSpaces;
- (id)initWithFrameHome:(CGRect)frame selected:(Boolean)isSelected withSpaces:(Boolean)isWithSpaces;
- (id)initWithFrameCustom:(CGRect)frame withSpaces:(Boolean)isWithSpaces r:(CGFloat)red g:(CGFloat)green b:(CGFloat)blue a:(CGFloat)alpha;

@end
