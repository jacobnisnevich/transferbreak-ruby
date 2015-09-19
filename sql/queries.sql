SELECT * FROM transferbreak_teams;
SELECT * FROM transferbreak_players;
SELECT * FROM transferbreak_leagues;

SELECT * FROM transferbreak_articles;
SELECT * FROM transferbreak_player_mentions;
SELECT * FROM transferbreak_team_mentions;

SELECT * FROM transferbreak_player_synonyms;
SELECT * FROM transferbreak_team_synonyms;

SELECT * FROM transferbreak_articles ORDER BY DATE DESC;
SELECT * FROM transferbreak_articles WHERE id="888f07135372155fdb19fc729106ee215bedac648a0e41140231a4e445b5be95";
SELECT * FROM transferbreak_articles WHERE source='Tribal Football' AND `date` > "2015-09-17 23:04:18";

SELECT m.*, a.link FROM transferbreak_player_mentions AS m, transferbreak_articles AS a WHERE a.id = m.article_id;
SELECT m.*, a.link FROM transferbreak_team_mentions AS m, transferbreak_articles AS a WHERE a.id = m.article_id;

SELECT * FROM transferbreak_rumors;
