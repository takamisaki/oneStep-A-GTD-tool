//This class is used for main page's searchController

#import "OSSearchController.h"


@implementation OSSearchController


/*
┌────────────────────────────────────────────────────────────┐
│Overwritten init method                                     │
│1. Super init                                               │
│2. Config details properties                                │
└────────────────────────────────────────────────────────────┘
 */
- (instancetype) initWithSearchResultsController: (UIViewController *)searchResultsController {

    if ( self = [ super initWithSearchResultsController: searchResultsController ] ) {

        self.dimsBackgroundDuringPresentation = NO;
        [ self.searchBar sizeToFit ];
        [ self setHidesNavigationBarDuringPresentation: true ];

        self.searchBar.placeholder             = @"请输入规划名关键字";
        self.searchBar.barStyle                = UIBarStyleBlack;
        self.searchBar.translucent             = NO;
        self.searchBar.tintColor               = [ UIColor whiteColor ];
        self.searchBar.backgroundImage         = [ UIImage imageNamed: @"searchbar_background" ];
        self.searchBar.scopeBarBackgroundImage = [ UIImage imageNamed: @"scope_background" ];
    }

    return self;
}

@end
