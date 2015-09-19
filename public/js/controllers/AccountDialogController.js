function AccountDialogController($scope, $mdDialog, $mdToast, $http, twitterPrefs, newsPrefs) {
	$scope.twitterPrefs = twitterPrefs;
	$scope.newsPrefs = newsPrefs;
	$scope.newsSelection = [
		"The Guardian",
		"Tribal Football",
		"ESPN FC"
	];

	$scope.toggle = function (item, list) {
		var index = list.indexOf(item);

		if (index > -1) {
			list.splice(index, 1);
		} else {
			list.push(item)
		};
	};

	$scope.exists = function (item, list) {
		return list.indexOf(item) > -1;
	};

	$scope.cancel = function() {
		$mdDialog.cancel();
	};

	$scope.submit = function() {
		$mdDialog.hide({
			"newTwitterPrefs": $scope.twitterPrefs,
			"newNewsPrefs": $scope.newsPrefs
		});
	};

	$scope.showStatus = function(message) {
		$mdToast.show(
			$mdToast.simple().content(message).position($scope.getToastPosition()).hideDelay(3000)
		);
	};

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

	function querySearch (query) {
		var results = query ? $scope.newsOptions.filter(createFilterFor(query)) : [];
		return results;
	}
	function createFilterFor(query) {
		var lowercaseQuery = angular.lowercase(query);
		return function filterFn(option) {
			return (option.indexOf(lowercaseQuery) === 0)
		};
    }
}