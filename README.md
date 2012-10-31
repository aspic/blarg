## Blarg

Is a small simplistic static site generator. It runs a post or all the
posts through a sequence of "filters", and strips meta data, anchors and
finally generates the HTML by running the result through a markdown
parser.

### Dependencies

- Template (template toolkit)
- Config::File
- Text::Markdown
- File::Slurp

### Usage

1.  Create one or several posts in the "posts" directory. These posts must
use the [markdown syntax](http://daringfireball.net/projects/markdown/syntax).
2. Generate the site by running:
    perl ./bin/deploy-post.pl

If everything was successful, the site was now generated in the
"site"-directory, which could be the root document of your preferred web
server.
