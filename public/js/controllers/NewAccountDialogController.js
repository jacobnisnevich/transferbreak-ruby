function NewAccountDialogController($scope, $mdDialog, $mdToast, $http) {
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
	$scope.submit = function(email, username, password, passwordConfirm) {
		var validateResult = $scope.validate(email, username, password, passwordConfirm);

		if (validateResult.valid) {
			$http.post('/createAccount', {
				"email": email,
				"username": username, 
				"password": password
			}).then(function(response) {
				$mdDialog.hide({
					"username": username
				});
			}, function(response) {
				$scope.showStatus(response);
			});
		} else {
			$scope.showStatus(validateResult.message);
		}
	};
	$scope.validate = function(email, username, password, passwordConfirm) {
		var validateObject = {
			"valid": true,
			"message": ""
		};

		if (!validateEmail(email)) {
			validateObject.valid = false;
			validateObject.message = "Email is not a valid email";
		}

		if (password !== passwordConfirm) {
			validateObject.valid = false;
			validateObject.message = "Passwords do not match";
		}

		return validateObject;
	};
	$scope.showStatus = function(message) {
		$mdToast.show(
			$mdToast.simple().content(message).position($scope.getToastPosition()).hideDelay(3000)
		);
	};
}

function validateEmail(email) {
    var re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;
    return re.test(email);
}