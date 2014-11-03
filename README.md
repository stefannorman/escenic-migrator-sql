escenic-migrator-sql
====================

A shell script using SQL to migrate Escenic article data from version 4 to version 5

Use the script to export articles from an Escenic 4 database. It produces a lot of files in Escenic 5 syndication format. The files can then be imported directly using the standard import functionality in Escenic 5.

The script was tested and used during migration of [NWT](http://nwt.se). JIRA issue: [NWT-239](https://bricco.atlassian.net/browse/NWT-239).

Before using the script I migrated sections, users and media objects using ECE migration tool.
NOTE: some images in ECE4 had the same source and sourceid as some articles making them collide on import. To fix this I ran an SQL to change source of the image objects. An **_img** was added to the source.
```
update ArticleMetaContent set source = concat(source, '_img') where codeID = 2;
```
