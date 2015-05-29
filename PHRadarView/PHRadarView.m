//
//  PHRadarView.m
//  PHRadarView
//
//  Created by Yang on 2015/05/29.
//  Copyright (c) 2015年 Yang PowHu. All rights reserved.
//

#import "PHRadarView.h"

@implementation PHRadarView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
        [self setup];
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

-(void)setup
{
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    radarLine = [[PHRadarLineView alloc] initWithFrame:self.bounds];
    radarLine.tintColor = self.tintColor;
    radarLine.backgroundColor = [UIColor clearColor];
    [self addSubview:radarLine];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    radarLine.frame = self.bounds;
    [radarLine setNeedsDisplay];
    
    for (UIView *v in self.subviews)
    {
        if ([v isKindOfClass:[UIImageView class]])
        {
            UIImageView *i = (UIImageView*)v;
            i.alpha = 0;
            i.tintColor = self.tintColor;
            i.image = [i.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    }
    
    [self startRadar];
}

-(void)update:(CADisplayLink*)displayLink
{
    CALayer* currentLayer = (CALayer*)[radarLine.layer presentationLayer];
    float currentRadians = [(NSNumber*)[currentLayer valueForKeyPath:@"transform.rotation.z"] floatValue];

    for (UIView *v in self.subviews)
    {
        if ([v isKindOfClass:[UIImageView class]])
        {
            CGFloat dx = v.center.x - self.frame.size.width / 2.0;
            CGFloat dy = -(v.center.y - self.frame.size.height / 2.0);
            CGFloat radians = atan2f(dx, dy);
            
            int cD = currentRadians * 180 / M_PI;
            int rD = radians * 180 / M_PI;
            
            if (abs(rD - cD) <= 15)
            {
                [self addShowAnimationToView:v];
            }
        }
    }
}

-(void)addShowAnimationToView:(UIView*)v
{
    if ([v.layer animationForKey:@"show"]) return;
    
    CAKeyframeAnimation *ani = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    ani.values = @[@0,@1,@0];
    ani.keyTimes = @[@0,@.3,@1];
    ani.duration = 0.6;
    ani.removedOnCompletion = 1;
    [v.layer addAnimation:ani forKey:@"show"];
    
}

-(void)startRadar
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 1.8;
    animation.fromValue = @0;
    animation.toValue = @(M_PI *2);
    animation.repeatCount = MAXFLOAT;
    [radarLine.layer addAnimation:animation forKey:@"rotate-layer"];
}

-(void)drawRect:(CGRect)rect
{
    CGFloat radius = MIN(self.frame.size.width, self.frame.size.height) / 2.0;
    CGRect r = CGRectMake(rect.size.width / 2.0 -radius, rect.size.height / 2.0 -radius, radius * 2, radius *2);
    
    //UIBezierPath *circle = [UIBezierPath bezierPathWithRoundedRect:r cornerRadius:radius];
    //[[UIColor colorWithWhite:0.3 alpha:1] setFill];
    //[circle fill];
    
    [[self.tintColor colorWithAlphaComponent:0.3] setStroke];
    for (int i = 0; i <= 3; i++)
    {
        CGRect rr = CGRectInset(r, r.size.width / 8 * i, r.size.width / 8 * i);
        UIBezierPath *drawLine = [UIBezierPath bezierPathWithRoundedRect:rr cornerRadius:rr.size.width / 2.0];
        drawLine.lineWidth = 2;
        [drawLine stroke];
    }
}


@end

@implementation PHRadarLineView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
        [self setup];
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

-(void)setup
{
    self.backgroundColor = [UIColor clearColor];
}

-(void)drawRect:(CGRect)rect
{
    CGFloat tWidth = 4;
    CGFloat bWidth = 2;
    
    UIBezierPath *p = [UIBezierPath bezierPath];
    [p moveToPoint:CGPointMake(CGRectGetMidX(rect) - bWidth, CGRectGetMidY(rect))];
    [p addLineToPoint:CGPointMake(CGRectGetMidX(rect) + bWidth, CGRectGetMidY(rect))];
    [p addLineToPoint:CGPointMake(CGRectGetMidX(rect) + tWidth, 0)];
    [p addLineToPoint:CGPointMake(CGRectGetMidX(rect) - tWidth, 0)];
    [p closePath];
    
    [[self.tintColor colorWithAlphaComponent:0.8] set];
    [p fill];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(CGRectGetMidX(rect) -12, 0, 12, rect.size.height / 2.0);
    gradientLayer.colors = [NSArray arrayWithObjects:(id)self.tintColor.CGColor, (id)[self.tintColor colorWithAlphaComponent:0].CGColor, nil];
    gradientLayer.startPoint = CGPointMake(1.0f, 0.0f);
    gradientLayer.endPoint = CGPointMake(.0f, 0.9f);
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

@end
