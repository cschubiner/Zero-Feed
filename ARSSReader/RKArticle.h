//
//  RKArticle.h
//  ARSSReader
//
//  Created by Clay Schubiner on 10/20/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKArticle : NSObject

@property (nonatomic, copy) NSNumber *id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;

@end
