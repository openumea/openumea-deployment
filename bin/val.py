#!/usr/bin/env python
import pprint
import yaml
import sys

if __name__ == '__main__':
    for foo in sys.argv[1:]:
        print "checking: "
        print foo
        print
        bar = yaml.load(file(foo, 'rb').read())
        #pprint.pprint(bar)
