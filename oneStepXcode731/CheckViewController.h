//This class is used as Parent class of processCheckViewController and SubmissionCheckViewController.

@interface CheckViewController : UIViewController
{
    NSManagedObjectContext *managedObjectContext;       //Coredata Context
}
@property (nonatomic, strong) PlanData *planData;       //Accept a data record from outside

@end
