//This class is used as Parent class of processCheckViewController and SubmissionCheckViewController.

#import "CheckViewController.h"

@interface CheckViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;        //Navi bar

@end



@implementation CheckViewController


/*
┌─────────────────────────────────────────────┐
│View did load                                │
│1. Config Navi title equals record's name    │
└─────────────────────────────────────────────┘
 */
- (void) viewDidLoad {
    [ super viewDidLoad ];

    self.navigationBar.topItem.title = self.planData.name;

    AppDelegate *appDelegate = (AppDelegate *)[ UIApplication sharedApplication ].delegate;
    managedObjectContext     = appDelegate.managedObjectContext;
}


/*
┌─────────────────────────────────────────────┐
│Cancel button                                │
│1. Rollback database modification            │
│2. Back to main ViewController               │
└─────────────────────────────────────────────┘
 */
- (IBAction)cancelClicked: (UIBarButtonItem *)sender {

    [managedObjectContext rollback ];
    [ self dismissViewControllerAnimated: YES completion: nil ];
}


/*
┌─────────────────────────────────────────────┐
│Save button                                  │
│1. Save database modification                │
│2. Back to main ViewController               │
└─────────────────────────────────────────────┘
 */
- (IBAction)saveClicked: (UIBarButtonItem *)sender {

    [ managedObjectContext save: nil ];
    [ self dismissViewControllerAnimated: YES completion: nil ];
}


- (void) didReceiveMemoryWarning {
    [ super didReceiveMemoryWarning ];
}

@end
