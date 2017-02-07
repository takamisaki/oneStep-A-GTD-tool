//This Class is used for adding new plan

#import "PlanConfigureViewController.h"
#import "TableViewProtocolClassForSetting.h"
#import "ScrollViewDelegateClass.h"

@interface PlanConfigureViewController () <UIScrollViewDelegate>
{
    PlanData                         *planData;                     //new data injected
    NSManagedObjectContext           *managedObjectContext;         //context
    NSMutableArray<NSString *>       *submissionArray;              //submissionArray (Submission plan type only)
    TableViewProtocolClassForSetting *tableViewProtocolInstance;    //tableViewDelegate & Datasource instance
    ScrollViewDelegateClass          *scrollViewDelegateInstance;   //UIScrollViewDelegate instance
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;                //navi cancel button
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;                  //navi save button

@property (weak, nonatomic) IBOutlet UIScrollView *planConfigureScroller;          //scrollView background
@property (weak, nonatomic) IBOutlet UIView       *processExampleView;             //process type example
@property (weak, nonatomic) IBOutlet UIView       *processPlanConfigureView;       //process plan config view
@property (weak, nonatomic) IBOutlet UIView       *submissionExampleView;          //submission type example
@property (weak, nonatomic) IBOutlet UIView       *submissionPlanConfigureView;    //submission plan config view
@property (weak, nonatomic) IBOutlet UIView       *importanceSettingView;          //importance setting

@property (weak, nonatomic) IBOutlet UITextField  *planTitleTextField;             //plan name
@property (weak, nonatomic) IBOutlet UITextField  *repeatedMissionField;           //repeated mission(process type only)
@property (weak, nonatomic) IBOutlet UITextField  *targetNumberField;              //target number(int only)
@property (weak, nonatomic) IBOutlet UITextField  *targetUnitField;                //target unit(such as: days, times)

@property (weak, nonatomic) IBOutlet UITableView  *submissionTableView;            //tableView show submissionArray
@property (weak, nonatomic) IBOutlet UITextField  *submissionField;                //input submission
@property (weak, nonatomic) IBOutlet UIButton     *submissionAddButton;            //add button for new submission

@property (weak, nonatomic) IBOutlet UISegmentedControl *planTypeSegmentControl;   //choose plan type
@property (weak, nonatomic) IBOutlet UISegmentedControl *importanceSegmentControl; //choose importance

@end



@implementation PlanConfigureViewController


#pragma mark -
#pragma mark viewController lifeCycle


/*
┌─────────────────────────────────────────────────────────────────────────┐
│View did load                                                            │
│1. Insert new data record into database                                  │
│2. Config delegate & datasource for tableView (submission type only)     │
│3. Set action of changing plan type                                      │
└─────────────────────────────────────────────────────────────────────────┘
 */
- (void) viewDidLoad {
    [super viewDidLoad];

    //Insert new data record into database
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    managedObjectContext     = appDelegate.managedObjectContext;

    planData = [NSEntityDescription insertNewObjectForEntityForName: @"PlanData"
                                             inManagedObjectContext: managedObjectContext];

    submissionArray                     = [NSMutableArray new];

    //Config delegate & datasource for tableView
    tableViewProtocolInstance           = [TableViewProtocolClassForSetting createWithArray: submissionArray
                                                                                 Identifier: @"submissionCell"];
    self.submissionTableView.delegate   = tableViewProtocolInstance;
    self.submissionTableView.dataSource = tableViewProtocolInstance;
    
    __block typeof(self) weakSelf = self;
    tableViewProtocolInstance.cellConfigBlock = ^(UITableViewCell *cell, NSIndexPath *indexPath){
        cell.textLabel.text = weakSelf->submissionArray[(NSUInteger) indexPath.row];
    };

    //Set action of changing plan type
    [self.planTypeSegmentControl addTarget: self
                                    action: @selector(planTypeSegmentControlClicked)
                          forControlEvents: UIControlEventValueChanged];

    //Config delegate for scroller ( keyboard will disappear when dragging )
    scrollViewDelegateInstance = [ ScrollViewDelegateClass generateInstanceWithView: self.view ];
    self.planConfigureScroller.delegate = scrollViewDelegateInstance;

}


/*
┌─────────────────────────────────────────────┐
│View will appear                             │
│1. Config background view - a scrollView     │
└─────────────────────────────────────────────┘
 */
- (void) viewDidAppear: (BOOL) animated {
    [super viewDidAppear: animated];

    //Config background view - a scrollView
    [self.planConfigureScroller setScrollEnabled: true];
    [self.planConfigureScroller setShowsVerticalScrollIndicator: false];
    [self.planConfigureScroller setContentSize: CGSizeMake(0, SCREEN_HEIGHT * 1.6)];
}


#pragma mark -
#pragma mark Navi Button


/*
┌──────────────────────────────────────────┐
│Cancel Button                             │
│1. Cancel new data injected               │
│2. Disappear the keyboard                 │
│3. Back to main viewController            │
└──────────────────────────────────────────┘
 */

- (IBAction) cancelClickedHandler: (UIBarButtonItem *) sender {

    [managedObjectContext rollback];

    [self.view endEditing: true ];

    [self dismissViewControllerAnimated: YES completion: nil];
}


/*
┌───────────────────────────────────────────────────┐
│Save Button                                        │
│1. Text input legality check                       │
│2. Assign values to new Data                       │
│3. Save Database                                   │
│4. Back to main viewController                     │
└───────────────────────────────────────────────────┘
  */
- (IBAction) saveClickedHandler: (UIBarButtonItem *) sender {

    [self.view endEditing: true ];

    //If plan title input is nil
    if (self.planTitleTextField.text.length == 0) {

        [SVProgressHUD showErrorWithStatus: @"Need Title" ];
        return;
    }

    //Name cannot be too long, like over 10 Chinese characters
    if (self.planTitleTextField.text.length > 10) {

        [SVProgressHUD showErrorWithStatus: @"Name too long" ];
        return;
    }

    //If plan name is duplicated
    if ([self isDuplicated]) {

        [SVProgressHUD showErrorWithStatus: @"Title already exits" ];
        return;
    }

    //If text input is nil (process type only)
    if (self.planTypeSegmentControl.selectedSegmentIndex == 0) {

        if (![self scanSubviews:self.processPlanConfigureView]) {

            [SVProgressHUD showErrorWithStatus: @"Need complete all" ];
            return;
        }
    }

    //Assign values to new Data
    NSNumber *planType = @(self.planTypeSegmentControl.selectedSegmentIndex);

    NSMutableArray *submissionDictArray = [NSMutableArray new];

    switch (planType.intValue) {
        case 0:
            if (![self isInt: self.targetNumberField.text]) {

                [SVProgressHUD showErrorWithStatus: @"Wrong Int target number" ];
                return;
            }

            [planData setTargetNumber:    @(self.targetNumberField.text.integerValue)];
            [planData setRepeatedMission: self.repeatedMissionField.text];
            [planData setTargetUnit:      self.targetUnitField.text];
            [planData setSubmissions:     nil];
            break;
        
        case 1:
            if (submissionArray.count == 0){

                [SVProgressHUD showErrorWithStatus: @"Please add submission" ];
                return;
            }

            for (int index = 0; index < submissionArray.count; index ++) {

                NSDictionary *submissionDict = @{ @"submission": submissionArray[ (NSUInteger) index],
                                                  @"checked"   : @0};
                [submissionDictArray addObject: submissionDict];
            }

            [planData setTargetUnit:      nil];
            [planData setRepeatedMission: nil];
            [planData setSubmissions:     submissionDictArray];
            [planData setTargetNumber:    @(submissionDictArray.count)];
            break;

        default:
            break;
    }

    NSNumber *importance = @(self.importanceSegmentControl.selectedSegmentIndex);

    [planData setReached:    @0];
    [planData setProgress:   @0];
    [planData setTags:       nil];
    [planData setType:       planType];
    [planData setImportance: importance];
    [planData setName:       self.planTitleTextField.text];

    //save new data & back to main VC
    [managedObjectContext save: nil];
    
    [self dismissViewControllerAnimated: YES completion: nil];
}


/*
┌──────────────────────────────────────────────────────┐
│Check subview input legality                          │
│1. Scan every subview                                 │
│2. If subview is a Textfield, check input legality    │
│3. If nothing input, return false. Or return true     │
└──────────────────────────────────────────────────────┘
 */
- (BOOL) scanSubviews: (UIView *) view {

    for (UIView *subview in view.subviews) {

        if ([subview isKindOfClass: [UITextField class]]) {

            UITextField *textField = (UITextField *)subview;

            if (textField.text.length == 0) {
                return false;
            }
        }
    }
    return true;
}


/*
┌──────────────────────────────────────────────────────┐
│Check if plan name duplicated                         │
│1. Get planData Array from Database                   │
│2. Traverse every single planData                     │
│3. If name duplicated, return true. Or return false   │
└──────────────────────────────────────────────────────┘
 */
- (BOOL) isDuplicated {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PlanData"];
    NSArray *allPlanArray = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    for (int index = 0; index < allPlanArray.count; ++index) {

        PlanData *tempPlan = allPlanArray[(NSUInteger) index];

        if (tempPlan.name == self.planTitleTextField.text){
            return true;
        }
    }
    return false;
}


/*
┌───────────────────────────────────────────────────────────┐
│Check if input is int                                      │
│1. Generate NSScanner instance with String                 │
│2. Return (if Integer) && (if Exhausted all characters)    │
└───────────────────────────────────────────────────────────┘
 */
- (BOOL) isInt: (NSString *)string {
    NSScanner *scanner = [NSScanner scannerWithString:string];
    int val1;
    return [scanner scanInt:&val1] && [scanner isAtEnd];
}


#pragma mark -
#pragma mark Other

/*
┌────────────────────────────────────────────────────────────────────────────────────────┐
│Switch Hidden of Example Views                                                          │
│1. If ProcessPlan type, show process example and process configure view only            │
│2. If SubmissionPlan type, show submission example and submission configure view only   │
└────────────────────────────────────────────────────────────────────────────────────────┘
 */
- (void) planTypeSegmentControlClicked {
    
    self.processExampleView.hidden          = !self.processExampleView.hidden;
    self.submissionExampleView.hidden       = !self.submissionExampleView.hidden;
    self.processPlanConfigureView.hidden    = !self.processPlanConfigureView.hidden;
    self.submissionPlanConfigureView.hidden = !self.submissionPlanConfigureView.hidden;
}


/*
┌──────────────────────────────────────────────┐
│Add Submission Button                         │
│1. Check submission input legality            │
│2. Add new submission into submissionArray    │
│3. Reload submission tableView                │
└──────────────────────────────────────────────┘
 */
- (IBAction) submissionAddButtonClicked: (UIButton *)sender {

    if (self.submissionField.text.length == 0) {

        [SVProgressHUD showErrorWithStatus: @"Please input submission" ];
        return;
    }
    [submissionArray addObject: self.submissionField.text];

    [self.submissionTableView reloadData];
}


@end
