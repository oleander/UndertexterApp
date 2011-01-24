//
//  main.m
//  UndertexterApp
//
//  Created by Linus Oleander on 2011-01-23.
//  Copyright Chalmers 2011. All rights reserved.
//

#import <MacRuby/MacRuby.h>

int main(int argc, char *argv[])
{
    return macruby_main("rb_main.rb", argc, argv);
}
