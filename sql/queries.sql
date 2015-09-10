SELECT * FROM transferbreak_user_preferences;
SELECT * FROM transferbreak_users;
DELETE FROM transferbreak_user_preferences;
DELETE FROM transferbreak_users;

SELECT twitter_preferences, news_preferences FROM transferbreak_user_preferences WHERE username="jacob.nisnevich";
UPDATE transferbreak_user_preferences SET twitter_preferences="", news_preferences="" WHERE username="jacob.nisnevich";