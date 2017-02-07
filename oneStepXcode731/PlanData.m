//This class is used for CoreData

#import "PlanData.h"


@implementation PlanData


//Config this class's description for debug
- (NSString *) description {

    NSDictionary *dict1 = @{ @"Key": @"importance", @"Value": self.importance };
    NSDictionary *dict2 = @{ @"Key": @"name", @"Value": self.name };
    NSDictionary *dict3 = @{ @"Key": @"progress", @"Value": self.progress };
    NSDictionary *dict4 = @{ @"Key": @"repeatedMission", @"Value": self.repeatedMission?self.repeatedMission:@"empty"};
    NSDictionary *dict5 = @{ @"Key": @"targetNumber", @"Value": self.targetNumber };
    NSDictionary *dict6 = @{ @"Key": @"targetUnit", @"Value": self.targetUnit ? self.targetUnit : @"empty" };
    NSDictionary *dict7 = @{ @"Key": @"type", @"Value": self.type };
    NSDictionary *dict8 = @{ @"Key": @"reached", @"Value": self.reached };

    NSArray *array = @[ dict1, dict2, dict3, dict4, dict5, dict6, dict7, dict8 ];

    NSLog( @"submissions: %@", self.submissions ? self.submissions : @"empty" );
    NSLog( @"tags: %@", self.tags ? self.tags : @"empty" );
    NSLog( @"------------------------------------------------" );

    return [ NSString stringWithFormat: @"%@", array ];
}

@end