//This Class is used for tableView delegate & datasource

#import "TableViewProtocolClassForSetting.h"

@implementation TableViewProtocolClassForSetting


#pragma mark -
#pragma mark New Instance

/*
┌──────────────────────────────────────────────┐
│Instance method for new instance              │
│1. assign values to properties                │
└──────────────────────────────────────────────┘
 */
- (instancetype) initWithArray: (NSMutableArray *) dataArray Identifier: (NSString *) identifier {

    _dataArray  = dataArray;
    _identifier = identifier;
    return self;
}


/*
┌───────────────────────────────────────────────────────┐
│Class method for new instance                          │
│1. call instance method to assign values to properties │
└───────────────────────────────────────────────────────┘
 */
+ (instancetype) createWithArray: (NSMutableArray *) dataArray Identifier: (NSString *) identifier {

    return [[TableViewProtocolClassForSetting alloc] initWithArray: dataArray Identifier: identifier];
}


/*
┌──────────────────────────────────────────────┐
│Instance method for new instance              │
│1. assign values to properties                │
└──────────────────────────────────────────────┘
 */
- (BOOL) tableView: (UITableView *) tableView canEditRowAtIndexPath: (NSIndexPath *) indexPath {
    return true;
}


/*
┌──────────────────────────────────────────────┐
│Instance method for new instance              │
│1. assign values to properties                │
└──────────────────────────────────────────────┘
 */
- (void) tableView: (UITableView *) tableView commitEditingStyle: (UITableViewCellEditingStyle) editingStyle
 forRowAtIndexPath: (NSIndexPath *) indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.dataArray removeObjectAtIndex:(NSUInteger) indexPath.row];
        if (self.commitEditingBlock){
            self.commitEditingBlock(indexPath);
        }
    }

    [tableView reloadData];
}


#pragma mark -
#pragma mark UITableViewDatasource

/*
┌───────────────────────────────────────────────────────┐
│Set Section numbers                                    │
│1. Return 1 (only need 1)                              │
└───────────────────────────────────────────────────────┘
 */
- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView {
    return 1;
}


/*
┌──────────────────────────────────────────────┐
│Instance method for new instance              │
│1. assign values to properties                │
└──────────────────────────────────────────────┘
 */
- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
    return self.dataArray.count;
}


/*
┌──────────────────────────────────────────────┐
│Instance method for new instance              │
│1. assign values to properties                │
└──────────────────────────────────────────────┘
 */
- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: self.identifier];
    if (self.cellConfigBlock) {
        self.cellConfigBlock(cell, indexPath);
    }

    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate

/*
┌──────────────────────────────────────────────┐
│Instance method for new instance              │
│1. assign values to properties                │
└──────────────────────────────────────────────┘
 */
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {

}

@end