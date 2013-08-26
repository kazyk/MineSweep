//
//  ViewController.m
//  MineSweap
//
//  Created by kazuyuki takahashi on 2013/08/23.
//  Copyright (c) 2013 kazuyuki takahashi. All rights reserved.
//

#import "ViewController.h"
#import "Game.h"
#import "BoardView.h"

static char kKVOContextFailedTimes;

@interface ViewController ()
@property (nonatomic) Game *game;
@property (nonatomic) BoardView *boardView;
@property (nonatomic) IBOutlet UILabel *turnLabel;
@property (nonatomic) IBOutlet UILabel *failedLabel;
@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    BoardView *boardView = [[BoardView alloc] init];
    [self.view addSubview:boardView];
    self.boardView = boardView;

    [self updateTurnLabel];
    self.failedLabel.text = @"";

    [self setupGame];

    [self addObserver:self forKeyPath:@"game.board.failedTimes" options:0 context:&kKVOContextFailedTimes];
}

- (void)setupGame
{
    self.game = [[Game alloc] init];

    self.boardView.board = self.game.board;
    [self.boardView sizeToFit];

    CGRect frame = self.boardView.frame;
    frame.origin.y = CGRectGetMidY(self.view.bounds) - CGRectGetHeight(frame) / 2;
    self.boardView.frame = frame;
}

- (IBAction)reset
{
    [self setupGame];
    [self updateTurnLabel];
}

- (IBAction)drop
{
    [self.game.board drop];
    [self updateTurnLabel];
}

- (void)updateTurnLabel
{
    self.turnLabel.text = [@(self.game.board.currentTurn) stringValue];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &kKVOContextFailedTimes) {
        //失敗数だけxならべる
        NSMutableString *s = [[NSMutableString alloc] init];
        for (int i = 0; i < self.game.board.failedTimes; ++i) {
            [s appendString:@"x"];
        }
        self.failedLabel.text = s;
    }
}

@end