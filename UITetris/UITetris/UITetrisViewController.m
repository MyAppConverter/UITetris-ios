/*
 * UITetrisViewController.m
 *
 * Author: Charles Magahern <charles@magahern.com>
 * Date Created: 03/28/2012
 */
 
#import "UITetrisViewController.h"
#import "UITetrisView.h"
#import "UITetronimo.h"

#define kControllerMoveSensitivity      22.0f
#define kControllerRotateSensitivity    5.0f
#define kControllerMoveDownSensitivity  20.0f


@interface UITetrisViewController ()

- (void)swipeDownGestureAction:(UISwipeGestureRecognizer *)recognizer;

@end


@implementation UITetrisViewController

- (id)init
{
    if ((self = [super init])) {
        // Setup Game
        tetrisGame = [[UITetrisGame alloc] init];
        [tetrisGame setGameDelegate:self];
        [tetrisGame setGameSpeed:3.5];
        [tetrisGame startGame];
        
        
        // Setup View
        CGRect windowBounds = [[UIScreen mainScreen] bounds];
        UITetrisView *tetrisView = [[UITetrisView alloc] initWithFrame:CGRectMake(0.0, 0.0, windowBounds.size.width, windowBounds.size.height)];
        tetrisView.game = tetrisGame;
        self.view = tetrisView;
        [tetrisView release];
        
        
        // Setup controls
        _touchDistanceMoved = 0.0;
        UISwipeGestureRecognizer *swipeGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDownGestureAction:)];
        [swipeGR setDirection:UISwipeGestureRecognizerDirectionDown];
        [self.view addGestureRecognizer:swipeGR];
        [swipeGR release];
        
        
        // Setup Music
        NSError *err = nil;
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"tetris" withExtension:@"m4a"];
        musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
        musicPlayer.numberOfLoops = -1;
        [musicPlayer play];
    }
    
    return self;
}

- (void)dealloc
{
    if (tetrisGame != nil)
        [tetrisGame release];
    
    [musicPlayer stop];
    [musicPlayer release];
    [super dealloc];
}


#pragma mark - Touch Controls

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchDistanceMoved = 0.0;
}


static CGFloat xDistanceMoved = 0.0;
static CGFloat yDistanceMoved = 0.0;


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint previous, now;
    CGFloat xDiff, yDiff;
    
    previous = [touch previousLocationInView:self.view];
    now = [touch locationInView:self.view];
    xDiff = now.x - previous.x;
    yDiff = now.y - previous.y;
    _touchDistanceMoved += fabsf(xDiff) + fabsf(yDiff);
    
    // Change in X direction?
    if ((xDistanceMoved > 0 && xDiff < 0) || (xDistanceMoved < 0 && xDiff > 0))
        xDistanceMoved = xDiff;
    else
        xDistanceMoved += xDiff;
    
    // Change in Y direction?
    if ((yDistanceMoved > 0 && yDiff < 0) || (yDistanceMoved < 0 && yDiff > 0))
        yDistanceMoved = yDiff;
    else
        yDistanceMoved += yDiff;
    
    if (fabsf(xDistanceMoved) >= kControllerMoveSensitivity) {
        if (xDistanceMoved < 0.0) {
            [tetrisGame moveTetronimo:UITetronimoActionLeft];
        } else if (xDistanceMoved > 0.0) {
            [tetrisGame moveTetronimo:UITetronimoActionRight];
        }
        
        xDistanceMoved = 0.0;
    }
    
//    if (yDistanceMoved >= kControllerMoveDownSensitivity) {
//        [tetrisGame moveTetronimo:UITetronimoActionDown];
//        
//        yDistanceMoved = 0.0;
//    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_touchDistanceMoved <= kControllerRotateSensitivity) {
        CGPoint pt = [(UITouch*)[touches anyObject] locationInView:self.view];
        if (pt.x <= self.view.bounds.size.width / 2.0) {
            [tetrisGame rotateTetronimo:UITetronimoActionLeft];
        } else {
            [tetrisGame rotateTetronimo:UITetronimoActionRight];
        }
    }
}

- (void)swipeDownGestureAction:(UISwipeGestureRecognizer *)recognizer
{
    [tetrisGame dropTetronimo];
}


#pragma mark - View Handling

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Tetris Game Delegate Methods

- (void)tetrisGameDidUpdate:(float)dt
{
    if (self.isViewLoaded)
        [(UITetrisView *) self.view redraw];
}

- (void)shouldDisplayNextTetronimo:(UITetronimo *)tetronimo
{
    if (self.isViewLoaded)
        [(UITetrisView *) self.view updateNextTetronimoDisplay:tetronimo];
}

- (void)tetrisBoardDidChange
{
    if (self.isViewLoaded)
        [(UITetrisView *) self.view setBoardIsDirty:YES];
}

- (void)shouldUpdateScore:(NSUInteger)score
{
    if (self.isViewLoaded)
        [(UITetrisView *) self.view setScore:score];
}

- (void)clearedLinesAtRows:(NSUInteger[])rows count:(NSUInteger)count
{
    if (self.isViewLoaded)
        [(UITetrisView *) self.view animateClearLinesAtRows:rows count:count];
}

- (void)gameOver
{
    NSString *message = [NSString stringWithFormat:@"Your Score: %d", tetrisGame.score];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over!" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}


#pragma mark - Alert View Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [(UITetrisView *) self.view setScore:0];
    [tetrisGame startGame];
}


@end

