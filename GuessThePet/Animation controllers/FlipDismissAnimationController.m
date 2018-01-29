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

#import "FlipDismissAnimationController.h"
#import "AnimationHelper.h"

@implementation FlipDismissAnimationController
-(instancetype)initWithDestinationFrame: (CGRect)destinationFrame  interactionController:(SwipeInteractionController*)interactionController{
  self = [super init];
  self.destinationFrame = destinationFrame;
  self.interactionController = interactionController;
  return self;
}

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
  UIViewController* fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIViewController* toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  UIView* snapshot = [fromVC.view snapshotViewAfterScreenUpdates:NO];
  if(fromVC && toVC && snapshot ){
    
    snapshot.layer.cornerRadius = 25;
    snapshot.layer.masksToBounds = YES;
    UIView* containerView = transitionContext.containerView;

    [containerView insertSubview:toVC.view atIndex:0];
    [containerView addSubview:snapshot];
    fromVC.view.hidden = YES;
    
    [AnimationHelper perspectiveTransformContainerView: containerView];
    toVC.view.layer.transform = [AnimationHelper yRotationAngle:-(M_PI / 2)];
    CGFloat duration =[self transitionDuration: transitionContext];
    
    [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
      [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0/3 animations:^{
        snapshot.frame = self.destinationFrame;
      }];
      [UIView addKeyframeWithRelativeStartTime:1.0/3 relativeDuration:1.0/3 animations:^{
        snapshot.layer.transform = [AnimationHelper yRotationAngle:M_PI/2];
      }];
      [UIView addKeyframeWithRelativeStartTime:2.0/3 relativeDuration:1.0/3 animations:^{
        toVC.view.layer.transform= [AnimationHelper yRotationAngle:0.0];
      }];
      
    } completion:^(BOOL finished) {
      fromVC.view.hidden = NO;
      [snapshot removeFromSuperview];
      if(transitionContext.transitionWasCancelled){
        [toVC.view removeFromSuperview];
      }
      [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
  }
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
  return 0.6;
}

@end

