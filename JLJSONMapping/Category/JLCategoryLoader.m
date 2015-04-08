//
//  JLCategoryLoader.m
//
//  Created by Joshua Liebowitz on 4/7/15.
//

#import "JLCategoryLoader.h"
#import "NSError+JLJSONMapping.h"
#import "NSMutableArray+JLJSONMapping.h"
#import "NSObject+JLJSONMapping.h"

@implementation JLCategoryLoader

+ (void)loadCategories
{
    linkErrorCategory();
    linkMutableArrayCategory();
    linkObjectCategory();
}

@end
