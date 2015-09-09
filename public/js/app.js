var app = angular.module("TransferBreak", ["ngMaterial"])
  	.config(function($mdThemingProvider) {
	$mdThemingProvider.theme('default')
			.primaryPalette('blue')
			.accentPalette('light-blue');	
});