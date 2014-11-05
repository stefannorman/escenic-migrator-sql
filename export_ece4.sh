#!/bin/bash

OUT_DIR="/Users/stefan/Public/DropBox"

MYSQL_CMD="mysql -s --skip-column-names -u root nwt_ece4"

PUB_ID="17" # NWT
#PUB_ID="901840" # SLA
#PUB_ID="901870" # Eposten

CONTENT_TYPES="'default', 'review', 'jobAd', 'textAd'"

SKIP_ARTICLEIDS="10262, 1018702, 1022272, 1032622, 1032753, 1033329, 1034012, 1035181, 1035243, 1035302, 1035859, 1036155, 1036648, 1037297, 1037387, 1037612, 1037761, 1037843, 1039016, 1039417, 1040258, 1040584, 1040729, 1040781, 1041602, 1057077, 1068504, 1082980, 1110673, 1112312, 1136972, 1160884, 1168635, 11798, 1200486, 1213684, 1248914, 12520, 1315168, 1342719, 1390073, 1435899, 14511, 1462952, 1465148, 1499877, 1539312, 1604923, 1606398, 1609099, 1622287, 16241, 1630301, 1642135, 1645337, 16747, 16751, 16752, 16921, 16922, 17003, 17004, 17007, 17024, 17025, 17029, 17030, 17051, 17065, 17077, 17079, 17086, 17087, 17088, 17626, 17663, 18589, 20534, 21609, 22191, 22338, 22942, 23455, 23592, 24776, 25661, 27926, 28980, 29273, 29274, 29518, 30418, 31366, 31563, 31598, 31958, 32989, 33443, 33780, 34192, 34819, 34950, 37087, 37821, 38004, 38891, 39243, 39278, 43811, 43889, 444058, 444786, 444788, 452723, 453379, 45682, 46010, 46251, 46360, 473221, 47668, 488871, 489490, 48956, 489599, 490679, 492650, 495899, 49650, 499262, 499650, 50083, 501181, 503496, 505509, 50792, 509862, 510153, 510729, 513590, 514785, 51848, 518888, 518890, 518895, 519381, 521212, 523468, 52490, 525952, 526723, 529858, 532989, 534331, 534652, 537733, 54090, 542126, 543805, 544894, 545113, 545740, 547896, 551619, 551718, 555732, 555733, 556192, 556808, 557532, 557631, 562096, 563198, 564758, 566191, 566331, 566780, 566959, 568345, 568806, 568992, 569329, 570338, 57159, 571819, 573113, 573280, 57332, 577152, 577163, 577966, 578579, 578935, 578937, 582173, 582876, 58326, 583956, 584209, 584614, 586580, 586708, 588071, 588365, 588421, 589136, 589284, 591067, 59164, 593048, 593087, 593983, 594888, 59494, 596167, 596215, 596551, 59760, 599724, 603747, 603748, 605370, 608182, 608333, 609381, 610107, 61229, 612783, 613232, 62783, 637858, 63976, 64498, 65921, 66164, 66920, 66922, 673489, 677420, 67875, 67917, 681362, 68406, 70102, 70210, 70481, 717830, 72112, 728886, 73455, 73473, 739307, 739308, 740000, 740047, 771076, 774831, 779940, 799649, 814290, 823326, 823327, 823328, 841736, 849721, 858117, 858985, 863285, 871142, 871148, 871152, 871698, 875588, 876626, 879717, 881797, 882106, 882432, 882676, 883560, 885268, 888888, 888987, 891469, 892733, 899550, 900202, 902013, 903063, 907317, 911334, 912113, 914174, 915776, 920741, 920742, 920746, 920794, 921557, 924211, 926078, 927667, 929133, 938080, 955994, 960784, 962245, 979202, 979205, 985764, 989671, 997997, 998118, 998135"


# Enabled exports
ENABLE_CONTENT=true
ENABLE_SECTION_REF=true
ENABLE_CREATOR_AUTHOR=true
ENABLE_RELATION=true


# Tillagda sektioner
# - ece_val2010
# - ece_kandis (under Nöje)
# - ece_varmland

artid_query="
	select
		ArticleMetaContent.articleID
	from
		ArticleMetaContent, ArticleSection, Section, Articletype
	where
    	ArticleMetaContent.articleID = ArticleSection.articleID and
	    ArticleMetaContent.codeID = Articletype.codeID and
	    Articletype.codeText IN ($CONTENT_TYPES) and
    	ArticleMetaContent.Art_codeID = 2 and /* only state published */
    	ArticleSection.priority = 1 and /* home section */
    	ArticleSection.sectionID = Section.sectionID and
    	Section.referenceID = $PUB_ID and
    	ArticleMetaContent.articleID not in ($SKIP_ARTICLEIDS)
/*

and ArticleMetaContent.articleID = 1411931
*/

	order by ArticleMetaContent.articleID
	limit 100"

# create output dir
if [ ! -d $OUT_DIR ]; then
	mkdir $OUT_DIR;
fi

while read line
do
    row=($line)
    articleID=${row[0]}

if $ENABLE_CONTENT; then

	filename="content_$articleID.xml"

    echo "Creating content XML for article $articleID";

    echo "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>" > $OUT_DIR/$filename;
    echo "<!DOCTYPE htmlEntities [
    		<!ENTITY % htmlmathml-f PUBLIC
			\"-//W3C//ENTITIES HTML MathML Set//EN//XML\"
			\"htmlmathml-f.ent\">
			%htmlmathml-f;
		]>" >> $OUT_DIR/$filename;

    echo "<escenic xmlns=\"http://xmlns.escenic.com/2009/import\" version=\"2.0\">" >> $OUT_DIR/$filename;

    query="
	select
	    concat(
	        '<content',
	        concat(' source=\"', ifnull(ArticleMetaContent.source, 'nwt_ece4'), '\"'),
	        concat(' sourceid=\"', ifnull(ArticleMetaContent.sourceIDStr, ArticleMetaContent.articleID), '\"'),
	        ifnull(concat(' sourceid=\"', ArticleMetaContent.sourceID, '\"'),''),

	        /* switch content type: ECE4 default to ECE5 story */
	        concat(' type=\"', replace(Articletype.codeText, 'default', 'story'), '\"'),

	        concat(' state=\"', ArticleState.codeText, '\"'),
	        concat(' creationdate=\"', ArticleMetaContent.creationDate, '\"'),

	        /* some ECE4 publishDates was way off */
	        concat(' publishdate=\"',
	        	if(
	        		year(ArticleMetaContent.publishDate) < 2000,
	        		DATE_FORMAT(publishDate,concat(year(creationDate), '-%m-%d %T')),
	        		ArticleMetaContent.publishDate
	        	),
				'\"'
	        ),

	        concat(' last-modified=\"', ArticleMetaContent.lastModified, '\"'),
	        concat(' activatedate=\"', ArticleMetaContent.activateDate, '\"'),
	        concat(' expiredate=\"', ArticleMetaContent.expireDate, '\"'),
	        '>',

	        /* Export old URI for aliasing */
	        concat('<uri use-as-default=\"false\">article', ArticleMetaContent.articleID, '.ece</uri>'),

			/* Default fields */
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/TITLE') != '',
	            concat( '<field name=\"TITLE\">', ExtractValue(Content.Content, '/ARTICLE/TITLE'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/SUBTITLE') != '',
	            concat( '<field name=\"SUBTITLE\">', ExtractValue(Content.Content, '/ARTICLE/SUBTITLE'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/LEAD_TEXT') != '',
	            concat( '<field name=\"LEADTEXT\"><![CDATA[', ExtractValue(Content.Content, '/ARTICLE/LEAD_TEXT'), ']]></field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/BODY') != '',
	            concat(
	            	'<field name=\"BODY\">',
	            	replace(replace(
	            	replace(replace(
	            	ExtractValue(Content.Content, '/ARTICLE/BODY'),
	            	'<tel>', ''), '</tel>', ''),
	            	'<HTML-kod>', ''), '</HTML-kod>', ''),
	            	'</field>'
	            ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/FACTSTITLE1') != '',
	            concat( '<field name=\"FACTSTITLE1\">', ExtractValue(Content.Content, '/ARTICLE/FACTSTITLE1'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/FACTS1') != '',
	            concat( '<field name=\"FACTS1\">', ExtractValue(Content.Content, '/ARTICLE/FACTS1'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/FACTSTITLE2') != '',
	            concat( '<field name=\"FACTSTITLE2\">', ExtractValue(Content.Content, '/ARTICLE/FACTSTITLE2'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/FACTS2') != '',
	            concat( '<field name=\"FACTS2\">', ExtractValue(Content.Content, '/ARTICLE/FACTS2'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/FACTSTITLE3') != '',
	            concat( '<field name=\"FACTSTITLE3\">', ExtractValue(Content.Content, '/ARTICLE/FACTSTITLE3'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/FACTS3') != '',
	            concat( '<field name=\"FACTS3\">', ExtractValue(Content.Content, '/ARTICLE/FACTS3'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/BYLINE') != '',
	            concat(
	            	'<field name=\"BYLINE\">',
		            replace(
		            	if(
		            		/* some bylines have broke <tel> inside. remove it and everything thereafter */
		            		locate('<tel>', ExtractValue(Content,'/ARTICLE/BYLINE')) > 0,
		            		left(ExtractValue(Content,'/ARTICLE/BYLINE'), locate('<tel>', ExtractValue(Content,'/ARTICLE/BYLINE'))-1),
							ExtractValue(Content.Content, '/ARTICLE/BYLINE')
		            	),
						' & ', /* escape & */
						' &amp; '
	            	),
	            	'</field>'
	            ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/ARTICLECOMMENTS') != '',
	            concat(
		            '<field name=\"ARTICLECOMMENTS\"><value>',
		            if(
		            	ExtractValue(ExtractValue(Content, '/ARTICLE/ARTICLECOMMENTS'),'ecs_selection') = 'value-1',
		            	'value-1',
		            	'value-2'
		            ),
		            '</value></field>'
	            ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/TIPTEXT') != '',
	            concat( '<field name=\"TIPTEXT\">', ExtractValue(Content.Content, '/ARTICLE/TIPTEXT'), '</field>' ),
	            ''
	        ),

			/* Puff fields */
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/TEASERHEADING') != '',
	            concat( '<field name=\"TEASERHEADING\">', ExtractValue(Content.Content, '/ARTICLE/TEASERHEADING'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/TEASERSUMMARY') != '',
	            concat( '<field name=\"TEASERLEADTEXT\"><![CDATA[', ExtractValue(Content.Content, '/ARTICLE/TEASERSUMMARY'), ']]></field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/TEASERVIGNETTE') != '',
	            concat( '<field name=\"TEASERVIGNETTE\">', ExtractValue(Content.Content, '/ARTICLE/TEASERVIGNETTE'), '</field>' ),
	            ''
	        ),

			/* Access fields */
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/OVERRIDE_AGREEMENT') != '',
	            concat( '<field name=\"OVERRIDE_AGREEMENT\">', ExtractValue(Content.Content, '/ARTICLE/OVERRIDE_AGREEMENT'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/LOCK_ARTICLE') != '',
	            concat( '<field name=\"LOCK_ARTICLE\">', ExtractValue(Content.Content, '/ARTICLE/LOCK_ARTICLE'), '</field>' ),
	            ''
	        ),

			/* SEO fields */
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/SEOKEYWORDS') != '',
	            concat( '<field name=\"SEOKEYWORDS\">', ExtractValue(Content.Content, '/ARTICLE/SEOKEYWORDS'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/SEODESCRIPTION') != '',
	            concat( '<field name=\"SEODESCRIPTION\">', ExtractValue(Content.Content, '/ARTICLE/SEODESCRIPTION'), '</field>' ),
	            ''
	        ),

			/* Map fields */
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/MAP_LONGITUDE') != '',
	            concat( '<field name=\"MAP_LONGITUDE\">', ExtractValue(Content.Content, '/ARTICLE/MAP_LONGITUDE'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/MAP_LATITUDE') != '',
	            concat( '<field name=\"MAP_LATITUDE\">', ExtractValue(Content.Content, '/ARTICLE/MAP_LATITUDE'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/MAP_ZOOM') != '',
	            concat( '<field name=\"MAP_ZOOM\">', ExtractValue(Content.Content, '/ARTICLE/MAP_ZOOM'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/MAP_TITLE') != '',
	            concat( '<field name=\"MAP_TITLE\">', ExtractValue(Content.Content, '/ARTICLE/MAP_TITLE'), '</field>' ),
	            ''
	        ),

			/* Slideshow fields */
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/SLIDESHOW_BYLINE') != '',
	            concat( '<field name=\"SLIDESHOW_BYLINE\">', ExtractValue(Content.Content, '/ARTICLE/SLIDESHOW_BYLINE'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/SLIDESHOW_TITLE') != '',
	            concat( '<field name=\"SLIDESHOW_TITLE\">', ExtractValue(Content.Content, '/ARTICLE/SLIDESHOW_TITLE'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/SLIDESHOW_ID') != '',
	            concat( '<field name=\"SLIDESHOW_ID\">', ExtractValue(Content.Content, '/ARTICLE/SLIDESHOW_ID'), '</field>' ),
	            ''
	        ),

			/* Slideshow fields */
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/VIDEO_TITLE') != '',
	            concat( '<field name=\"VIDEO_TITLE\">', ExtractValue(Content.Content, '/ARTICLE/VIDEO_TITLE'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/YOUPLAY_PROGRAM') != '',
	            concat( '<field name=\"YOUPLAY_PROGRAM\">', ExtractValue(Content.Content, '/ARTICLE/YOUPLAY_PROGRAM'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/YOUPLAY_PART') != '',
	            concat( '<field name=\"YOUPLAY_PART\">', ExtractValue(Content.Content, '/ARTICLE/YOUPLAY_PART'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/YOUPLAY_LIVESTREAM') != '',
	            concat( '<field name=\"YOUPLAY_LIVESTREAM\">', ExtractValue(Content.Content, '/ARTICLE/YOUPLAY_LIVESTREAM'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/VIMEO_ID') != '',
	            concat( '<field name=\"VIMEO_ID\">', ExtractValue(Content.Content, '/ARTICLE/VIMEO_ID'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/YOUTUBE_LINK') != '',
	            concat( '<field name=\"YOUTUBE_LINK\">', ExtractValue(Content.Content, '/ARTICLE/YOUTUBE_LINK'), '</field>' ),
	            ''
	        ),

			/* Company fields */
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/COMPANYNAME') != '',
	            concat( '<field name=\"COMPANYNAME\">', ExtractValue(Content.Content, '/ARTICLE/COMPANYNAME'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/COMPANYCITY') != '',
	            concat( '<field name=\"COMPANYCITY\">', ExtractValue(Content.Content, '/ARTICLE/COMPANYCITY'), '</field>' ),
	            ''
	        ),
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/COMPANYURL') != '',
	            concat( '<field name=\"COMPANYURL\">', ExtractValue(Content.Content, '/ARTICLE/COMPANYURL'), '</field>' ),
	            ''
	        ),

			/* Review fields */
	        if(
	            ExtractValue(Content.Content, '/ARTICLE/RATING') != '' and
	            ExtractValue(ExtractValue(Content, '/ARTICLE/RATING'),'ecs_selection') != '',
	            concat(
		            '<field name=\"SCORE\"><value>',
		            ExtractValue(ExtractValue(Content, '/ARTICLE/RATING'),'ecs_selection'),
		            '</value></field>'
	            ),
	            ''
	        ),


	        '</content>'
		)
	from
	    Content, ArticleMetaContent, Articletype, ArticleState
	where
	    ArticleMetaContent.articleID = Content.articleID and
	    ArticleMetaContent.codeID = Articletype.codeID and
	    ArticleMetaContent.Art_codeID = ArticleState.codeID and
	    ArticleMetaContent.articleID = $articleID
    "
    $MYSQL_CMD --raw --default-character-set=utf8 -e "${query}" >> $OUT_DIR/$filename;


    echo "</escenic>" >> $OUT_DIR/$filename;

fi
if $ENABLE_SECTION_REF; then

    # Create section-ref files
    echo "Creating section-ref XMLs for article $articleID";


    query="
	select
		Section.sectionID,
	    ifnull(ArticleMetaContent.source, 'nwt_ece4') as source,
	    ifnull(ArticleMetaContent.sourceIDStr, ArticleMetaContent.articleID) as sourceIDStr,
	    if(
	    	/* set ece_frontpage to ece_varmland */
	   		Section.uniquename = 'ece_frontpage',
	   		'ece_varmland',
			if(
		    	/* merge ece_karlskoga and ece_degerfors into ece_karlskoga-degerfors */
				Section.uniquename = 'ece_karlskoga' or Section.uniquename = 'ece_degerfors',
				'ece_karlskoga-degerfors',
				Section.uniquename
			)
		) as uniquename,
		if(ArticleSection.priority, 'true', 'false') as priority
	from
	    ArticleMetaContent, ArticleSection, Section
	where
		ArticleSection.sectionID = Section.sectionID and
		Section.uniquename not in ('ece_all', 'ece_right_inner', 'ece_right_outer', 'ece_right_inner_val_2014') and
	    ArticleSection.articleID = ArticleMetaContent.articleID and
	    ArticleMetaContent.articleID = $articleID
    "


    while read line
	do
	    row=($line)
	    sectionID=${row[0]}
	    sourceStr=${row[1]}
	    sourceIDStr=${row[2]}
	    uniquename=${row[3]}
	    priority=${row[4]}

	    filename="section-ref_$priority-$articleID-$sectionID.xml"

    	echo "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>" > $OUT_DIR/$filename;
    	echo "<escenic xmlns=\"http://xmlns.escenic.com/2009/import\" version=\"2.0\">" >> $OUT_DIR/$filename;

		echo "<content source=\"$sourceStr\" sourceid=\"$sourceIDStr\">" >> $OUT_DIR/$filename;
		# map sektions should be transformed to field "marker". I e ece_brott to <value>brott</value>
		if [[ "$uniquename" == "ece_brott" || "$uniquename" == "ece_lasarnyhet" || "$uniquename" == "ece_olycka" || "$uniquename" == "ece_politik" || "$uniquename" == "ece_ovrigt" ]]; then
			echo "<field name=\"MARKER\"><value>${uniquename:4}</value></field>" >> $OUT_DIR/$filename;
		else
		    echo "<section-ref unique-name=\"$uniquename\" home-section=\"$priority\"/>" >> $OUT_DIR/$filename;
		fi
	    echo "</content>" >> $OUT_DIR/$filename;
	    echo "</escenic>" >> $OUT_DIR/$filename;
	done < <($MYSQL_CMD -e "${query}")

fi
if $ENABLE_CREATOR_AUTHOR; then

    # Create creator and author files

    echo "Creating creator and author XMLs for article $articleID";

    query="
	select
		PersonArticleType.codeText persontype,
		replace(substring_index(url, ',ou=', 1), 'cn=', '') as username,
	    ifnull(ArticleMetaContent.source, 'nwt_ece4') as source,
	    ifnull(ArticleMetaContent.sourceIDStr, ArticleMetaContent.articleID) as sourceIDStr
	from
		ArticleMetaContent, ReferenceEntity, PersonArticleRole, PersonArticleType
	where
		ReferenceEntity.referenceID = PersonArticleRole.referenceID and
		PersonArticleType.codeID = PersonArticleRole.codeID and
		PersonArticleType.codeText in ('creator', 'author') and
	    PersonArticleRole.articleID = ArticleMetaContent.articleID and
	    ArticleMetaContent.articleID = $articleID
	"

    while read line
		do
	    row=($line)
	    persontype=${row[0]}
	    username=${row[1]}
	    sourceStr=${row[2]}
	    sourceIDStr=${row[3]}

	    filename="$persontype-$articleID-$username.xml"

    	echo "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>" > $OUT_DIR/$filename;
    	echo "<escenic xmlns=\"http://xmlns.escenic.com/2009/import\" version=\"2.0\">" >> $OUT_DIR/$filename;
		echo "<content source=\"$sourceStr\" sourceid=\"$sourceIDStr\">" >> $OUT_DIR/$filename;
		if [[ "$persontype" == "creator" ]]; then
			echo "<creator usernname=\"$username\"/>" >> $OUT_DIR/$filename;
		else
		    echo "<author username=\"$username\"/>" >> $OUT_DIR/$filename;
		fi
	    echo "</content>" >> $OUT_DIR/$filename;
	    echo "</escenic>" >> $OUT_DIR/$filename;

	done < <($MYSQL_CMD -e "${query}")

fi
if $ENABLE_RELATION; then

    # Create relation files

    echo "Creating relation XMLs for article $articleID";

	query="
	select
		upper(RelationType.codeText),
		ArticleRelation.Art_articleID,
    ifnull(amc.source, 'nwt_ece4') as source,
	  ifnull(amc.sourceIDStr, amc.articleID) as sourceIDStr,
    ifnull(amc2.source, 'nwt_ece4') as source2,
	  ifnull(amc2.sourceIDStr, amc2.articleID) as sourceIDStr2
	from
		ArticleRelation, ArticleMetaContent amc, ArticleMetaContent amc2, RelationType
	where
		amc.articleID = ArticleRelation.articleID and
		amc2.articleID = ArticleRelation.Art_articleID and
		RelationType.codeID = ArticleRelation.codeID and
		ArticleRelation.articleID = $articleID
	"

    while read line
		do
	    row=($line)
	    relationBox=${row[0]}
	    relationArticleID=${row[1]}
	    sourceStr=${row[2]}
	    sourceIDStr=${row[3]}
	    relationSourceStr=${row[4]}
	    relationSourceIDStr=${row[5]}

	    filename="relation-$articleID-$relationArticleID.xml"

    	echo "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>" > $OUT_DIR/$filename;
    	echo "<escenic xmlns=\"http://xmlns.escenic.com/2009/import\" version=\"2.0\">" >> $OUT_DIR/$filename;
			echo "<content source=\"$sourceStr\" sourceid=\"$sourceIDStr\">" >> $OUT_DIR/$filename;
			echo "<relation type=\"$relationBox\" source=\"$relationSourceStr\" sourceid=\"$relationSourceIDStr\"/>" >> $OUT_DIR/$filename;
	    echo "</content>" >> $OUT_DIR/$filename;
	    echo "</escenic>" >> $OUT_DIR/$filename;

	done < <($MYSQL_CMD -e "${query}")

fi

done < <($MYSQL_CMD -e "${artid_query}")





