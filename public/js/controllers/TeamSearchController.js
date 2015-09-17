app.controller("TeamSearchController", ["$scope", "$http", "$rootScope", function($scope, $http, $rootScope) {
	$scope.teamNameEntry = "";

	$scope.resultsLoaded = true;
	$scope.results = [];

	$scope.lookUpTeam = function() {
		if ($scope.teamNameEntry.length > 1) {			
			$scope.resultsLoaded = false;
			$http.post("/lookUpTeam", {
				"query": $scope.teamNameEntry
			}).then(function(response) {
				$scope.resultsLoaded = true;
				$scope.results = response.data;
			}, function(response){
				console.log("Failed to look up player: " + $scope.teamNameEntry);
			});
		}
	};

	$scope.loadTeam = function(team) {
		$http.post("/getSpecificTeam", {
			"team": team
		}).then(function(response) {
			$rootScope.$broadcast("teamDataLoaded", response.data);
		}, function(response){
			console.log("Failed to look up player: " + name);
		});
	};

	$scope.$on("goToTeamProfile", function(event, data) {
		$scope.loadTeam(data.team);
		$scope.teamNameEntry = data.team;
		$scope.lookUpTeam();
	});
}]);