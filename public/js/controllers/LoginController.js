app.controller("LoginController", ["$scope", "$mdDialog", "$http", "$rootScope", function($scope, $mdDialog, $http, $rootScope) {
	$scope.loggedIn = false;
	$scope.accountText = "Log In";
	$scope.loggedInUser = "";

	$scope.beLoggedIn = function(username) {
		$scope.loggedIn = true;
		$scope.accountText = "Account Settings"
		$scope.loggedInUser = username;

		$http.post("/getUserPreferences", {
			username: $scope.loggedInUser
		}).then(function(response) {
			$rootScope.$broadcast("updateContent", {
				"twitterPrefs": response.data.twitter,
				"newsPrefs": response.data.news
			});
		}, function(response) {
			console.log("Failed to load user preferences");
		});
	};

	$scope.beLoggedOut = function() {
		$scope.loggedIn = false;
		$scope.accountText = "Log In";
		$scope.loggedInUser = "";
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
				}).then(function(user) {
					$scope.beLoggedIn(user.username);
				});
			} else {
				$scope.beLoggedIn(user.username);
			}
		});
	};

	$scope.openAccountSettingsDialog = function(event) {
		$http.post("/getUserPreferences", {
			username: $scope.loggedInUser
		}).then(function(response) {
			$mdDialog.show({
				controller: AccountDialogController,
				templateUrl: "js/templates/account.tmpl.html",
				parent: angular.element(document.body),
				targetEvent: event,
				clickOutsideToClose: true,
				locals: {
					"twitterPrefs": response.data.twitter,
					"newsPrefs": response.data.news
				}
			}).then(function(user) {
				$http.post("/updateUserPreferences", {
					"twitterPrefs": user.newTwitterPrefs,
					"newsPrefs": user.newNewsPrefs
				}).then(function(response) {
					$rootScope.$broadcast("updateContent", {
						"twitterPrefs": user.newTwitterPrefs,
						"newsPrefs": user.newNewsPrefs
					});
				}, function(response) {
					console.log("Error updating user preferences");
				});
			});
		}, function(response) {
			console.log("Failed to load user preferences");
		});
	};
}]);