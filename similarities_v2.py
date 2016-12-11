#! /usr/bin/env python

# Primarily from http://stackoverflow.com/questions/8897593/similarity-between-two-text-documents
import nltk, string
from sklearn.feature_extraction.text import TfidfVectorizer

nltk.download('punkt') # if necessary...

stemmer = nltk.stem.porter.PorterStemmer()
remove_punctuation_map = dict((ord(char), None) for char in string.punctuation)

def stem_tokens(tokens):
    return [stemmer.stem(item) for item in tokens]

'''remove punctuation, lowercase, stem'''
def normalize(text):
    return stem_tokens(nltk.word_tokenize(text.lower().translate(remove_punctuation_map)))

vectorizer = TfidfVectorizer(tokenizer=normalize, stop_words='english')

def cosine_sim(text1, text2):
    tfidf = vectorizer.fit_transform([text1, text2])
    return ((tfidf * tfidf.T).A)[0,1]

text_files = [
    'data/combined-2008.txt',
    'data/combined-2009.txt',
    'data/combined-2010.txt',
    'data/combined-2011.txt',
    'data/combined-2012.txt',
    'data/combined-2013.txt',
    'data/combined-2014.txt',
    'data/combined-2015.txt',
    'data/combined-2016.txt',
]

for f1 in text_files:
    for f2 in text_files:
        t1 = open(f1, 'r').read()
        t2 = open(f2, 'r').read()
        print f1, 'vs', f2, cosine_sim(t1, t2)
