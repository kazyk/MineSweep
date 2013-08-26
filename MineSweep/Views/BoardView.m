//
//  Created by TAKAHASHI kazuyuki on 2013/08/23.
//


#import "BoardView.h"
#import "SquareView.h"
#import "Square.h"

static const CGSize kSquareSize = {40, 40};


@interface BoardView() <BoardDelegate>
@property (nonatomic) NSMutableArray *squareViews;
@end


@implementation BoardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _squareViews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(self.board.horizontalSize * kSquareSize.width, self.board.verticalSize * kSquareSize.height);
}

- (void)setBoard:(Board *)board
{
    if (_board == board) {
        return;
    }
    _board.delegate = nil;
    _board = board;
    board.delegate = self;

    for (UIView *view in self.squareViews) {
        [view removeFromSuperview];
    }

    [self.board enumerate:^(BoardPoint p, BOOL *stop) {
        SquareView *view = [[SquareView alloc] initWithFrame:[self frameForSquareAtPoint:p]
                                                      square:[self.board squareAtPoint:p]];
        [self addSubview:view];
        [self.squareViews addObject:view];
    }];
}

- (CGRect)frameForSquareAtPoint:(BoardPoint)point
{
    return CGRectMake(point.x * kSquareSize.width, point.y * kSquareSize.height, kSquareSize.width, kSquareSize.height);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject] locationInView:self];

    UIView *view = [self hitTest:p withEvent:event];
    if ([view isKindOfClass:[SquareView class]]) {
        SquareView *squareView = (SquareView *)view;
        [self.board openSquareAtPoint:squareView.square.point];
    }

    NSLog(@"%@", self.board);
}

#pragma mark - BoardDelegate

- (void)boardWillDrop:(Board *)board
{
    //openedなやつを消す
    NSPredicate *opened = [NSPredicate predicateWithBlock:^BOOL(SquareView *evaluatedObject, NSDictionary *bindings) {
        return (evaluatedObject.square.isOpened);
    }];
    NSArray *squareViewsToRemove = [self.squareViews filteredArrayUsingPredicate:opened];
    [UIView animateWithDuration:0.3 animations:^{
        for (UIView *v in squareViewsToRemove) {
            v.alpha = 0;
        }
    } completion:^(BOOL finished) {
        for (UIView *v in squareViewsToRemove) {
            [v removeFromSuperview];
        }
    }];

    [self.squareViews removeObjectsInArray:squareViewsToRemove];
}

- (void)boardDidDrop:(Board *)board newSquares:(NSArray *)newSquares
{
    for (Square *sq in newSquares) {
        CGRect frame = [self frameForSquareAtPoint:sq.point];
        frame.origin.y -= 300;

        SquareView *squareView = [[SquareView alloc] initWithFrame:frame square:sq];
        [self.squareViews addObject:squareView];
        [self addSubview:squareView];
    }

    [UIView animateWithDuration:0.4 animations:^{
        for (SquareView *squareView in self.squareViews) {
            squareView.frame = [self frameForSquareAtPoint:squareView.square.point];
        }
    } completion:^(BOOL finished) {

    }];

    NSLog(@"%@", self.board);
}

@end