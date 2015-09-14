SELECT * FROM transferbreak_user_preferences;
SELECT * FROM transferbreak_users;
SELECT * FROM transferbreak_teams;

SELECT COUNT(NAME) FROM transferbreak_players;
SELECT COUNT(NAME) FROM transferbreak_player_synonyms;
SELECT COUNT(team) FROM transferbreak_teams;
SELECT COUNT(NAME) FROM transferbreak_team_synonyms;

SELECT * FROM transferbreak_articles;
SELECT * FROM transferbreak_player_mentions;
SELECT DISTINCT * FROM transferbreak_team_mentions;

SELECT * FROM transferbreak_player_synonyms;
SELECT * FROM transferbreak_team_synonyms;

SELECT DATE FROM transferbreak_articles ORDER BY DATE;

SELECT m.*, a.link FROM transferbreak_player_mentions AS m, transferbreak_articles AS a WHERE a.id = m.article_id;
SELECT m.*, a.link FROM transferbreak_team_mentions AS m, transferbreak_articles AS a WHERE a.id = m.article_id;

SELECT twitter_preferences, news_preferences FROM transferbreak_user_preferences WHERE username="jacob.nisnevich";
UPDATE transferbreak_user_preferences SET twitter_preferences="", news_preferences="" WHERE username="jacob.nisnevich";

SELECT * FROM transfer


DELETE FROM transferbreak_articles;
DELETE FROM transferbreak_player_mentions;
DELETE FROM transferbreak_team_mentions;