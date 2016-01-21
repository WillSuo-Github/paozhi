//
//  ViewController.m
//  paozhi
//
//  Created by ws on 16/1/21.
//  Copyright © 2016年 ws. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *image;
@property (nonatomic, weak) IBOutlet UIView *redSquare;
@property (nonatomic, weak) IBOutlet UIView *blueSquare;


@property (nonatomic, assign) CGRect originalBounds;
@property (nonatomic, assign) CGPoint originalCenter;

@property (nonatomic) UIDynamicAnimator *animator;
@property (nonatomic) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic) UIPushBehavior *pushBehavior;
@property (nonatomic) UIDynamicItemBehavior *itemBehavior;

@end

@implementation ViewController

static const CGFloat ThrowingThreshold = 1000;
static const CGFloat ThrowingVelocityPadding = 35;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.originalBounds = self.image.bounds;
    self.originalCenter = self.image.center;
}


- (IBAction) handleAttachmentGesture:(UIPanGestureRecognizer*)gesture
{
    CGPoint location = [gesture locationInView:self.view];
    CGPoint boxLocation = [gesture locationInView:self.image];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
            NSLog(@"you touch started position %@",NSStringFromCGPoint(location));
            NSLog(@"location in image started is %@",NSStringFromCGPoint(boxLocation));
            
            [self.animator removeAllBehaviors];
            UIOffset centerOffset = UIOffsetMake(boxLocation.x - CGRectGetMidX(self.image.bounds), boxLocation.y - CGRectGetMidY(self.image.bounds));
            self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.image
                                                                offsetFromCenter:centerOffset
                                                                attachedToAnchor:location];
            
            // 3
            self.redSquare.center = self.attachmentBehavior.anchorPoint;
            self.blueSquare.center = location;
            
            // 4
            [self.animator addBehavior:self.attachmentBehavior];
            
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self.animator removeBehavior:self.attachmentBehavior];
            
            //1
            CGPoint velocity = [gesture velocityInView:self.view];//速度
            CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
            
            if (magnitude > ThrowingThreshold) {
                //2
                UIPushBehavior *pushBehavior = [[UIPushBehavior alloc]
                                                initWithItems:@[self.image]
                                                mode:UIPushBehaviorModeInstantaneous];
                pushBehavior.pushDirection = CGVectorMake((velocity.x / 10) , (velocity.y / 10));
                pushBehavior.magnitude = magnitude / ThrowingVelocityPadding;
                
                self.pushBehavior = pushBehavior;
                [self.animator addBehavior:self.pushBehavior];
                
                //3
//                NSInteger angle = arc4random_uniform(20) - 10;
                NSInteger angle = 10;
                
                self.itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.image]];
                self.itemBehavior.friction = 0.2;
                self.itemBehavior.allowsRotation = YES;
                [self.itemBehavior addAngularVelocity:angle forItem:self.image];
                [self.animator addBehavior:self.itemBehavior];
                
                //4
                [self performSelector:@selector(resetDemo) withObject:nil afterDelay:0.4];
            }
            
            else {
                [self resetDemo];
            }
            break;
        }
        default:
            
            
            [self.attachmentBehavior setAnchorPoint:[gesture locationInView:self.view]];
            self.redSquare.center = self.attachmentBehavior.anchorPoint;
            break;
    }
}


- (void)resetDemo
{
    [self.animator removeAllBehaviors];
    
    [UIView animateWithDuration:0.45 animations:^{
        self.image.bounds = self.originalBounds;
        self.image.center = self.originalCenter;
        self.image.transform = CGAffineTransformIdentity;
    }];
}



@end
