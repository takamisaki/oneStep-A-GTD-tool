//This class is used for modify plan's tag

#import "ChangeTagViewController.h"
#import "TableViewProtocolClassForSetting.h"

@interface ChangeTagViewController ()
{
    NSManagedObjectContext           *managedObjectContext;
    NSMutableArray                   *tagArray;
    TableViewProtocolClassForSetting *tableViewProtocolInstance;    //tableViewDelegate & Datasource instance
}
@property ( weak, nonatomic ) IBOutlet UITableView *tagTableView;
@property ( weak, nonatomic ) IBOutlet UITextField *tagTextField;
@end


@implementation ChangeTagViewController

- (void) viewDidLoad {

    [ super viewDidLoad ];

    tagArray = [ NSMutableArray arrayWithArray: ( NSArray * ) self.planData.tags ];

    //Config delegate & datasource for tableView
    tableViewProtocolInstance           = [TableViewProtocolClassForSetting createWithArray: tagArray
                                                                                 Identifier: @"tagCell"];
    self.tagTableView.delegate   = tableViewProtocolInstance;
    self.tagTableView.dataSource = tableViewProtocolInstance;

    __block typeof(self) weakSelf = self;
    tableViewProtocolInstance.cellConfigBlock = ^(UITableViewCell *cell, NSIndexPath *indexPath){
        cell.textLabel.text = weakSelf->tagArray[(NSUInteger) indexPath.row];
    };

    AppDelegate *appDelegate = ( AppDelegate * ) [ UIApplication sharedApplication ].delegate;
    managedObjectContext     = appDelegate.managedObjectContext;
}


- (IBAction)addClicked: (UIButton *)sender {

    if ( tagArray.count >= 3 ) {

        [SVProgressHUD showInfoWithStatus: @"Max count is 3" ];
        return;
    }
    if ( self.tagTextField.text.length != 0 ) {
        if ( self.tagTextField.text.length >= 6 ) {

            [SVProgressHUD showErrorWithStatus: @"Tag too long" ];
            return;
        }
        [ tagArray addObject: self.tagTextField.text ];
        [ self.tagTableView reloadData ];

    } else {

        [SVProgressHUD showErrorWithStatus: @"Please input tag" ];
        return;
    }
}


- (IBAction)cancelClicked: (UIBarButtonItem *)sender {

    [ managedObjectContext undo ];

    [ self.view endEditing: true ];

    [ self dismissViewControllerAnimated: true completion: nil ];
}


- (IBAction)saveClicked: (UIBarButtonItem *)sender {

    [self.view endEditing: true ];

    [ self.planData setValue: tagArray forKey: @"tags" ];

    [ managedObjectContext save: nil ];

    [ self dismissViewControllerAnimated: true completion: nil ];
}


- (void) didReceiveMemoryWarning {

    [ super didReceiveMemoryWarning ];
}

@end
