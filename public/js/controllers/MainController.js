app.controller("MainController", ["$scope", "$timeout", function($scope, $timeout) {
	$scope.init = function() {
		$timeout(function() {
			$scope.$broadcast("initTB");
		});
	};
}]);