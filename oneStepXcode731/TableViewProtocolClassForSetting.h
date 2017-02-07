//This Class is used for tableView delegate & datasource

#import <Foundation/Foundation.h>

typedef void(^CellConfigBlock)(UITableViewCell *cell, NSIndexPath *indexPath);
typedef void(^CommitEditingBlock)(NSIndexPath *indexPath);

@interface TableViewProtocolClassForSetting : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy  ) NSString       *identifier;            //cell identifier
@property (nonatomic, strong) NSMutableArray *dataArray;             //data array as datasource
@property (nonatomic, copy  ) CellConfigBlock cellConfigBlock;       //Config cell content
@property (nonatomic, copy  ) CommitEditingBlock commitEditingBlock; //Additional action needed when editing cell

+ (instancetype) createWithArray: (NSMutableArray *)dataArray Identifier:(NSString *)identifier;

@end