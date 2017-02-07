//This class is used for CoreData

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ValueTransformer.h"

NS_ASSUME_NONNULL_BEGIN

@interface PlanData : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "PlanData+CoreDataProperties.h"


//Create subclass of NSValueTransformer for attribute: id submissions
@interface Submissions : ValueTransformer

@end


//Create subclass of NSValueTransformer for attribute: id submissions
@interface Tags : ValueTransformer

@end