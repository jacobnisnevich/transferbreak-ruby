app.controller("LoginController", ["$scope", "$mdDialog", function($scope, $mdDialog) {
	$scope.loggedIn = false;
	$scope.accountText = "Log In";
	$scope.beLoggedIn = function() {
		$scope.loggedIn = true;
		$scope.accountText = "Account Settings"
	};
	$scope.beLoggedOut = function() {
		$scope.loggedIn = false;
		$scope.accountText = "Log In";
	};
	$scope.openAccountDialog = function(event) {
		if ($scope.loggedIn) {
			$scope.openAccountSettingsDialog(event);
		} else {
			$scope.openLoginDialog(event)
		}
	};
	$scope.openLoginDialog = function(event) {
		$mdDialog.show({
			controller: LoginDialogController,
			templateUrl: "js/templates/login.tmpl.html",
			parent: angular.element(document.body),
			targetEvent: event,
			clickOutsideToClose: true
		}).then(function(user) {
			if (user.newAccount) {
				$mdDialog.show({
					controller: NewAccountDialogController,
					templateUrl: "js/templates/create-account.tmpl.html",
					parent: angular.element(document.body),
					targetEvent: event,
					clickOutsideToClose: true
				}).then(function() {
					$scope.beLoggedIn();
				});
			} else {
				$scope.beLoggedIn();
			}
		});
	};
	$scope.openAccountSettingsDialog = function(event) {

	};
}]);