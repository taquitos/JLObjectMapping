//
//  JLCategoryLoader.m
//
//  Created by Joshua Liebowitz on 4/7/15.
//

#import "FABJLCategoryLoader.h"
#import "NSError+JLJSONMapping.h"
#import "NSMutableArray+JLJSONMapping.h"
#import "NSObject+JLJSONMapping.h"

@implementation FABJLCategoryLoader

+ (void)loadCategories
{
    linkErrorCategory();
    linkMutableArrayCategory();
    linkObjectCategory();
}

@end
