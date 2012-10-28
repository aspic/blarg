---
template: post.tpl
project: blarg.html
title: Hello world!
---
## A post about Blarg

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

### Why?
I figured I already have too little time to do my own projects, so it
would not really matter. Also, because Perl is fun!

### Latest Blarg commits
{% git limit=3 path=/home/aspic/dev/blarg %}
