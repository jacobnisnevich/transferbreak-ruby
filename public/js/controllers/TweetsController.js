app.controller("TweetsController", ["$scope", "$http", function($scope, $http) {
	$scope.twitterSources = [
		"GuillemBalague", 
		"DiMarzio", 
		"TonyEvansTimes", 
		"OliverKayTimes", 
		"OllieHoltMirror", 
		"HenryWinter"
	];

	$scope.tweets = {};

	$scope.tweetsLoaded = false;

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

	$scope.$on("initTB", function(event) {
		$scope.loadTweets();
	});

	$scope.$on("updateContent", function(event, data) {
		$scope.tweetsLoaded = false;
		$scope.twitterSources = data.twitterPrefs;
		$scope.loadTweets();
	});
}]);