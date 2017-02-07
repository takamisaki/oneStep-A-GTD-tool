//This class is used for daily check the Plan of Submission Type

#import "SubmissionCheckViewController.h"
#import "SubmissionTableViewCell.h"

@interface SubmissionCheckViewController () < UITableViewDelegate, UITableViewDataSource >
{
    NSMutableArray *submissionDictArray;  //array stores all submission (NSDictionary *)
    float checkedCount;                   //checked number
}
@property ( weak, nonatomic ) IBOutlet UITableView *submissionListTableView; //tableView show submission list
@property ( weak, nonatomic ) IBOutlet UILabel     *progressLabel;           //label show progress
@property ( weak, nonatomic ) IBOutlet UILabel     *reachedLabel;            //label show congrats if plan accomplished
@end



@implementation SubmissionCheckViewController


/*
┌────────────────────────────────────────────────┐
│View did load                                   │
│1. If plan accomplished, show 'Congrats' view   │
│2. Assign values                                │
│3. Config views                                 │
└────────────────────────────────────────────────┘
 */
- (void) viewDidLoad {
    [ super viewDidLoad ];

    //If plan accomplished, show congrats view
    if ( self.planData.reached.intValue ) {
        [ self.reachedLabel  setHidden: false ];
        [ self.progressLabel setHidden: true ];
    }

    //Assign values
    checkedCount        = self.planData.progress.floatValue;
    submissionDictArray = [ NSMutableArray arrayWithArray: self.planData.submissions ];

    //Config views
    float progressRate                      = checkedCount/submissionDictArray.count;
    self.progressLabel.text                 = [NSString stringWithFormat: @"已完成 %.1f %%", progressRate * 100 ];
    self.submissionListTableView.delegate   = self;
    self.submissionListTableView.dataSource = self;
}


//Set rows number in section
- (NSInteger) tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)section {
    return submissionDictArray.count;
}


/*
┌────────────────────────────────────────────────┐
│Config Cell                                     │
│1. Assign cell label                            │
│2. Config cell check button action              │
│3. Assign data record                           │
│3. Invoke UI refresh method                     │
└────────────────────────────────────────────────┘
 */
- (UITableViewCell *) tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {

    SubmissionTableViewCell *cell = [ tableView dequeueReusableCellWithIdentifier: @"submissionCell" ];

    //Config cell content
    __block NSDictionary *dictionary = submissionDictArray[(NSUInteger) indexPath.row ];
    cell.submissionName.text         = dictionary[@"submission"];

    __block NSNumber *checkedNumber = dictionary[@"checked"];
    [ cell.isChecked setOn: checkedNumber.intValue ? true : false ];

    //Config cell's check action
    __weak typeof ( self ) weakSelf = self;

    cell.checkBlock = ^( ) {

        NSNumber *valueNumber = checkedNumber.intValue ? @0 : @1;

        valueNumber.intValue ? ( checkedCount++ ) : ( checkedCount-- );

        [ self.planData setProgress: @(checkedCount) ];

        weakSelf.progressLabel.text = [ NSString stringWithFormat:
                                        @"已完成 %.1f %%", checkedCount / submissionDictArray.count * 100 ];

        dictionary = @{ @"submission": dictionary[@"submission"],
                        @"checked"   : valueNumber };

        submissionDictArray[(NSUInteger) indexPath.row ] = dictionary;

        [ weakSelf.planData setSubmissions: submissionDictArray ];

        [ weakSelf refreshData ];
    };

    return cell;
}


/*
┌────────────────────────────────────────────────┐
│Refresh UI                                      │
│1. If plan accomplished, show congrats view     │
│2. Reload submission tableView                  │
└────────────────────────────────────────────────┘
 */
- (void) refreshData {

    if ( checkedCount == submissionDictArray.count ) {

        [ self.reachedLabel  setHidden: false ];
        [ self.progressLabel setHidden: true  ];
        [ self.planData setReached: @1 ];

    } else {
        [ self.reachedLabel  setHidden: true  ];
        [ self.progressLabel setHidden: false ];
        [ self.planData setReached: @0 ];
    }

    [ self.submissionListTableView reloadData ];
}

@end
