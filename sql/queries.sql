SELECT * FROM transferbreak_user_preferences;
SELECT * FROM transferbreak_users;
SELECT * FROM transferbreak_teams;

SELECT COUNT(NAME) FROM transferbreak_players;

DELETE FROM transferbreak_articles;
DELETE FROM transferbreak_player_mentions;
DELETE FROM transferbreak_team_mentions;

SELECT * FROM transferbreak_articles;
SELECT * FROM transferbreak_player_mentions;
SELECT * FROM transferbreak_team_mentions;

SELECT m.*, a.link FROM transferbreak_player_mentions AS m, transferbreak_articles AS a WHERE a.id = m.article_id;

SELECT twitter_preferences, news_preferences FROM transferbreak_user_preferences WHERE username="jacob.nisnevich";
UPDATE transferbreak_user_preferences SET twitter_preferences="", news_preferences="" WHERE username="jacob.nisnevich";
