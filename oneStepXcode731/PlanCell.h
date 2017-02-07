//This class is used for main page's cell

typedef void(^TagBlock)  ( );  //block for menu button - modify tag
typedef void(^PlanBlock) ( );  //block for menu button - modify plan

@interface PlanCell : UITableViewCell

@property ( weak, nonatomic ) IBOutlet UILabel *nameLabel;      //Label shows plan name
@property ( weak, nonatomic ) IBOutlet UILabel *processLabel;   //Label shows process number
@property ( weak, nonatomic ) IBOutlet UILabel *tag0Label;      //3 Labels show tag array
@property ( weak, nonatomic ) IBOutlet UILabel *tag1Label;
@property ( weak, nonatomic ) IBOutlet UILabel *tag2Label;
@property ( weak, nonatomic ) IBOutlet UIImageView *reachedImageView; //show if plan accomplished

@property ( copy, nonatomic ) TagBlock  changeTagClickedBlock;  //modify tag clicked action
@property ( copy, nonatomic ) PlanBlock changePlanClickedBlock; //modify plan clicked action

@end
