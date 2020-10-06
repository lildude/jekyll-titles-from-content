# Jekyll Titles from Content

A Jekyll plugin to pull the page title from the first X words of the first line of the content, when none is specified.

## What it does

If you have a Jekyll page that doesn't have a title specified in the YAML Front Matter, this plugin instructs Jekyll to use that first X words of the content as the page's title.

## Why

Because lots of plugins and templates rely on `page.title`. This doesn't play nicely with micro blogging which doesn't require a title.

## Usage

1. Add the following to your site's Gemfile:

  ```ruby
  gem 'jekyll-titles-from-content'
  ```

2. Add the following to your site's config file:

  ```yml
  plugins:
    - jekyll-titles-from-content
  ```
  Note: If you are using a Jekyll version less than 3.5.0, use the `gems` key instead of `plugins`.

## Configuration

Configuration options are optional and placed in `_config.yml` under the `titles_from_content` key. They default to:

```yml
titles_from_content:
  enabled:     true
  words:       5
  collections: true
```

### Processing Collections

If you want to enable this plugin for collection items, set the `collections` option to `true`.

Since collection items (including posts) already have a title inferred from their filename, this option changes the behavior of this plugin to override the inferred title.

### Disabling

Even if the plugin is enabled (e.g., via the `:jekyll_plugins` group in your Gemfile) you can disable it by setting the `enabled` key to `false`.

### Credit

This plugin is heavily inspired by the [jekyll-titles-from-headings](https://github.com/benbalter/jekyll-titles-from-headings) plugin.

http://osfameron.github.io/jekyll-plugins-tutorial/2015/12/05/jekyll-plugins-tutorial-part-2.html
