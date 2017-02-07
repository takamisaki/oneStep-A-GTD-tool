//This class is used for main page showing plan list

#import "PlanListViewController.h"
#import "PlanCell.h"
#import "CheckViewController.h"
#import "ChangeTagViewController.h"
#import "OSSearchController.h"

@interface PlanListViewController ()
        < UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate >
{
    NSMutableArray<PlanData *>  *filteredPlanArray;            //Searched result
    NSMutableArray<PlanData *>  *allPlanArray;                 //All record array
    NSManagedObjectContext      *managedObjectContext;         //CoreData context
}

@property (   weak, nonatomic ) IBOutlet UITableView *planListTableView; //tableView show plan list
@property (   weak, nonatomic ) IBOutlet UILabel     *addPlanTipLabel;   //Show tips when none record
@property ( strong, nonatomic ) UISearchController   *searchController;  //UISearchController to filter record

@end


@implementation PlanListViewController


/*
┌────────────────────────────────────────────────────────────────────┐
│View did load                                                       │
│1. SearchController config                                          │
│2. Generate array for filtered array via search                     │
│3. Config coreData                                                  │
│4. Config tableView protocols                                       │
└────────────────────────────────────────────────────────────────────┘
 */
- (void) viewDidLoad {

    [ super viewDidLoad ];

    //SearchController config
    _searchController = [ [ OSSearchController alloc ] initWithSearchResultsController: nil ];

    self.searchController.searchResultsUpdater              = self;
    self.searchController.searchBar.scopeButtonTitles       = @[ @"所有", @"重要", @"一般" ];
    self.searchController.searchBar.delegate                = self;
    self.definesPresentationContext                         = YES;
    self.planListTableView.tableHeaderView                  = self.searchController.searchBar;

    //Generate array for filtered array via search
    filteredPlanArray = [ NSMutableArray new ];

    //Config coreData
    AppDelegate *appDelegate = (AppDelegate *)[ UIApplication sharedApplication ].delegate;
    managedObjectContext = appDelegate.managedObjectContext;

    //Config tableView protocols
    self.planListTableView.delegate = self;
    self.planListTableView.dataSource = self;
}


//Refresh data every time when view will appear
- (void) viewWillAppear: (BOOL)animated {

    [ super viewWillAppear: animated ];
    [ self refreshData ];
}


#pragma mark -
#pragma mark UITableViewDelegate & Datasource

/*
┌─────────────────────────────────────────────────────────────────────────────┐
│Config TableView rows                                                        │
│1. If searchController is active or has input, return filtered array.count   │
│2. Or return all array.count                                                 │
└─────────────────────────────────────────────────────────────────────────────┘
 */
- (NSInteger) tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)section {

    if ( [ self.searchController isActive ] || self.searchController.searchBar.text.length > 0 ) {
        return filteredPlanArray.count;
    }
    return allPlanArray.count;
}


/*
┌─────────────────────────────────────────────────────────────────────────────┐
│Config cell content                                                          │
│1. Choose which array to show                                                │
│2. Set plan color based on importance and reached                            │
│3. Config progress UI                                                        │
│4. Config tags UI                                                            │
│5. Config cell's 2 menu button action                                        │
└─────────────────────────────────────────────────────────────────────────────┘
 */
- (UITableViewCell *) tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {

    PlanCell *cell = [ tableView dequeueReusableCellWithIdentifier: @"planCell" ];

    //Choose which array to show
    PlanData *planTemp;

    if ( [ self.searchController isActive ] || self.searchController.searchBar.text.length > 0 ) {

        planTemp = filteredPlanArray[(NSUInteger) indexPath.row ];

    } else {

        planTemp = allPlanArray[(NSUInteger) indexPath.row ];
    }

    //Set plan color
    cell.nameLabel.text = planTemp.name;

    if ( planTemp.reached.intValue ) {
        cell.reachedImageView.hidden = NO;
        cell.processLabel.hidden     = YES;

    } else {
        cell.reachedImageView.hidden = YES;
        cell.processLabel.hidden     = NO;
        [ cell.nameLabel setTextColor: planTemp.importance.intValue ? [UIColor blackColor] : [UIColor redColor] ];
    }

    //Config progress UI
    float progress = planTemp.progress.floatValue / planTemp.targetNumber.floatValue;
    cell.processLabel.text = [ NSString stringWithFormat: @"进度 %.1f %%", progress * 100 ];

    //Config tags UI
    for ( int index = 0; index < 3; ++index ) {
        UILabel *tagLabel = [ cell viewWithTag: index + 300 ];
        //UILabel *tagLabel = ( UILabel * ) [ cell viewWithTag: index + 300 ];
        [ tagLabel setHidden: true ];
    }

    NSArray<NSString *> *tagArray = planTemp.tags;

    if ( tagArray.count > 0 ) {

        for ( int index = 0; index < tagArray.count; index++ ) {

            UILabel *tagLabel = ( UILabel * ) [ cell viewWithTag: index + 300 ];
            [ tagLabel setHidden: false ];
            tagLabel.text = tagArray[ (NSUInteger)index ];
        }
    }

    //Config cell's 2 menu button action
    UIStoryboard *storyBoard = [ UIStoryboard storyboardWithName: @"Main" bundle: [ NSBundle mainBundle ] ];

    //Present ChangeTagViewController
    cell.changeTagClickedBlock = ^( ) {

        ChangeTagViewController *changeTagVC = [ storyBoard instantiateViewControllerWithIdentifier: @"changeTagViewController" ];
        [ changeTagVC setValue: planTemp forKey: @"planData" ];
        [ self presentViewController: changeTagVC animated: YES completion: nil ];
    };

    //Present ChangePlan
    cell.changePlanClickedBlock = ^( ) {

        UIViewController *planVC;

        if ( planTemp.type.intValue == 0 ) {
            planVC = [ storyBoard instantiateViewControllerWithIdentifier: @"changeProcessViewController" ];

        } else {
            planVC = [ storyBoard instantiateViewControllerWithIdentifier: @"changeSubmissionViewController" ];
        }

        [ planVC setValue: planTemp forKey: @"planData" ];
        [ self presentViewController: planVC animated: YES completion: nil ];
    };

    return cell;
}


/*
┌─────────────────────────────────────────────────────────────────────────────┐
│Config action when cell is selected                                          │
│1. If searchController is active                                             │
│    - dismiss searchController                                               │
│    - invoke method to show relative daily check page                        │
│2. Or just show relative daily check page                                    │
└─────────────────────────────────────────────────────────────────────────────┘
 */
- (void) tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {

    if ( [ self.searchController isActive ] || self.searchController.searchBar.text.length > 0 ) {

        [ self dismissViewControllerAnimated: true completion: ^{

            PlanData *clickedPlan = filteredPlanArray[ (NSUInteger) indexPath.row ];
            [ self showCheckViewController: clickedPlan ];
        } ];

    } else {

        PlanData *clickedPlan = allPlanArray[ (NSUInteger) indexPath.row ];
        [ self showCheckViewController: clickedPlan ];
    }
}


//Set tableView row can be edited
- (BOOL) tableView: (UITableView *)tableView canEditRowAtIndexPath: (NSIndexPath *)indexPath {
    return YES;
}


/*
┌─────────────────────────────────────────────────────────────────────────────┐
│Config tableView row editing                                                 │
│1. If searchController is active or has input                                │
│    - this row belongs to filtered array                                     │
│    - or belongs to all array                                                │
│2. If editing style is delete, delete and save, refresh UI                   │
└─────────────────────────────────────────────────────────────────────────────┘
 */
- (void) tableView: (UITableView *)tableView commitEditingStyle: (UITableViewCellEditingStyle)editingStyle
                                              forRowAtIndexPath: (NSIndexPath *)indexPath {

    PlanData *clickedPlan;

    if ( [ self.searchController isActive ] || self.searchController.searchBar.text.length > 0 ) {
        clickedPlan = filteredPlanArray[ (NSUInteger) indexPath.row ];

    } else {
        clickedPlan = allPlanArray[ (NSUInteger)indexPath.row ];
    }

    if ( editingStyle == UITableViewCellEditingStyleDelete ) {

        [ managedObjectContext deleteObject: clickedPlan ];
        [ managedObjectContext save: nil ];

        [ self refreshData ];
    }
}


/*
┌─────────────────────────────────────────────────────────────────────────────┐
│Config action when cell is selected                                          │
│1. If searchController is active                                             │
│    - dismiss searchController                                               │
│    - invoke method to show relative daily check page                        │
│2. Or just show relative daily check page                                    │
└─────────────────────────────────────────────────────────────────────────────┘
 */
- (void) showCheckViewController: (PlanData *)clickedPlan {

    UIStoryboard *storyBoard = [ UIStoryboard storyboardWithName: @"Main" bundle: [ NSBundle mainBundle ] ];

    CheckViewController *checkViewController;

    NSString *viewControllerIdentifier = (clickedPlan.type.intValue == 0)?
            @"processCheckViewController":@"submissionCheckViewController";

    checkViewController = [ storyBoard instantiateViewControllerWithIdentifier: viewControllerIdentifier ];

    [ checkViewController setPlanData: clickedPlan ];

    [self presentViewController: checkViewController animated: YES completion: nil ];
}


/*
┌─────────────────────────────────────────────────────────────────────────────┐
│Update UI every time data changed                                            │
│1. Gain data array from database                                             │
│2. If none record, show tip view                                             │
│3. Or tableView reload data.                                                 │
│4. If searchController has input, set it active                              │
└─────────────────────────────────────────────────────────────────────────────┘
 */
- (void) refreshData {

    NSFetchRequest *fetchRequest = [ NSFetchRequest fetchRequestWithEntityName: @"PlanData" ];

    NSArray *allPlanArrayTemp    = [ managedObjectContext executeFetchRequest: fetchRequest error: nil ];

    allPlanArray = [ NSMutableArray arrayWithArray: allPlanArrayTemp ];

    [ self.addPlanTipLabel setHidden: allPlanArray.count == 0 ? false : true ];

    [ self.planListTableView reloadData ];

    if ( self.searchController.searchBar.text.length > 0 ) {
        [ self.searchController setActive: true ];
    }
}


/*
┌─────────────────────────────────────────────────────────────────────────────┐
│Filter dataArray via searchController                                        │
│1. If searchController has input                                             │
│    - filter all dataArray to generate filtered array                        │
│    - If none input, show all dataArray                                      │
│2. Filter new array based on step 1's array via scope                        │
│    - '0' means show the important records only                              │
│    - '1' means show the unimportant records only                            │
│    - '2' means show all records                                             │
│3. tableView reload data to show filtered result                             │
└─────────────────────────────────────────────────────────────────────────────┘
 */
- (void) filterContentForSearchContext: (NSString *)keywords andScope: (NSString *)scopeString {

    //If searchController has input
    if ( keywords.length > 0 ) {

        NSPredicate *predicate = [ NSPredicate predicateWithFormat: @"%K LIKE[c] %@", @"name", [ NSString stringWithFormat: @"*%@*", keywords ] ];
        filteredPlanArray = [ NSMutableArray arrayWithArray: [ allPlanArray filteredArrayUsingPredicate: predicate ] ];

    } else {
        filteredPlanArray = allPlanArray;
    }

    //If scope has selected index
    if ( scopeString.length > 0 ) {

        int newScope = 0;

        if ( [ scopeString isEqualToString: @"重要" ] ) {
            newScope = 0;

        } else if ( [ scopeString isEqualToString: @"一般" ] ) {
            newScope = 1;

        } else {
            newScope = 2;
        }

        // '2' means 'All' is selected
        if ( newScope != 2 ) {

            NSPredicate *predicate = [ NSPredicate predicateWithFormat: @"%K == %d", @"importance", newScope ];
            filteredPlanArray = [ NSMutableArray arrayWithArray: [ filteredPlanArray filteredArrayUsingPredicate: predicate ] ];
        }
    }
    [ self.planListTableView reloadData ];
}


#pragma mark -
#pragma mark UISearchResultsUpdating

/*
┌─────────────────────────────────────────────────────────────────────────────┐
│Config tableViewController to show updated data                              │
│1. Get searchBar input and selected ScopeButtonTitle                         │
│2. Filter all datas to generate new array                                    │
│3. tableView reloadData to show filtered array                               │
└─────────────────────────────────────────────────────────────────────────────┘
 */
- (void) updateSearchResultsForSearchController: (UISearchController *)searchController {

    UISearchBar *searchBar = searchController.searchBar;
    NSString *scope = searchBar.scopeButtonTitles[ (NSUInteger) searchBar.selectedScopeButtonIndex ];
    [ self filterContentForSearchContext: searchBar.text andScope: scope ];
    [ self.planListTableView reloadData ];
}


#pragma mark -
#pragma mark UISearchBarDelegate

/*
┌──────────────────────────────────────────────────────────────────────────────────┐
│Config action when scopeButton changed                                            │
│1. Invoke method to filter data based on searchController selection and update UI │
└──────────────────────────────────────────────────────────────────────────────────┘
 */
- (void) searchBar: (UISearchBar *)searchBar selectedScopeButtonIndexDidChange: (NSInteger)selectedScope {

    [ self updateSearchResultsForSearchController: self.searchController ];
}

@end
