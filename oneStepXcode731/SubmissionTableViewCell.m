//This class is used for cell of submission check view

#import "SubmissionTableViewCell.h"

@implementation SubmissionTableViewCell


//Add action to cell's check button
- (void) awakeFromNib {
    [ super awakeFromNib ];

    [ self.isChecked addTarget: self action: @selector (clickedHandler) forControlEvents: UIControlEventValueChanged];
}


//Invoke block if assigned
- (void) clickedHandler {
    if ( self.checkBlock ) {
         self.checkBlock ( );
    }
}


//Default method
- (void) setSelected: (BOOL)selected animated: (BOOL)animated {
    [ super setSelected: selected animated: animated ];
}

@end
