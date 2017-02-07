//This class is used for UIScrollViewDelegate

#import "ScrollViewDelegateClass.h"


@interface ScrollViewDelegateClass ()
{
    UIView *_view;      //Target view
}
@end



@implementation ScrollViewDelegateClass


/*
┌────────────────────────────────────────────────────────────┐
│Instance method to init                                     │
│1. Need argument View to set target view                    │
└────────────────────────────────────────────────────────────┘
 */
- (instancetype) initWithView: (UIView *)view {

    if ( self = [ super init ]){

        _view = view;
        return self;
    }

    return nil;
}


//Class method to init
+ (instancetype) generateInstanceWithView: (UIView *)view {

    return [ [ ScrollViewDelegateClass alloc ] initWithView: view ];
}


//Target view endEditing to hide keyboard when dragging
- (void) scrollViewWillBeginDragging: (UIScrollView *)scrollView {
    [_view endEditing: true ];
}

@end
