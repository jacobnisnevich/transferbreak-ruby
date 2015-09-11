app.controller("BigPanelController", ["$scope", function($scope) {
	$scope.playerData = {};
	$scope.playerLoaded = false;

	$scope.$on("playerDataLoaded", function(event, data) {
		$scope.playerData = data;
		$scope.playerLoaded = true;
	});
}]);