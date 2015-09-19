function LoginDialogController($scope, $mdDialog, $mdToast, $http) {
	var last = {
		bottom: false,
		top: true,
		left: false,
		right: true
	};
	$scope.toastPosition = angular.extend({}, last);
	$scope.getToastPosition = function() {
		sanitizePosition();
		return Object.keys($scope.toastPosition)
			.filter(function(pos) { return $scope.toastPosition[pos]; })
			.join(" ");
	};
	function sanitizePosition() {
		var current = $scope.toastPosition;
		if ( current.bottom && last.top ) current.top = false;
		if ( current.top && last.bottom ) current.bottom = false;
		if ( current.right && last.left ) current.left = false;
		if ( current.left && last.right ) current.right = false;
		last = angular.extend({},current);
	};
	$scope.cancel = function() {
		$mdDialog.cancel();
	};
	$scope.newAccount = function() {
		$mdDialog.hide({
			"newAccount": true
		});
	}
	$scope.submit = function(username, password) {
		$http.post('/validateLogin', {
			"username": username, 
			"password": password
		}).then(function(response) {
			if (response.data.valid) {
				$mdDialog.hide({
					"username": username
				});
			} else {
				$scope.showStatus("Your username or password is not valid.");
			}
		}, function(response) {
			$scope.showStatus(response);
		});
	};
	$scope.showStatus = function(message) {
		$mdToast.show(
			$mdToast.simple().content(message).position($scope.getToastPosition()).hideDelay(3000)
		);
	};
}