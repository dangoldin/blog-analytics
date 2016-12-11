#! /usr/bin/env python

import sys, csv

if __name__ == '__main__':
    fn, out = sys.argv[1], sys.argv[2]

    all_posts = []
    with open(fn, 'r') as f:
        c = csv.reader(f)
        headers = c.next()
        for line in c:
            all_posts.append(line[4])

    with open(out, 'w') as f:
        f.write("\n".join(all_posts))
