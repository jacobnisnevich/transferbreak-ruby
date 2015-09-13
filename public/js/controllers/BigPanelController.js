app.controller("BigPanelController", ["$scope", "$compile", "$rootScope", function($scope, $compile, $rootScope) {
	// Twitter View

	$scope.twitterData = {};
	$scope.twitterLoaded = false;

	$scope.$on("tweetDataLoaded", function(event, data) {
		$scope.twitterData = data;
		$scope.twitterLoaded = true;
	});

	// Player View

	$scope.playerData = {};
	$scope.playerLoaded = false;

	$scope.$on("playerDataLoaded", function(event, data) {
		$scope.playerData = data;
		$scope.playerLoaded = true;
	});

	// Article View

	$scope.articleData = {};
	$scope.articleLoaded = false;

	$scope.$on("articleDataLoaded", function(event, data) {
		$scope.articleData = data;
		$scope.articleLoaded = true;
	});

	$scope.goToPlayerProfile = function(name) {
		$rootScope.$broadcast("goToPlayerProfile", {
			"name": name
		});
	};

	$scope.toJsDate = function(str) {
		if(!str) return null;
		return new Date(str);
	};

	$scope.getLargeURL = function(str) {
		return str.replace("_normal", "");
	};
}]);