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

#import "FlipPresentAnimationController.h"
#import "GuessThePet-Swift.h"
#import "AnimationHelper.h"

@class CardViewController;
@interface FlipPresentAnimationController()<UIViewControllerAnimatedTransitioning>
@property(assign,nonatomic)CGRect originFrame;
@end
@implementation FlipPresentAnimationController

-(instancetype)initWithOriginFrame: (CGRect)originFrame {
  self = [super init];
  self.originFrame = originFrame;
  return self;
}

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
  UIViewController* fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIViewController* toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  
  UIView* snapshot = [toVC.view snapshotViewAfterScreenUpdates:YES];// toVC.view 是不可见view，因此 afterScreenUpdates 参数需要设置为 yes

  // snapshot 为 nil 时会 crash
  if(fromVC && toVC && snapshot){
    UIView* containerView = transitionContext.containerView;
    CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
    snapshot.frame= _originFrame;
    snapshot.layer.cornerRadius = 25 ;
    snapshot.layer.masksToBounds =  true;
    
    [containerView addSubview:toVC.view];
    [containerView addSubview:snapshot];
    
    toVC.view.hidden = YES;

    [AnimationHelper perspectiveTransformContainerView:containerView];
    // 将截图的 y 轴旋转 90°，这会导致它以侧向的姿态面对观察者，也就是在动画的一开始它不可见
    snapshot.layer.transform = [AnimationHelper yRotationAngle:M_PI/2];
    CGFloat duration = [self transitionDuration:transitionContext];

    [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
      // 一开始沿 y 轴旋转 from 视图 90°，隐藏它
      [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0/3 animations:^{
        fromVC.view.layer.transform = [AnimationHelper yRotationAngle: 0 - M_PI/2];
      }];
      // 显示截图，将它从侧向 90º 状态旋转回 0º
      [UIView addKeyframeWithRelativeStartTime:1.0/3 relativeDuration:1.0/3 animations:^{
        snapshot.layer.transform = [AnimationHelper yRotationAngle:0];
      }];
      // 设置截图的框架大小已填充全屏。
      [UIView addKeyframeWithRelativeStartTime:2.0/3 relativeDuration:1.0/3 animations:^{
        snapshot.frame = finalFrame;
        snapshot.layer.cornerRadius = 0;
      }];
      
    } completion:^(BOOL finished) {
      // 截图现在已经完全和 to 视图一致了，因此可以安全第显示真正的 to 视图了。从视图树中删除截图，因为它不再需要。然后将 from 视图恢复原有状态；否则当转换动画结束它会被隐藏。调用 completeTransition(_:) 告诉 UIKit 动画已经完成。这将确保最终状态是一致的并从容器视图中移除 from 视图。
      toVC.view.hidden = NO;
      [snapshot removeFromSuperview];
      fromVC.view.layer.transform = CATransform3DIdentity;
      [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
  }
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
  return 0.6;
}
@end
