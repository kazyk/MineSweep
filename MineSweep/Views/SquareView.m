//
//  Created by TAKAHASHI kazuyuki on 2013/08/23.
//

#import <QuartzCore/QuartzCore.h>
#import "SquareView.h"
#import "Square.h"
#import "BoardView.h"

static char kKVOContextOpened;
static char kKVOContextPoint;


@interface SquareView()
@property (nonatomic) UILabel *label;
@property (nonatomic) UIView *boxView;
@end


@implementation SquareView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.color = [UIColor colorWithRed:0.1 green:0.6 blue:0.9 alpha:0.9];
        self.backgroundColor = [UIColor whiteColor];

        [self addObserver:self forKeyPath:@"square.opened" options:0 context:&kKVOContextOpened];
        [self addObserver:self forKeyPath:@"square.point" options:0 context:&kKVOContextPoint];
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    if (newWindow) {
        //setup
        [self.boxView removeFromSuperview];
        self.boxView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 4, 4)];
        self.boxView.userInteractionEnabled = NO;   //touchEventとられないようにする
        [self addSubview:self.boxView];

        if (!self.square.isOpened) {
            self.boxView.layer.borderColor = self.color.CGColor;
            self.boxView.layer.borderWidth = 0.5;
            self.boxView.layer.backgroundColor = [self.color colorWithAlphaComponent:0.3].CGColor;
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //マスをタッチしたときのアニメーション
    self.layer.borderColor = self.color.CGColor;
    CABasicAnimation *border = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
    border.fromValue = @3.0;
    border.toValue = @0.0;
    border.duration = 0.3;
    [self.layer addAnimation:border forKey:@"border"];
    CABasicAnimation *bg = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    bg.fromValue = (id)[self.color colorWithAlphaComponent:0.5].CGColor;
    bg.toValue = (id)[UIColor whiteColor].CGColor;
    bg.duration = 0.7;
    [self.layer addAnimation:bg forKey:@"bg"];

    //superviewにeventを伝播させる
    [super touchesBegan:touches withEvent:event];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &kKVOContextOpened) {
        [self updateLabel];

        if (self.square.isOpened) {
            [UIView animateWithDuration:0.3 animations:^{
                self.boxView.alpha = 0;
            } completion:^(BOOL finished) {
                [self.boxView removeFromSuperview];
                self.boxView = nil;
            }];
        }
    } else if (context == &kKVOContextPoint) {
        if ([self boardView]) {
            CGRect newFrame = [[self boardView] frameForSquareAtPoint:self.square.point];
            [UIView animateWithDuration:0.3 animations:^{
                self.frame = newFrame;
            } completion:^(BOOL finished) {

            }];
        }
    }
}

#pragma mark - private methods

- (void)updateLabel
{
    if (!self.label) {
        self.label = [[UILabel alloc] initWithFrame:self.bounds];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.font = [UIFont systemFontOfSize:20];
        self.label.textColor = [UIColor grayColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        [self addSubview:self.label];
    }

    if (self.square.isOpened) {
        self.label.text = [self.square description];
    }
}

- (BoardView *)boardView
{
    return (BoardView *)self.superview;
}

@end