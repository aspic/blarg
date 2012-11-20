## Blarg

Is a small simplistic static site generator. It runs a post or all the
posts through a sequence of "filters", and strips meta data, anchors and
finally generates the HTML by running the result through a markdown
parser.

### Sites using this static site generator!

-    [My own page](http://kjetil.mehl.no/blarg)

### Dependencies

- Template (template toolkit)
- Config::File
- Text::Markdown
- File::Slurp

### Usage

1.  Create one or several posts in the "posts" directory. These posts must
use the [markdown syntax](http://daringfireball.net/projects/markdown/syntax).
2. Generate the site by running:
    `perl ./bin/deploy-post.pl`

If everything was successful, the site was now generated in the
"site"-directory, which could be the root document of your preferred web
server.

#### Meta fields

All posts must be prepended with at least a meta field for template.
This field tells the generator what template to run this post through.
These templates gets read from the /templates directory. The declaration
of templates is displayed below:

    ---
	template: post.tpl
	---

In addition to this there are several other meta fields. These are
explained in the following sub sections.

##### Projects

One post may point to a project or something similar. This is done by
adding two fields to the meta fieldset:

	---
	template: post.tpl
	project_url: myproject.html
	project_title: A project!
	---

For the project URL to give any meaning a "myproject.md"-post should
also be created in the /posts directory.

##### Tags

Posts can be tagged by adding the following to the meta fieldset:

	---
	template: post.tpl
	tags: tag1,tag2
	---

In addition to this a tag-file must also be specified in the
configuration file. This path tells the generator where to create the
overview of the tags. This file must also exist in the /posts directory.

1.	Create /posts/tags.md
2.	Add tags.md to the PAGE_TAGS config line
3.	Start to tag posts

