---
title:  Documentation
layout: page
permalink: /doc/
sitemap: false
---

{% comment %}
Trick to get TOC Generating
If content is enclosed in html tag, toc doesn't generate
{% endcomment %}
{% capture toc %}
* TOC WILL GO HERE DO NOT REMOVE
{:toc}
{% endcapture %}

{% capture text %}
## Pavement Preservation Knowledge Base
The **Pavement Preservation Knowledge Base** (aka **KB** in this document) website is build with [Jekyll](http://jekyllrb.com/).

### Knowledge base organization
Base KB's element is **article**.

**Articles** are organized in **collection** : **methods**, **materials** and **manage**.

An **article** can be from one **category** (eg : Fog Seals, Chip Seals, Spray Seals, ... ). Each collection has is own categories (see **categories** paragraph for more informations).

An **article** can be from one type (**article**, **video**, **link**, **project** or **research**).

An **article** can have one to many **tags**.

## Collections organization

We have three **collections** used to display **articles** : **methods**, **materials** and **manage**.

They are usual Jekyll collections.

### Configuration
This is the basic configuration for a collection.

{% highlight yaml %}
collections:

  methods:
    output: true   # every page in the collection will be created
    isKB: true     # is part of Knowledge base
    name: "Methods" # Print name used in titles, menus, ...
    categories:
      [...]
{% endhighlight %}

All articles for **methods** collections goes in a **_methods/categoryName** folder
(see **categories** paragraph for more informations).

In order to differentiate **KB** collections from other collections we set a `isKB: true` on the collection.

### Collection's index page

For our **methods** collection we have a methods/index.html page.

{% highlight yaml %}
{% raw %}
---
title: Methods
---
{% include components/collection-page.html %}
{% endraw %}
{% endhighlight %}

This page will then be reached at **/methods/index.html** that can be shortened to **/methods/**.

## Create a Category

Articles are organized in collections, then in categories inside each collection.

Article can be part of only one **category**.
Each collection has is own categories.

A category is automatically assigned depending on the folder name and default configuration rules.

### Add the category in parent collection configuration.

Add `- { name: "Fog Seals", slug: fog-seals }` in :

{% highlight yaml %}
collections:
  methods:
    output: true
    # categories will appear in the order they are here
    categories:
        - { name: "Fog Seals", slug: fog-seals }
{% endhighlight %}

Here we've added the **Fog Seals** category to the methods collection.
Category name is used for presentation and **slug** is used for path and url generation.

Note that the generated url will be **methods/fog-seals/articleTitle.html**.
It's then important to give meaningful slug to categories and to avoid abbreviations.

### Create a folder for this category

We then create a **_methods/fog-seals** folder.

### Create a default configuration rule for this category.

Add `- { scope: { path: "methods/fog-seals" }, values:  { category: "fog-seals" } }` in :

{% highlight yaml %}
defaults:
  # default layout for collections articles
[...]

# assign a default category to any item in a given folder
  - { scope: { path: "methods/fog-seals" }, values:  { category: "fog-seals" } }
{% endhighlight %}

Any article file in **_methods/fog-seals** folder will see its category set to **fog-seals**.

### Create the Category index page

Create `methods/fog-seals.md` page containing :

{% highlight yaml %}
{% raw %}
---
title: Methods - Fog seals
---
{% include components/category-page.html %}
{% endraw %}
{% endhighlight %}

## Creating an article

You can find a sample article at `_samples/article.md`.
Open it and `save as` in the right path.

Example : for a `Methods > Fog Seals > New Method` article, you save it as
`_methods/fog-seals/new-method.md`

Articles metadatas are in the front matter.

  - title
  - date : use `YYYY-MM-DD` format and NOT `YYYY-MM-DD HH:MM:SS`
  - tags : tags are used to propose related articles. You can provide from 5 to 20 tags for an article. Use business words (truck, cement, seal).

```
tags :
  - tag one
  - tag two

or

tags: [tag one, tag two]
```
  - type : type can be "article", "video", "link", project" or "research"
  - image_path : path to article image. Leave empty is no image.

## Publishing to github

You can control your site locally with `rake serve`.

Publish with `rake publish`. Before that, you must configure the `github` key in `_config.yml`

It will :

  - check if we need to create new category page
  - build the site
  - check if git setup is correct
  - publish code in master
  - publish site in gh-pages (note: this must be changed for user/org repository)

{% endcapture %}

<style>
  pre{
    background: #E6E6E6;
  }
  code{
    background: #E6E6E6;
    border: none;
  }
</style>


<div class="row">
  <div class="medium-4 columns">
{{ toc }}
  </div>
  <div class="medium-8 columns">
{{ text }}
  </div>
</div>
