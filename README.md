escenic-migrator-sql
====================

My task was to migrate NWT from Escenic 4.3 to Escenic 5.7. I used the ECE migration tools for migrating sections, users and media.
But when it came to the articles I found the Escenic migration plugins hard to use. Mainly because of poor user interface and inadequate error handling. 

To get more control I wrote this rather large shell script that exports all relevant (to me) article data to ECE 5 syndication files. The script uses SQL to export Escenic 4 article data.

Use the script to export articles from an Escenic 4 database. It produces a lot of files in Escenic 5 syndication format. The files can then be imported directly using the standard import functionality in Escenic 5.

The script was tested and used during migration of [NWT](http://nwt.se). JIRA issue: [NWT-239](https://bricco.atlassian.net/browse/NWT-239).

Before using the script I migrated sections, users and media objects using ECE migration tool.
NOTE: some images in ECE4 had the same source and sourceid as some articles making them collide on import. To fix this I ran an SQL to change source of the image objects. An **_img** was added to the source.
```
update ArticleMetaContent set source = concat(source, '_img') where codeID = 2;
```

Files exported are:
- content_*.xml - this is the article fields. Also the <uri> element is exported
- section-ref_true_*.xml - this is the home section refs.
- section-ref_false_*.xml - this is all non-home section relations.
- creator-*.xml - the creator refs.
- author-*.xml - the author refs.
- relation-*.xml - the article relations.
They must be imported in that order.

NOTE: To find out which sections are missing after the section-ref_*.xml imports run this oneliner:
```
grep ERROR /var/log/escenic/engine/ece-messages.log | sed "s/ /\\n/g" | grep unique-name | sort --unique
```
