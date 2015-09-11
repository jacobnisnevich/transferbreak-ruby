app.controller("SearchController", ["$scope", "$http", "$rootScope", function($scope, $http, $rootScope) {
	$scope.playerNameEntry = "";

	$scope.resultsLoaded = true;
	$scope.results = [];

	$scope.lookUpPlayer = function() {
		if ($scope.playerNameEntry.length > 1) {			
			$scope.resultsLoaded = false;
			$http.post("/lookUpPlayer", {
				"query": $scope.playerNameEntry
			}).then(function(response) {
				$scope.resultsLoaded = true;
				$scope.results = response.data;
			}, function(response){
				console.log("Failed to look up player: " + $scope.playerNameEntry);
			});
		}
	};

	$scope.loadPlayer = function(name, team) {
		$http.post("/getSpecificPlayer", {
			"name": name,
			"team": team
		}).then(function(response) {
			$rootScope.$broadcast("playerDataLoaded", response.data);
		}, function(response){
			console.log("Failed to look up player: " + name);
		});
	}
}]);