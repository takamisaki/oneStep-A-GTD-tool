//This class is used for main page's cell

#import "PlanCell.h"


@implementation PlanCell


//Add longPressGestureRecognizer
- (void) awakeFromNib {

    [ super awakeFromNib ];
    
    [ self addGestureRecognizer: [ [ UILongPressGestureRecognizer alloc ] initWithTarget: self
                                                                                  action: @selector (longPressed:) ]];

    self.processLabel.hidden     = NO;
    self.reachedImageView.hidden = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


/*
┌────────────────────────────────────────────────────────────────────┐
│LongPress Action                                                    │
│1. Make pressed cell first responder                                │
│2. Generate MenuController containing 2 buttons                     │
│3. Config MenuController and show                                   │
└────────────────────────────────────────────────────────────────────┘
 */
- (void) longPressed: (UILongPressGestureRecognizer *)longPressGestureRecognizer {

    if ( longPressGestureRecognizer.state == UIGestureRecognizerStateBegan ) {

        [ self becomeFirstResponder ];

        UIMenuController *cellMenuController = [ UIMenuController sharedMenuController ];
        UIMenuItem *changeTagItem  = [ [ UIMenuItem alloc ] initWithTitle: @"修改标签"
                                                                   action: @selector ( changeTagItemClicked ) ];
        UIMenuItem *changePlanItem = [ [ UIMenuItem alloc ] initWithTitle: @"修改规划"
                                                                   action: @selector ( changePlanItemClicked ) ];

        [ cellMenuController setMenuItems  : @[ changeTagItem, changePlanItem ] ];
        [ cellMenuController setTargetRect : self.bounds inView: self ];
        [ cellMenuController setMenuVisible: YES animated: YES ];
    }
}


/*
┌────────────────────────────────────────────────────────────────────┐
│Config when this class can perform action                           │
│1. Verify action with 2 actions                                     │
└────────────────────────────────────────────────────────────────────┘
 */
- (BOOL) canPerformAction: (SEL)action withSender: (id)sender {

    if (action == @selector ( changeTagItemClicked)  || action == @selector ( changePlanItemClicked)) {
        return true;
    }

    return [ super canPerformAction: action withSender: sender ];
}


//Ensure this class instance can be firstResponder
- (BOOL) canBecomeFirstResponder {
    return true;
}


//Invoke tag modify method
- (void) changeTagItemClicked {

    if ( self.changeTagClickedBlock ) {
        self.changeTagClickedBlock ( );
    }
}


//Invoke plan modify method
- (void) changePlanItemClicked {

    if ( self.changePlanClickedBlock ) {
        self.changePlanClickedBlock ( );
    }
}


//Default method
- (void) setSelected: (BOOL)selected animated: (BOOL)animated {
    [ super setSelected: selected animated: animated ];
}

@end
