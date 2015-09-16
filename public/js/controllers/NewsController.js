app.controller("NewsController", ["$scope", "$rootScope", "$http", "$interval", function($scope, $rootScope, $http, $interval) {
	$scope.newsSources = [
		"Tribal Football"
	];

	$scope.genericNewsSources = [
		"Tribal Football"
	];

	$scope.articles = [];
	$scope.articlesBuffer = [];

	$scope.newsLoaded = false;
	$scope.stopInterval;

	$scope.periodicallyCheckForNews = function(seconds) {
		$scope.stopInterval = $interval($scope.checkForNewNews, seconds * 1000);
	};

	$scope.stopUpdateLoop = function() {
		if (angular.isDefined($scope.stopInterval)) {
			$interval.cancel($scope.stopInterval);
			$scope.stopInterval = undefined;
		}
	};

	$scope.loadBufferedNews = function() {
		$scope.articlesBuffer.forEach(function(newArticle) {
			$scope.articles.unshift(newArticle);
		});

		$scope.articlesBuffer = [];
	};

	$scope.checkForNewNews = function() {
		$http.post("/getNewNews", {
			"newsSources": $scope.newsSources,
			"newestDate": $scope.articles[0].date
		}).then(function(response) {
			$scope.articlesBuffer = response.data;
		}, function(response) {
			console.log("Failed to retrieve new articles.");
		});
	};

	$scope.loadNews = function() {
		$http.post("/getNewsFeed", {
			"newsSources": $scope.newsSources
		}).then(function(response) {
			$scope.articles = response.data;
			$scope.newsLoaded = true;
		}, function(response) {
			console.log("Error loading news.");
		});
	};

	$scope.loadArticle = function(link) {
		$http.post("/getSpecificArticle", {
			"link": link
		}).then(function(response) {
			$rootScope.$broadcast("articleDataLoaded", response.data);
		}, function(response){
			console.log("Failed to look up article at: " + link);
		});
	};

	$scope.loadArticleByID = function(id) {
		$http.post("/getSpecificArticleByID", {
			"id": id
		}).then(function(response) {
			$rootScope.$broadcast("articleDataLoaded", response.data);
		}, function(response){
			console.log("Failed to look up article at: " + id);
		});
	};

	$scope.toJsDate = function(str) {
		if(!str) return null;
		return new Date(str);
	}

	$scope.removeSpaces = function(str) {
		return str.replace(/\s/g, '').toLowerCase();
	}

	$scope.$on("initGenericNews", function(event) {
		$scope.newsLoaded = false;
		$scope.newsSources = $scope.genericNewsSources;
		$scope.loadNews();
		$scope.stopUpdateLoop();
		$scope.periodicallyCheckForNews(60);
	});

	$scope.$on("updateContent", function(event, data) {
		$scope.newsLoaded = false;
		$scope.newsSources = data.newsPrefs;
		$scope.loadNews();
		$scope.stopUpdateLoop();
		$scope.periodicallyCheckForNews(60);
	});

	$scope.$on("goToArticle", function(event, data) {
		$scope.loadArticleByID(data.id);
	});
}]);