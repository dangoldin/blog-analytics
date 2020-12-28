#! /usr/bin/env python

# Sample usage:
# python analyze.py ~/code/dangoldin.github.com/_posts /tmp/out.csv text

import os, sys, json, re, csv

# TODO: Just use string.punctuation
RE_CLEAN_TEXT = re.compile('[\s\.\-\?]+')

RE_MARKDOWN_LINK = re.compile('\[.+?\]\(.+?\)')

# At some point also strip markdown
RE_HTML = re.compile('<.+?>')

def get_posts(dirname):
    return [x for x in os.listdir(dirname) if x.endswith('md') or x.endswith('.markdown')]

def get_date(filename):
    f = filename.split('/')[-1]
    pieces = f.split('-')
    return '-'.join(pieces[:3])

def get_slug(filename):
    f = filename.replace('.md','').split('/')[-1]
    pieces = f.split('-')
    return '-'.join(pieces[3:])

def count_words(text):
    return len(RE_CLEAN_TEXT.split(text))

def count_links(text):
    # Markdown links
    num_links = len(RE_MARKDOWN_LINK.findall(text))

    # A href links
    num_links += text.count('<a ')

    return num_links

def analyze_content(content):
    tags = []
    title = keywords = description = ''
    for line in content.split("\n"):
        if line.startswith('title:'):
            title = line.replace('title:', '').strip('" ')
        if line.startswith('tags:'):
            tags = json.loads(line.replace('tags:','').strip('" '))
        if line.startswith('keywords'):
            keywords = line.replace('keywords:','').strip('" ')
        if line.startswith('description'):
            description = line.replace('description:','').strip('" ')

    text = content.split('---')[-1].replace('{% include JB/setup %}', '').strip("\n")

    clean_text = RE_HTML.sub(' ', text.replace("\n", ' ')).strip()

    return {
        'title': title,
        'tags': ','.join(tags),
        'keywords': keywords,
        'description': description,
        'text': clean_text,
        'num_chars': len(clean_text),
        'num_text_words': count_words(text),
        'num_text_description': count_words(description),
        'num_keywords': len(keywords.split(',')),
        'num_tags': len(tags),
        'num_images': text.lower().count('<img'),
        'num_links': count_links(text),
    }

def analyze_post(filename):
    date = get_date(filename)
    slug = get_slug(filename)

    # Get the # of words
    with open(filename, 'r') as f:
        content = f.read()
        try:
            o = analyze_content(content)
            o['ymd'] = date
            o['slug'] = slug
            return o
        except Exception as e:
            print('Failed processing', filename, e)

    return {}

def write_csv(analysis, outfile, columns):
    with open(outfile, 'w') as f:
        # Ignore custom columns not matching dictionary
        c = csv.DictWriter(f, columns, extrasaction='ignore', delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        c.writeheader()
        c.writerows(analysis)

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print('Specify directory to analyze and location of outfile')
        exit(1)

    dirname, outfile = sys.argv[1], sys.argv[2]

    columns_to_exclude = []
    if len(sys.argv) == 4:
        columns_to_exclude = sys.argv[3].split(',')

    posts = get_posts(dirname)

    analysis = [analyze_post(os.path.join(dirname, p)) for p in posts]

    column_order = """title,tags,keywords,description,num_chars,num_text_words,num_text_description,num_keywords,num_tags,num_images,num_links,ymd,slug,text""".split(',')

    columns = [x for x in column_order if x not in columns_to_exclude]

    write_csv(analysis, outfile, columns)
