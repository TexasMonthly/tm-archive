###################################################
# Query list of issues with shell articles
###################################################

SELECT t.slug, STR_TO_DATE(t.slug,"%M-%Y") as date, count(*) FROM `wp_posts` as p, `wp_term_relationships` as tr, `wp_term_taxonomy` as tt, `wp_terms` as t WHERE p.ID = tr.object_id AND tr.term_taxonomy_id = tt.term_taxonomy_id AND tt.term_id = t.term_id AND tt.taxonomy = "emmis-issue" AND p.post_content = "" AND post_type = "post" AND post_status = "publish" GROUP BY t.slug ORDER BY date ASC


# get list of feature stories published without copy

SELECT p.ID, p.post_title as headline, UPPER(REPLACE(tI.slug, '-', ' ')) as issue, STR_TO_DATE(REPLACE(tI.slug, '-', ' 1, '), "%M %e, %Y") as date, tA.name as author, p.guid as link

FROM `wp_posts` as p, `wp_postmeta` as pm,

`wp_term_relationships` as trI, `wp_term_taxonomy` as ttI, `wp_terms` as tI,
`wp_term_relationships` as trF, `wp_term_taxonomy` as ttF, `wp_terms` as tF,
`wp_term_relationships` as trA, `wp_term_taxonomy` as ttA, `wp_terms` as tA

WHERE p.ID = pm.post_id AND

p.ID = trI.object_id AND trI.term_taxonomy_id = ttI.term_taxonomy_id AND ttI.term_id = tI.term_id AND
p.ID = trF.object_id AND trF.term_taxonomy_id = ttF.term_taxonomy_id AND ttF.term_id = tF.term_id AND
p.ID = trA.object_id AND trA.term_taxonomy_id = ttA.term_taxonomy_id AND ttA.term_id = tA.term_id 

AND ttI.taxonomy = "emmis-issue" AND p.post_content = "" AND post_type = "post" AND post_status = "publish"

AND ( pm.meta_value = "Feature" OR tF.slug = "Features" )

AND ttA.taxonomy = "author"

GROUP BY p.ID

ORDER BY date DESC

###################################################
# Query all missing articles (5/24/21)
###################################################

SELECT p.ID, p.post_title as headline, p.post_excerpt as excerpt, p.post_content as content, UPPER(REPLACE(tI.slug, '-', ' ')) as issue, tMS.name as magazine_section, STR_TO_DATE(REPLACE(tI.slug, '-', ' 1, '), "%M %e, %Y") as date, tA.name as author, pmL.meta_value as lede, p.guid as link, CONCAT("https://www.texasmonthly.com/?p=", pmT.meta_value) as thumbnail

FROM `wp_posts` as p 
# issue
LEFT JOIN `wp_term_relationships` as trI ON p.ID = trI.object_id
LEFT JOIN `wp_term_taxonomy` as ttI ON trI.term_taxonomy_id = ttI.term_taxonomy_id
LEFT JOIN `wp_terms` as tI ON ttI.term_id = tI.term_id

# author
LEFT JOIN `wp_term_relationships` as trA ON p.ID = trA.object_id
LEFT JOIN `wp_term_taxonomy` as ttA ON trA.term_taxonomy_id = ttA.term_taxonomy_id
LEFT JOIN `wp_terms` as tA ON ttA.term_id = tA.term_id 

# magazine section
LEFT JOIN `wp_term_relationships` as trMS ON p.ID = trMS.object_id
LEFT JOIN `wp_term_taxonomy` as ttMS ON trMS.term_taxonomy_id = ttMS.term_taxonomy_id
LEFT JOIN `wp_terms` as tMS ON ttMS.term_id = tMS.term_id 

LEFT JOIN `wp_postmeta` as pmL ON ( pmL.post_id = p.ID AND pmL.meta_key = "texas_lede" )
LEFT JOIN `wp_postmeta` as pmT ON ( pmT.post_id = p.ID AND pmT.meta_key = "_thumbnail_id" )

WHERE 

ttI.taxonomy = "emmis-issue" 
AND ttA.taxonomy = "author"
AND ttMS.taxonomy = "emmis-section"

# features
AND (UPPER(tMS.name) LIKE '%FEATURE%' OR UPPER(pmL.meta_value) LIKE '%FEATURE%')

AND ( p.post_content = "" OR CHAR_LENGTH( p.post_content ) < 500 ) AND p.post_type = "post" AND p.post_status = "publish"

GROUP BY p.ID

ORDER BY date DESC

# story = 617673
# author = 5019 (term id = 2754)

###################################################
# Query list of recipes (category only)
###################################################

SELECT p.ID, p.post_title as headline, tA.name as author, p.post_excerpt as excerpt, p.post_date as publish_date, GROUP_CONCAT( DISTINCT tCat.name) as categories, GROUP_CONCAT(tTag.name) as tags, tV.name as vertical, tA.name as author, pmL.meta_value as lede, CONCAT("https://www.texasmonthly.com/?p=", p.ID) as link, CONCAT("https://www.texasmonthly.com/?p=", pmT.meta_value) as thumbnail

FROM `wp_posts` as p 

# recipes
LEFT JOIN `wp_term_relationships` as trRec ON p.ID = trRec.object_id
LEFT JOIN `wp_term_taxonomy` as ttRec ON trRec.term_taxonomy_id = ttRec.term_taxonomy_id
LEFT JOIN `wp_terms` as tRec ON ( ttRec.term_id = tRec.term_id AND ttRec.taxonomy = "category" )


# categories
LEFT JOIN `wp_term_relationships` as trCat ON p.ID = trCat.object_id
LEFT JOIN `wp_term_taxonomy` as ttCat ON trCat.term_taxonomy_id = ttCat.term_taxonomy_id
LEFT JOIN `wp_terms` as tCat ON ( ttCat.term_id = tCat.term_id AND ttCat.taxonomy = "category" )

# tags
LEFT JOIN `wp_term_relationships` as trTag ON p.ID = trTag.object_id
LEFT JOIN `wp_term_taxonomy` as ttTag ON trTag.term_taxonomy_id = ttTag.term_taxonomy_id
LEFT JOIN `wp_terms` as tTag ON ( ttTag.term_id = tTag.term_id AND ttTag.taxonomy = "post_tag" )

# vertical
LEFT JOIN `wp_term_relationships` as trV ON p.ID = trV.object_id
LEFT JOIN `wp_term_taxonomy` as ttV ON trV.term_taxonomy_id = ttV.term_taxonomy_id
LEFT JOIN `wp_terms` as tV ON ttV.term_id = tV.term_id

# author
LEFT JOIN `wp_term_relationships` as trA ON p.ID = trA.object_id
LEFT JOIN `wp_term_taxonomy` as ttA ON trA.term_taxonomy_id = ttA.term_taxonomy_id
LEFT JOIN `wp_terms` as tA ON ttA.term_id = tA.term_id 


LEFT JOIN `wp_postmeta` as pmL ON ( pmL.post_id = p.ID AND pmL.meta_key = "texas_lede" )
LEFT JOIN `wp_postmeta` as pmT ON ( pmT.post_id = p.ID AND pmT.meta_key = "_thumbnail_id" )

WHERE 

tRec.name = "Recipes"
AND ttV.taxonomy = "emmis-blog"
AND ttA.taxonomy = "author"

AND p.post_type = "post" AND p.post_status = "publish"

GROUP BY p.ID

PCD Marketable Actives,TXMO Online UnEntitled - Launch Split,[BC DEV] PCD Account # and PCD Email Address,[Analysis] Paid social visitor and eventual subscriber,Viewed Paywall,[Analysis] Log in attempt, unentitled,[Test] Recent BBQ Visitors,PCD DTP Active Subscribers,[test] Preferred Category,TXMO Online Free Trial Expires,TXMO Online UnEntitled + Split A,Paywall Subscriber Expires,Actively Viewing Paywall,[Analysis] Viewed Paywall, Subscribed,All Online Profiles with Email,Engagement: High,Campaign Monitor: Promotions,[Analysis] Free Trial > Subscription Purchase,PCD All Marketable Accounts with Email,Logged In,Landed through campaign,[dev] Test newsletter elections from subscriber file,[dev] TXMO+PCD Email Segment,Preferred visit hour: Afternoon,Known Visitors,Free Trial Cohort,Campaign Monitor: Events,All Visitors,TXMO Online UnEntitled,WordPress Users,Campaign Monitor: Editorial,Online Subscription Order Conversions,Paywall Converters,[demo] HOTS Campaign
