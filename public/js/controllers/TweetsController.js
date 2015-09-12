app.controller("TweetsController", ["$scope", "$http", "$interval", function($scope, $http, $interval) {
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

	$scope.tweets = [];
	$scope.tweetsBuffer = [];

	$scope.tweetsLoaded = false;
	$scope.stopInterval;

	$scope.periodicallyCheckForTweets = function(seconds) {
		stopInterval = $interval($scope.checkForNewTweets, seconds * 1000);
	};

	$scope.stopUpdateLoop = function() {
		if (angular.isDefined($scope.stopInterval)) {
			$interval.cancel($scope.stopInterval);
			$scope.stopInterval = undefined;
		}
	};

	$scope.loadBufferedTweets = function() {
		$scope.tweetsBuffer.reverse().forEach(function(newTweet) {
			$scope.tweets.unshift(newTweet);
		});

		$scope.tweetsBuffer = [];
	};

	$scope.checkForNewTweets = function() {
		$http.post("/getNewTweets", {
			"twitterUsers": $scope.twitterSources,
			"newestDate": $scope.tweets[0].date
		}).then(function(response) {
			$scope.tweetsBuffer = response.data;
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
		$scope.stopUpdateLoop();
		$scope.periodicallyCheckForTweets(15);
	});

	$scope.$on("updateContent", function(event, data) {
		$scope.tweetsLoaded = false;
		$scope.twitterSources = data.twitterPrefs;
		$scope.loadTweets();
		$scope.stopUpdateLoop();
		$scope.periodicallyCheckForTweets(15);
	});
}]);