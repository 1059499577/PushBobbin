//
//  UIView+XibConfiguration.h
//  Lecarx
//
//  Created by OLi on 15/8/27.
//  Copyright (c) 2015年 Lecarx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (XibConfiguration)

@property (nonatomic, assign) IBInspectable UIColor *LayerColor;
@property (nonatomic, assign) IBInspectable CGFloat  LayerWidth;
@property (nonatomic, assign) IBInspectable CGFloat  LayerRadius;

@property (nonatomic, assign) IBInspectable CGSize   ShadowOffset;
@property (nonatomic, assign) IBInspectable CGFloat  ShadowRadius;
@property (nonatomic, assign) IBInspectable CGFloat  ShadowOpacity;
@property (nonatomic, assign) IBInspectable UIColor *ShadowColor;

@end
