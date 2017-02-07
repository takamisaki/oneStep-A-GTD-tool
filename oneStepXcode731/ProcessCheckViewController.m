//This class is used for daily check the Plan of Process Type

#import "ProcessCheckViewController.h"

@interface ProcessCheckViewController ()
{
    float progressValue;                            //progress number
    float targetNumberValue;                        //target number
    float processRadio;                             //progress rate
}
@property ( weak, nonatomic ) IBOutlet UILabel      *repeatedMissionLabel;   //show repeated mission
@property ( weak, nonatomic ) IBOutlet UILabel      *totalMissionLabel;      //show target mission
@property ( weak, nonatomic ) IBOutlet UILabel      *processLabel;           //show current progress text
@property ( weak, nonatomic ) IBOutlet UIButton     *checkButton;            //daily check button
@property ( weak, nonatomic ) IBOutlet UIView       *reachedView;            //if plan accomplished, show this view
@property (weak, nonatomic) IBOutlet UIProgressView *processView;            //show process

@end


@implementation ProcessCheckViewController


/*
┌────────────────────────────────────────────────────┐
│View did load                                       │
│1. If plan accomplished, show 'congrats' view       │
│2. Assign properties' value                         │
│3. Config view's content                            │
└────────────────────────────────────────────────────┘
 */
- (void) viewDidLoad {
    [ super viewDidLoad ];

    //If plan accomplished, show this view
    if ( self.planData.reached.intValue == 1 ) {
        [ self.reachedView setHidden: false ];
    }

    //Assign values
    progressValue     = self.planData.progress.floatValue;
    targetNumberValue = self.planData.targetNumber.floatValue;

    processRadio = progressValue / targetNumberValue;
    self.processView.transform = CGAffineTransformScale(self.processView.transform, 1, 10);
    [ self updateProceessView:processRadio];
    
    //Config text to show
    self.repeatedMissionLabel.text = self.planData.repeatedMission;
    self.totalMissionLabel.text    = [ NSString stringWithFormat: @"%.1f %@", targetNumberValue, self.planData.targetUnit ];
}


/*
┌────────────────────────────────────────────────────┐
│Update process view                                 │
│1. Update progress label                            │
│2. Update processView value                         │
└────────────────────────────────────────────────────┘
 */
- (void) updateProceessView: (float)value {
    
    self.processLabel.text = [ NSString stringWithFormat: @"已完成 %.1f %%", self->processRadio * 100 ];
    [ self.processView setProgress:processRadio animated:true];
}

/*
┌──────────────────────────────────────────────────────────────────────────────┐
│Check button action                                                           │
│1. Verify progress value legality, if plan accomplished, show 'Congrats' view │
│2. Update slider and progress label                                           │
└──────────────────────────────────────────────────────────────────────────────┘
 */
- (IBAction)checkClicked: (UIButton *)sender {

    processRadio  += 1 / targetNumberValue;
    progressValue += 1.0;

    if ( processRadio >= 0.999 ) {
        processRadio  = 1.0;
        progressValue = self.planData.targetNumber.floatValue;
        [ self.reachedView setHidden: false ];
        [ self.planData setReached: @1 ];
    }

    [ self updateProceessView: processRadio];
    [ self.planData setProgress: @(progressValue) ];
}

@end
