var app = angular.module("TransferBreak", ["ngMaterial", "ngIdle", "md.data.table"]);

app.config(function($mdThemingProvider, IdleProvider) {
	$mdThemingProvider.theme("default")
		.primaryPalette('blue', {
		'default': '500',
		'hue-1': '400',
		'hue-2': '300',
		'hue-3': '100'
	});
	IdleProvider.idle(5);
	IdleProvider.timeout(5);
});

app.filter('unsafe', function($sce) {
	return function(val) {
		val = val.replace(/goToTeamProfile\(\"(.*)\"\); main.currentView = \"search\"/, "goToTeamProfile(\"$1\"); main.currentView = \"teamSearch\"");
		val = val.replace(/goToPlayerProfile\(\"(.*)\"\); main.currentView = \"search\"/, "goToPlayerProfile(\"$1\"); main.currentView = \"playerSearch\"");
		return $sce.trustAsHtml(val);
	};
});

app.run(function($rootScope) {
	$rootScope.$on("IdleStart", function() {
		console.log("You will be logged out in 60s if you remain idle...")
	});
	$rootScope.$on("IdleTimeout", function() {
		$rootScope.$broadcast("userTimeout");
	});
});

app.directive('dynamic', function ($compile) {
	return {
		restrict: 'A',
		replace: true,
		link: function (scope, ele, attrs) {
			scope.$watch(attrs.dynamic, function(html) {
				ele.html(html);
				$compile(ele.contents())(scope);
			});
		}
	};
});