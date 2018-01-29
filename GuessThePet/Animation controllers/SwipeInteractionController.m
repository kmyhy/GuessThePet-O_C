///// Copyright (c) 2017 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

#import "SwipeInteractionController.h"

@interface SwipeInteractionController()

@property(assign,nonatomic)BOOL shouldCompleteTransition;
@property(weak,nonatomic)UIViewController* viewController;
@end

@implementation SwipeInteractionController

-(instancetype)initWithViewController: (UIViewController*)viewController {
  self = [super init];
  self.viewController = viewController;
  [self prepareGestureRecognizerInView:viewController.view];
  return self;
}
-(void)prepareGestureRecognizerInView: (UIView*)view {
  UIScreenEdgePanGestureRecognizer* gesture = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
  gesture.edges = UIRectEdgeLeft;
  [view addGestureRecognizer:gesture];
}

-(void)handleGesture: (UIScreenEdgePanGestureRecognizer*)gestureRecognizer {
  // 1
  CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view.superview];
  
  CGFloat progress = (translation.x / 200);
  
  progress = (CGFloat)(fminf(fmaxf(progress, 0.0), 1.0));
  
  switch(gestureRecognizer.state){
    case UIGestureRecognizerStateBegan:
      self.interactionInProgress = YES;
      [_viewController dismissViewControllerAnimated:YES completion:nil];
      break;
    case UIGestureRecognizerStateChanged:
      self.shouldCompleteTransition = progress > 0.5;
      [self updateInteractiveTransition:progress];
      break;
    case UIGestureRecognizerStateCancelled:
      self.interactionInProgress = NO;
      [self cancelInteractiveTransition];
      break;
    case UIGestureRecognizerStateEnded:
      self.interactionInProgress = NO;
      if( self.shouldCompleteTransition ){
        [self finishInteractiveTransition];
      } else {
        [self cancelInteractiveTransition];
      }
      break;
    default:
      break;
  }
}
@end






