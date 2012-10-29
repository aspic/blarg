---
template: post.tpl
project_url: blarg.html
project_title: Blarg
title: Hello Blarg!
---
## A post about Blarg
[% date %]

I just figured I needed a static site generator (hah!), but when
looking for suitable software, they were all written in the wrong
programming languages. Hey, I don't want to install Ruby on Rails, and
why are people still using PHP?!

### So I rolled my own
.. using Perl and some neat modules

- Template toolkit
- [Markdown](http://daringfireball.net/projects/markdown/) by John
  Gruber

(it has some other dependencies as well).

### How?
The engine is basically just a small library for dissecting
fixed-format text files (gathering meta data, action hooks etc.). At
last the content gets run through the markdown-parser, and stored to
disk. What you are reading now, is the result of this process.

### Why?
Pushing another element onto this stack of _things I want to spend time
on_ just seemed appropriate. I've also wanted a minimalistic hobby site
for some time, where I can write about hobby projects, and other stuff.

### Latest Blarg commits
[% git limit=3 path=/home/aspic/dev/blarg %]
