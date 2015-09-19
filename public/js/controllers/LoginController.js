app.controller("LoginController", ["$scope", "$mdDialog", "$http", "$rootScope", function($scope, $mdDialog, $http, $rootScope) {
	$scope.loggedIn = false;
	$scope.loggedInUser = "";

	$scope.beLoggedIn = function(username) {
		$scope.loggedIn = true;
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
		$scope.loggedInUser = "";
		$http.get("/userLogout").then(function(response) {
			console.log(response.data + " has logged out");
		}, function(response) {
			console.log("Failed to log out user");
		});
		$rootScope.$broadcast("initGenericTweets");
		$rootScope.$broadcast("initGenericNews");
	};

	$scope.$on("userTimeout", function() {
		$scope.beLoggedOut();
	});

	$scope.$on("initTB", function() {
		$http.get("/getLoggedInUser").then(function(response) {
			if (response.data.loggedIn) {
				$scope.beLoggedIn(response.data.user)
			} else {
				$rootScope.$broadcast("initGenericTweets");
			}
		}, function(response) {
			console.log("Failed to retrieve logged in user");
		});
	});

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