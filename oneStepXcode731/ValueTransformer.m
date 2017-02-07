//This class is  used for Entity Transformable Attributes

#import "ValueTransformer.h"


@implementation ValueTransformer


/*
┌────────────────────────────────────────────────────────────────────┐
│Implement                                                           │
│1. Config Class by overwritten 4 methods                            │
│2. Ensure hands-off data transform between this class and NSArray   │
└────────────────────────────────────────────────────────────────────┘
 */
+ (Class) transformedValueClass {
    return [ NSArray class ];
}


+ (BOOL) allowsReverseTransformation {
    return YES;
}


- (id) transformedValue: (id)value {
    return [ NSKeyedArchiver archivedDataWithRootObject: value ];
}


- (id) reverseTransformedValue: (id)value {
    return [ NSKeyedUnarchiver unarchiveObjectWithData: value ];
}

@end