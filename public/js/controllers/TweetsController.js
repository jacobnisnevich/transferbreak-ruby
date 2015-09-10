app.controller("TweetsController", ["$scope", "$http", function($scope, $http) {
	$scope.twitterSources = [
		"GuillemBalague", 
		"DiMarzio", 
		"TonyEvansTimes", 
		"OliverKayTimes", 
		"OllieHoltMirror", 
		"HenryWinter"
	];

	$scope.genericTwitterSources = [
		"GuillemBalague", 
		"DiMarzio", 
		"TonyEvansTimes", 
		"OliverKayTimes", 
		"OllieHoltMirror", 
		"HenryWinter"
	];

	$scope.tweets = {};

	$scope.tweetsLoaded = false;

	$scope.checkForNewTweets = function() {
		$http.post("/getNewTweets", {
			"newestDate": $scope.tweets[0].date
		}).then(function(response) {
			response.body.newTweets.forEach(function(newTweet) {
				$scope.tweets.unshift(newTweet);
			});
		}, function(response) {
			console.log("Failed to retrieve new tweets");
		});
	};

	$scope.loadTweets = function() {
		$http.post("/getTwitterFeed", {
			"twitterUsers": $scope.twitterSources
		}).then(function(response) {
			$scope.tweets = response.data;
			$scope.tweetsLoaded = true;
		}, function(response) {
			console.log("Error loading tweets.");
		});
	};

	$scope.toJsDate = function(str){
		if(!str) return null;
		return new Date(str);
	}

	$scope.$on("initGenericTweets", function(event) {
		$scope.tweetsLoaded = false;
		$scope.twitterSources = $scope.genericTwitterSources;
		$scope.loadTweets();
	});

	$scope.$on("updateContent", function(event, data) {
		$scope.tweetsLoaded = false;
		$scope.twitterSources = data.twitterPrefs;
		$scope.loadTweets();
	});
}]);