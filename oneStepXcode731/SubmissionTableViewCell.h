//This class is used for cell of submission check view

typedef void(^clickBlock)();

@interface SubmissionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel  *submissionName;  //Label show submission name
@property (weak, nonatomic) IBOutlet UISwitch *isChecked;       //Show isChecked?
@property (copy, nonatomic) clickBlock checkBlock;              //Cell's button action

@end
