app.controller("MainController", ["$scope", "$timeout", function($scope, $timeout) {
	$scope.init = function() {
		$timeout(function() {
			$scope.$broadcast("initTB");
		});
	};

	this.fabIsOpen = false;

	this.currentView = "twitter";
	$scope.views = ["twitter", "news", "search"];
}]);