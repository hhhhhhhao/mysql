use yuedu;

/*
 1.when user admin1 read an article from his/her collection, which font will be used? 
 
 fontFamily	fontSize	userId
 siyuan	null	1
 */
select
    fontFamily,
    fontSize,
    design.userId
from
    design
    inner join user on design.userId = user.userId
where
    user.userName = 'admin';

/*
 2.The user admin1 have 5-minutes to read, which articals do you recommend to admin1 to read? Suppose one can read 250 words per minute.
 
 articleId	title
 1	永不过站的人
 4	花坞
 9	雨
 18	把白的说成白的
 62	到老屋去
 */
select
    articleId,
    title
from
    article
where
    CHAR_LENGTH(content) < 250 * 5;

/*
 3.The developer wants a string describing the books admin collects.
 
 admin is reading天才梦,花坞,背日,一个人要像一支队伍,永不过站的人
 */
select
    concat('admin is reading', group_concat(title))
from
    article
where
    articleId in (
        select
            articleId
        from
            collection
        where
            userId in (
                select
                    userId
                from
                    user
                where
                    userName = 'admin'
            )
    );

/*
 4.The system now has a new rule that the users must have a different password from each other. So, who should we inform to tell them to change the password?
 
 userId	userName
 1	admin
 2	admin1
 3	admin2
 4	admin3
 5	admin4
 6	admin5
 7	admin6
 8	admin7
 9	admin8
 10	admin9
 */
select
    userId,
    userName
from
    user
where
    passWord in (
        select
            passWord
        from
            user
        group by
            passWord
        having
            count(*) > 1
    );

/*
 5.How many articleTypes in article?
 
 userId	userName
 articleType	count(*)
 outside	20
 inside	12
 */
select
    articleType,
    count(*)
from
    article
group by
    articleType;

/*
 6.Do users like font siyuan than font fangsong? Which font do users prefer?
 
 fangsong
 34
 */
create procedure WHICHFONT(out Which varchar(10)) begin declare totalTeacher int default 0;

select
    count(*) as siyuan
from
    design
where
    fontFamily = "siyuan";

select
    count(*) as fangsong
from
    design
where
    fontFamily = "fangsong";

if siyuan > fangsong then
set
    Which = "siyuan";

else
set
    Which = "fangsong";

end if;

end;

call WHICHFONT(@Which);

select
    @Which;

/*
 7.Which article does the first user like?
 
 articleId
 11
 */
select
    articleId
from
    collection A
where
    exists(
        select
            userId
        from
            user
        where
            signIntime =(
                select
                    min(signIntime)
                from
                    user
            )
            and A.userId = userId
    );

/*
 8.which artcle did the user 62 comment and what he/she said? Select top 5.
 
 content	title
 GOOD!	永不过站的人
 GOOD!	背日
 GOOD!	《红处方》后记
 GOOD!	花坞
 GOOD!	镜中人
 */
select
    comment.content,
    title
from
    comment
    inner join article on comment.userId = comment.userId
where
    userId = 62
limit
    5;

/*
 9. When the users click likes, the system should collect this article.
 
 fieldCount	affectedRows	insertId	serverStatus	warningCount	message	protocol41	changedRows
 0	0	0	10	0		true	0
 0	3	0	34	0	(Rows matched: 3 Changed: 3 Warnings: 0	true	3
 */
drop trigger beforeupdate create trigger beforeupdate
after
update
    on comment for each row begin
insert into
    collection (collectionid, userId, articleId)
values
    (floor(rand() * 100), new.userId, new.articleId);

end;

update
    comment
set
    likes = likes + 1
where
    articleId = 6
    and userId = 1;

SELECT
    *
FROM
    information_schema.`TRIGGERS`
where
    TRIGGER_SCHEMA = 'yuedu';

/*
 10. Select the cover of book by its name.
 
 @bookPhoto
 aa
 */
drop function picture;

create procedure picture(
    in bookTitle varchar(50),
    out bookPhoto varchar(20)
) begin
select
    title into bookPhoto
from
    recommend
where
    title = bookTitle;

end;

call picture('aa', @bookPhoto);

select
    @bookPhoto;

/*
 11. Get the url of the book with book name. If the book is not in the database, return the 'null'.
 
 getPictureUrl('aa')
 www.a.com/a.pic
 */
drop function getPictureUrl;

create function getPictureUrl(param1 varchar(20)) returns varchar(100) deterministic begin declare pictureUrl varchar(20);

declare bookName varchar(20);

select
    link into pictureUrl
from
    recommend
where
    title = param1;

select
    bookPhoto into bookName
from
    recommend
where
    title = param1;

if pictureUrl is null then return 'null';

end if;

return concat(pictureUrl, "/", bookName);

end;

select
    getPictureUrl('aa');

/*
 12. Create a view to get article whose articleId is below 10.
 
 author	title	wordNumber	preview
 饭饭	永不过站的人	899	null
 落落	背日	15221	null
 毕淑敏	《红处方》后记	1831	null
 郁达夫	花坞	595	null
 杨绛	镜中人	2396	null
 张爱玲	天才梦	1352	null
 冯骥才	灵魂的巢	1242	null
 郁达夫	花坞	1367	null
 郁达夫	雨	520	null
 铁凝	火锅子	1387	null
 */
drop view readCollection;

create view readCollection(author, title, wordNumber, preview) as
select
    author,
    title,
    wordNumber,
    preview
from
    article
where
    articleId <= 10;

with check option;

select
    *
from
    readCollection;