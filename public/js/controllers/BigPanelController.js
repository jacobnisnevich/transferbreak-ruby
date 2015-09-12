app.controller("BigPanelController", ["$scope", function($scope) {
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

	$scope.toJsDate = function(str) {
		if(!str) return null;
		return new Date(str);
	}
}]);