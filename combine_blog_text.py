#! /usr/bin/env python

import sys, csv
from collections import defaultdict

if __name__ == '__main__':
    fn, out = sys.argv[1], sys.argv[2]

    all_posts = []
    by_date = defaultdict(list)
    with open(fn, 'r') as f:
        c = csv.reader(f)
        headers = c.next()
        for line in c:
            text = line[4]
            date = line[7]
            year = date[:4]

            all_posts.append(text)
            by_date[year].append(text)

    with open(out, 'w') as f:
        f.write("\n".join(all_posts))

    for date, posts in by_date.iteritems():
        with open(out.replace('.', '-' + date + '.'), 'w') as f:
            f.write("\n".join(posts))
