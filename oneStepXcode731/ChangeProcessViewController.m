//This class is used for modify process type plan

#import "ChangeProcessViewController.h"

@interface ChangeProcessViewController ()
{
    int progressValue;                               //progress number
    NSString *orginalPlanName;                       //old plan name
    NSManagedObjectContext *managedObjectContext;    //coredata context
}

@property ( weak, nonatomic ) IBOutlet UITextField *planTitleField;                   //show plan name
@property ( weak, nonatomic ) IBOutlet UITextField *repeatedMissionField;             //show repeated mission
@property ( weak, nonatomic ) IBOutlet UITextField *targetNumberField;                //show target number
@property ( weak, nonatomic ) IBOutlet UITextField *targetUnitField;                  //show target unit
@property ( weak, nonatomic ) IBOutlet UISegmentedControl *importanceSegmentControl;  //set plan importance

@end



@implementation ChangeProcessViewController


/*
┌─────────────────────────────────────────────┐
│View did load                                │
│1. Config UI and assign values               │
│2. Get coredata context                      │
└─────────────────────────────────────────────┘
 */
- (void) viewDidLoad {

    [ super viewDidLoad ];

    //Config UI, Assign values
    self.planTitleField.text        = self.planData.name;
    self.repeatedMissionField.text  = self.planData.repeatedMission;
    self.targetNumberField.text     = [ NSString stringWithFormat: @"%@", self.planData.targetNumber ];
    self.targetUnitField.text       = self.planData.targetUnit;
    progressValue                   = self.planData.progress.intValue;
    orginalPlanName                 = self.planData.name;
    [ self.importanceSegmentControl setSelectedSegmentIndex: self.planData.importance.integerValue ];

    //coredata context
    AppDelegate *appDelegate        = (AppDelegate *)[ UIApplication sharedApplication ].delegate;
    managedObjectContext            = appDelegate.managedObjectContext;
}


/*
┌─────────────────────────────────────────────┐
│Cancel button                                │
│1. Undo database modification                │
│2. Back to main ViewController               │
└─────────────────────────────────────────────┘
 */
- (IBAction) cancelClicked: (UIBarButtonItem *)sender {

    [ managedObjectContext undo ];
    [ self.view endEditing: true ];
    [ self dismissViewControllerAnimated: true completion: nil ];
}


/*
┌─────────────────────────────────────────────┐
│Save action                                  │
│1. If legal input                            │
│2. If targetNumber is Int                    │
│3. If plan name duplicated                   │
│4. Assign value                              │
│5. Context save                              │
│6. Back to main page                         │
└─────────────────────────────────────────────┘
 */
- (IBAction) saveClicked: (UIBarButtonItem *)sender {

    [ self.view endEditing: true ];

    //If legal input
    for ( UIView *subview in self.view.subviews ) {
        if ( [ subview isKindOfClass: [ UITextField class ] ] ) {
            UITextField *textField = ( UITextField * ) subview;
            if ( textField.text.length == 0 ) {

                [SVProgressHUD showErrorWithStatus: @"Please complete the content" ];
                return;
            }
        }
    }

    //Name cannot be too long, like over 10 Chinese characters
    if (self.planTitleField.text.length > 10) {

        [SVProgressHUD showErrorWithStatus: @"Name too long" ];
        return;
    }

    //If targetNumber is Int
    if ( [ self isInt: self.targetNumberField.text ] ) {
        int newTargetNumber = self.targetNumberField.text.intValue;
        if ( newTargetNumber < progressValue ) {

            [SVProgressHUD showErrorWithStatus: @"Cannot be smaller than progress" ];
            return;
        }

        [ self.planData setTargetNumber: @(self.targetNumberField.text.integerValue) ];
        [ self.planData setReached: ( newTargetNumber == progressValue ) ? @1 : @0 ];

    } else {

        [SVProgressHUD showErrorWithStatus: @"Wrong Number" ];
        return;
    }

    //If plan name duplicated
    NSFetchRequest *fetchRequest = [ NSFetchRequest fetchRequestWithEntityName: @"PlanData" ];
    NSArray *allPlanArray = [ managedObjectContext executeFetchRequest: fetchRequest error: nil ];

    for ( int index = 0; index < allPlanArray.count; ++index ) {
        PlanData *tempPlan = allPlanArray[(NSUInteger) index ];

        if ( ( tempPlan.name == self.planTitleField.text ) && ( orginalPlanName != self.planTitleField.text ) ) {

            [SVProgressHUD showErrorWithStatus: @"Name already exits" ];
            return;
        }
    }

    //Assign value
    [ self.planData setName:            self.planTitleField.text ];
    [ self.planData setRepeatedMission: self.repeatedMissionField.text ];
    [ self.planData setImportance:      @(self.importanceSegmentControl.selectedSegmentIndex) ];
    [ self.planData setTargetUnit:      self.targetUnitField.text ];

    //Context save
    [ managedObjectContext save: nil ];

    //Back to main page
    [ self dismissViewControllerAnimated: true completion: nil ];
}


/*
┌─────────────────────────────────────────────┐
│If input is Int                              │
│1. Generate scanner with input string        │
│2. Scan and return BOOL                      │
└─────────────────────────────────────────────┘
 */
- (BOOL) isInt: (NSString *)string {

    NSScanner *scanner = [ NSScanner scannerWithString: string ];
    int val1;
    return [ scanner scanInt: &val1 ] && [ scanner isAtEnd ];
}


//Keyboard will disappear when touch
- (void) touchesBegan: (NSSet<UITouch *> *)touches withEvent: (UIEvent *)event {

    [ self.view endEditing: true ];
}


//Default method
- (void) didReceiveMemoryWarning {

    [ super didReceiveMemoryWarning ];
}

@end
