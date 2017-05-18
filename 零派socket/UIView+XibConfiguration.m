//
//  UIView+XibConfiguration.m
//  Lecarx
//
//  Created by OLi on 15/8/27.
//  Copyright (c) 2015年 Lecarx. All rights reserved.
//

#import "UIView+XibConfiguration.h"

@implementation UIView (XibConfiguration)
// LayerColor
-(UIColor*)borderUIColor {
    return [UIColor colorWithCGColor:self.layer.borderColor];
}
-(void)setLayerColor:(UIColor *)LayerColor_ {
    self.layer.borderColor = LayerColor_.CGColor;
}
- (UIColor *)LayerColor {
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

// LayerWidth
- (void)setLayerWidth:(CGFloat)LayerWidth_ {
    self.layer.borderWidth = LayerWidth_;
    self.layer.allowsEdgeAntialiasing = YES;// 解决layer.border.width随着view的放大，会出现锯齿化的问题（iOS7.0）
}
- (CGFloat)LayerWidth {
    return self.layer.borderWidth;
}

// LayerRadius
- (void)setLayerRadius:(CGFloat)LayerRadius_ {
    self.layer.cornerRadius = LayerRadius_;
}
- (CGFloat)LayerRadius {
    return self.layer.cornerRadius;
}

// LayerShadowOffset
- (void)setShadowOffset:(CGSize)ShadowOffset_ {
    self.layer.shadowOffset = ShadowOffset_;
}
- (CGSize)ShadowOffset {
    return self.layer.shadowOffset;
}

// LayerShadowRadius
- (void)setShadowRadius:(CGFloat)ShadowRadius_ {
    self.layer.shadowRadius = ShadowRadius_;
}
- (CGFloat)ShadowRadius {
    return self.layer.shadowRadius;
}

// LayerShadowOpacity
- (void)setShadowOpacity:(CGFloat)ShadowOpacity_ {
    self.layer.shadowOpacity = ShadowOpacity_;
}
- (CGFloat)ShadowOpacity {
    return self.layer.shadowOpacity;
}

// LayerShadowColor
- (void)setShadowColor:(UIColor *)ShadowColor_ {
    self.layer.shadowColor = ShadowColor_.CGColor;
}
- (UIColor *)ShadowColor {
    return [UIColor colorWithCGColor:self.layer.shadowColor];
}

@end
