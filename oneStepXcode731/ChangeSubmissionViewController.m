//This class is used for modify submission type plan

#import "ChangeSubmissionViewController.h"
#import "TableViewProtocolClassForSetting.h"

@interface ChangeSubmissionViewController ()
{
    NSString                         *originalPlanName;           //store original plan name
    NSMutableArray                   *submissionDictArray;        //submission dict array (submission name, checked)
    NSMutableArray                   *submissionArray;            //submission array (just submission)
    NSManagedObjectContext           *managedObjectContext;       //coredata context
    TableViewProtocolClassForSetting *tableViewProtocolInstance;  //tableview delegate & datasource
}

@property ( weak, nonatomic ) IBOutlet UITextField        *planTitleField;           //show plan name
@property ( weak, nonatomic ) IBOutlet UITableView        *submissionTableView;      //show submission array
@property ( weak, nonatomic ) IBOutlet UITextField        *addTextField;             //show new submission
@property ( weak, nonatomic ) IBOutlet UISegmentedControl *importanceSegmentControl; //set importance

@end



@implementation ChangeSubmissionViewController


/*
┌────────────────────────────────────────────────────────────┐
│View did load                                               │
│1. Save plan original name                                  │
│2. Gain submission array from this record                   │
│3. Generate tableview delegate and datasource               │
│4. Importance setting                                       │
│5. Generate coredata context                                │
└────────────────────────────────────────────────────────────┘
 */
- (void) viewDidLoad {

    [ super viewDidLoad ];

    originalPlanName            = self.planData.name;
    self.planTitleField.text    = self.planData.name;

    //Gain submission array from this record
    submissionDictArray = [ NSMutableArray arrayWithArray: self.planData.submissions ];
    submissionArray     = [ NSMutableArray new ];

    for ( int index = 0; index < submissionDictArray.count; ++index ) {

        NSDictionary *dictionary = ( NSDictionary * ) submissionDictArray[(NSUInteger) index ];
        NSString *submission     = dictionary[@"submission"];

        [ submissionArray addObject: submission ];
    }

    //Generate tableView delegate and datasource
    tableViewProtocolInstance = [TableViewProtocolClassForSetting createWithArray: submissionArray
                                                                       Identifier: @"submissionCell" ];

    self.submissionTableView.delegate       = tableViewProtocolInstance;
    self.submissionTableView.dataSource     = tableViewProtocolInstance;

    __block typeof (self) weakSelf = self;
    
    tableViewProtocolInstance.cellConfigBlock = ^(UITableViewCell *cell, NSIndexPath *indexPath){
        cell.textLabel.text = weakSelf->submissionArray[(NSUInteger) indexPath.row];
    };
    
    tableViewProtocolInstance.commitEditingBlock    = ^(NSIndexPath *indexPath){
        [ weakSelf->submissionDictArray removeObjectAtIndex:(NSUInteger) indexPath.row ];
    };

    //Importance setting
    [ self.importanceSegmentControl setSelectedSegmentIndex: self.planData.importance.integerValue ];

    //Generate coredata context
    AppDelegate *appDelegate = (AppDelegate *)[ UIApplication sharedApplication ].delegate;
    managedObjectContext     = appDelegate.managedObjectContext;
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
│1. Verify input legality                     │
│    - If has input                           │
│    - If duplicated                          │
│2. Update this data record                   │
│    - Update progress number                 │
│    - Update 'reached'                       │
│    - Update other attributes                │
│3. Save database                             │
│4. Back to main page                         │
└─────────────────────────────────────────────┘
 */
- (IBAction) saveClicked: (UIBarButtonItem *)sender {

    [ self.view endEditing: true ];

    //Verify input legality
    //1. If has input
    if ( self.planTitleField.text.length > 0 ) {

        //Name cannot be too long, like over 10 Chinese characters
        if (self.planTitleField.text.length > 10) {

            [SVProgressHUD showErrorWithStatus: @"Name too long" ];
            return;
        }

        //2. Check if duplicated
        NSFetchRequest *fetchRequest = [ NSFetchRequest fetchRequestWithEntityName: @"PlanData" ];
        NSArray *allPlanArray = [ managedObjectContext executeFetchRequest: fetchRequest error: nil ];

        for ( int index = 0; index < allPlanArray.count; ++index ) {

            PlanData *tempPlan = allPlanArray[(NSUInteger) index ];

            if ( ( tempPlan.name == self.planTitleField.text ) && ( originalPlanName != self.planTitleField.text ) ) {

                [SVProgressHUD showErrorWithStatus: @"Name already exits" ];
                return;
            }
        }

        [ self.planData setName: self.planTitleField.text ];

    } else {

        [SVProgressHUD showErrorWithStatus: @"Please input name" ];
        return;
    }

    //Update progress
    int progress = 0;

    for ( int index = 0; index < submissionDictArray.count; ++index ) {

        NSDictionary *dictionary = submissionDictArray[(NSUInteger) index ];
        NSNumber *number = [ dictionary valueForKey: @"checked" ];

        if ( number.intValue ) {
            progress++;
        }
    }

    //If plan accomplished, update 'reached'
    [ self.planData setReached: progress == submissionDictArray.count ? @1 : @0 ];

    [ self.planData setProgress: @(progress) ];
    [ self.planData setTargetNumber: @(submissionDictArray.count) ];

    [ self.planData setSubmissions: submissionDictArray ];
    [ self.planData setImportance: @(self.importanceSegmentControl.selectedSegmentIndex) ];

    //Save database
    [ managedObjectContext save: nil ];

    [ self dismissViewControllerAnimated: true completion: nil ];
}


/*
┌─────────────────────────────────────────────┐
│Action to add new submission                 │
│1. Verify input legality                     │
│2. Update tableView and plan record          │
└─────────────────────────────────────────────┘
 */
- (IBAction) addClicked: (UIButton *)sender {

    NSString *addText = self.addTextField.text;

    if ( addText.length > 0 ) {

        [ submissionArray addObject: addText ];
        [ self.submissionTableView reloadData ];

        NSDictionary *addDict = @{ @"submission": addText, @"checked": @0 };
        [ submissionDictArray addObject: addDict ];

        [ self.planData setReached: @0 ];

    } else {

        [SVProgressHUD showErrorWithStatus: @"Please input submission" ];
        return;
    }
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
