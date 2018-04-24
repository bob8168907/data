CREATE TABLE fulltext_sample(copy TEXT,FULLTEXT(copy))TYPE=MYISAM;
INSERT INTO fulltext_sample VALUES
('It appears good from here'),
('The here and the past'),
('Why are we hear'),
('An all-out alert'),
('All you need is love'),
('A good alert');
SELECT * FROM fulltext_sample
SELECT * FROM fulltext_sample WHERE MATCH(copy) AGAINST('here'); 
SELECT * FROM fulltext_sample WHERE MATCH(copy) AGAINST('lov');
SELECT * FROM fulltext_sample WHERE MATCH(copy) AGAINST('good,alert');

SELECT copy,MATCH(copy) AGAINST('good,alert') AS relevance
FROM fulltext_sample WHERE MATCH(copy) AGAINST('good,alert');

SELECT * FROM `ad` WHERE CONCAT(`ad_content`,`ad_id`,`ad_flack`,`ad_prod`) LIKE '%110%'

  这里的table需要是MyISAM类型的表，col1、col2 必须是char、varchar或text类型，在查询之前需要在 col1 和 col2 上分别建立全文索引(FULLTEXT索引)。
  自然语言检索： IN NATURAL LANGUAGE MODE
  布尔检索： IN BOOLEAN MODE



  DELETE
FROM
    opt
WHERE
    opt.id in
 (
	 select a.id from 
	( select id from opt where
	 leadid IN (
        SELECT
            leadid
        FROM
            opt
        GROUP BY
            leadid
        HAVING
            count(leadid) > 1
    )
	AND id NOT IN (
    SELECT
        min(id)
    FROM
        opt
    GROUP BY
        leadid
    HAVING
        count(leadid) > 1
	)
	and leadid !=0) a
 );

 删除重复数据