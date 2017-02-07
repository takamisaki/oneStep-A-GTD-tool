//This class is used for Attributes of Entity

#import "PlanData.h"

NS_ASSUME_NONNULL_BEGIN

@interface PlanData (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *importance;      //Plan importance
@property (nullable, nonatomic, retain) NSString *name;            //Plan name
@property (nullable, nonatomic, retain) NSNumber *progress;        //Plan checked number
@property (nullable, nonatomic, retain) NSString *repeatedMission; //Repeated mission (progress type only)
@property (nullable, nonatomic, retain) NSNumber *targetNumber;    //Target number
@property (nullable, nonatomic, retain) NSString *targetUnit;      //Target unit(days, times, etc)
@property (nullable, nonatomic, retain) NSNumber *type;            //Plan type(progress, submission)
@property (nullable, nonatomic, retain) NSNumber *reached;         //Mark if a plan is accomplished
@property (nullable, nonatomic, retain) id       submissions;      //Submission array (submission type only)
@property (nullable, nonatomic, retain) id       tags;             //Plan tags (custom marks)

@end

NS_ASSUME_NONNULL_END
