var app = angular.module("TransferBreak", ["ngMaterial", "ngIdle"]);

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

app.run(function($rootScope) {
	$rootScope.$on("IdleStart", function() {
		console.log("You will be logged out in 60s if you remain idle...")
	});
	$rootScope.$on("IdleTimeout", function() {
		$rootScope.$broadcast("userTimeout");
	});
});