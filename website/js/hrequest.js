// copyright (c) Henry de Jongh http://00laboratories.com/
$(function () {

	hrequest = {
		database: {},
		html: {},
		winamp: {},
		
		sections: $('#sections'),
		songs: $('#songs'),
		requests: $('#requests'),
		searchsections: $('#search-sections'),
		searchsongs: $('#search-songs'),
		
		latestUpdateInfo: undefined,
		lastSongId: -1,
		lastSongRating: 0,
		requestsId: -1
	};

	////////////////////////////////////////////////////////////////////////////////////////////////
	// DATABASE
	////////////////////////////////////////////////////////////////////////////////////////////////

	// Adds a song to the list of requests.
	hrequest.database.addRequestAjax = function(songId, callback) {
		$.get({url: '/database.addRequest/' + songId + '/', cache: false}, function (data) {
			callback(data);
		}, 'json').fail(function (e) {
			callback();
		});
	};
	
	hrequest.database.addRequest = function(songId) {
		var l = Ladda.create($('#song-'+songId+'-request').get(0));
		l.start();
		
		hrequest.database.addRequestAjax(songId, function (data) {
			l.stop();
			if (data == undefined) return;
			// do something.
		});
	}
	
	// Retrieves a list of all sections.
	hrequest.database.getSections = function(callback) {
		$.get({url: '/database.getSections/', cache: false}, '', function (data) {
			callback(data);
		}, 'json').fail(function (e) {
			callback();
		});
	};
	
	// Retrieves a list of all songs in a section.
	hrequest.database.getSongs = function(sectionId, callback) {
		$.get({url: '/database.getSongs/' + sectionId + '/', cache: false}, '', function (data) {
			callback(data);
		}, 'json').fail(function (e) {
			callback();
		});
	};
	
	// Sets a rating for a song.
	hrequest.database.setRatingAjax = function(songId, rating, callback) {
		$.get({url: '/database.setRating/' + songId + '/' + rating + '/', cache: false}, '', function (data) {
			callback(data);
		}, 'json').fail(function (e) {
			callback();
		});
	};
	
	hrequest.database.setRating = function(songId, rating, isPlaying) {
		var l = Ladda.create($('#'+(isPlaying?'rating-playing':'rating-'+songId)).get(0));
		l.start();
		
		hrequest.database.setRatingAjax((isPlaying?hrequest.latestUpdateInfo.songId:songId), rating, function (data) {
			l.stop();
			if (data == undefined) return;
			hrequest.html.updateRating(songId, rating, isPlaying);
		})
	};
	
	hrequest.database.openSection = function (sectionId) {
		// start loading icon
		var l = Ladda.create($('#section-' + sectionId).get(0));
		l.start();
		
		// swipe old songs to the left.
		$('#songs').css({'left':'0px'}).animate({'left':'-100%','opacity':'0'}, 200, 'linear', function() {
			// clear the old songs.
			hrequest.html.clearSongs();
			
			// get new songs if possible.
			hrequest.database.getSongs(sectionId, function (data) {
				l.stop();
				if (data == undefined) return;
				if (data.length == 0) return;

				// on success, display them.
				data.forEach(function (song) {
					hrequest.html.addSong(song.id, song.name, song.rating);
				});
				hrequest.forceRepaintOnMobile(hrequest.songs);
				
				// swipe new content into view.
				$('#songs').css({'left':'100%'}).animate({'left':'0px','opacity':'1'}, 200, 'linear');
			});
		});
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////
	// WINAMP
	////////////////////////////////////////////////////////////////////////////////////////////////
	hrequest.winamp.previous = function (callback) {
		$.get({url: '/winamp.previous/', cache: false}, '', function (data) {
			callback(true);
		}, 'json').fail(function (e) {
			callback(false);
		});
	}
	
	hrequest.winamp.play = function (callback) {
		$.get({url: '/winamp.play/', cache: false}, '', function (data) {
			callback(true);
		}, 'json').fail(function (e) {
			callback(false);
		});
	}
	
	hrequest.winamp.pause = function (callback) {
		$.get({url: '/winamp.pause/', cache: false}, '', function (data) {
			callback(true);
		}, 'json').fail(function (e) {
			callback(false);
		});
	}
	
	hrequest.winamp.stop = function (callback) {
		$.get({url: '/winamp.stop/', cache: false}, '', function (data) {
			callback(true);
		}, 'json').fail(function (e) {
			callback(false);
		});
	}
	
	hrequest.winamp.next = function (callback) {
		$.get({url: '/winamp.next/', cache: false}, '', function (data) {
			callback(true);
		}, 'json').fail(function (e) {
			callback(false);
		});
	}
	////////////////////////////////////////////////////////////////////////////////////////////////
	// HTML
	////////////////////////////////////////////////////////////////////////////////////////////////

	hrequest.html.addSection = function (sectionId, name) {
		var html = '<a href="javascript:hrequest.database.openSection(' + sectionId + ')"><div class="hr-section hvr-underline-reveal ladda-button" data-style="expand-left" id="section-' + sectionId + '">' + name;
		hrequest.sections.append(html + '</div></a>');
	};
	
	hrequest.html.clearSections = function () {
		hrequest.sections.html('');
	};
	
	hrequest.html.getSection = function (sectionId) {
		return $('#section-' + sectionId);
	}
	
	hrequest.html.hasSection = function (sectionId) {
		return $('#section-' + sectionId).length > 0;
	}
	
	hrequest.html.clearSongs = function () {
		hrequest.songs.html('');
	};
	
	hrequest.html.addSong = function (songId, name, rating) {
		var star1 = (rating > 0 ? 'gold' : 'silver');
		var star2 = (rating > 1 ? 'gold' : 'silver');
		var star3 = (rating > 2 ? 'gold' : 'silver');
		var star4 = (rating > 3 ? 'gold' : 'silver');
		var star5 = (rating > 4 ? 'gold' : 'silver');
		var html = '<div class="hr-song hvr-underline-reveal"><a id="song-'+songId+'-request" href="javascript:hrequest.database.addRequest('+songId+')" class="name ladda-button" data-style="expand-left">'+name+'</a><div class="rating ladda-button" data-style="expand-left" id="rating-'+songId+'"><a href="javascript:hrequest.database.setRating('+songId+',1,false)"><div class="star star-'+star1+'" id="song-'+songId+'-rating-1"></div></a><a href="javascript:hrequest.database.setRating('+songId+',2,false)"><div class="star star-'+star2+'" id="song-'+songId+'-rating-2"></div></a><a href="javascript:hrequest.database.setRating('+songId+',3,false)"><div class="star star-'+star3+'" id="song-'+songId+'-rating-3"></div></a><a href="javascript:hrequest.database.setRating('+songId+',4,false)"><div class="star star-'+star4+'" id="song-'+songId+'-rating-4"></div></a><a href="javascript:hrequest.database.setRating('+songId+',5,false)"><div class="star star-'+star5+'" id="song-'+songId+'-rating-5"></div></a></div></div>';
		hrequest.songs.append(html + '</div></a>');
	};
	
	hrequest.html.searchSections = function (name) {
		$('#sections div').each(function () {
			if($(this).text().toLowerCase().indexOf(name.toLowerCase()) > -1) {
				$(this).show();
			} else {
				$(this).hide();
			}
		});
	}
	
	hrequest.html.searchSongs = function (name) {
		$('#songs').children().each(function () {
			if($(this).text().toLowerCase().indexOf(name.toLowerCase()) > -1) {
				$(this).show();
			} else {
				$(this).hide();
			}
		});
	}
	
	hrequest.html.nextSong = function (songId, name, rating, sectionName) {
		$('#hr-playing-content').css({'left':'0px'}).animate({'left':'-100%','opacity':'0'}, 1000, 'linear', function() {
			$('#hr-playing-section').text(sectionName);
			$('#hr-playing-title').text(name);
			var star1 = (rating > 0 ? 'gold' : 'silver');
			var star2 = (rating > 1 ? 'gold' : 'silver');
			var star3 = (rating > 2 ? 'gold' : 'silver');
			var star4 = (rating > 3 ? 'gold' : 'silver');
			var star5 = (rating > 4 ? 'gold' : 'silver');
			$('#playing-rating-1').removeClass('star-gold').removeClass('star-silver').addClass('star-'+star1);
			$('#playing-rating-2').removeClass('star-gold').removeClass('star-silver').addClass('star-'+star2);
			$('#playing-rating-3').removeClass('star-gold').removeClass('star-silver').addClass('star-'+star3);
			$('#playing-rating-4').removeClass('star-gold').removeClass('star-silver').addClass('star-'+star4);
			$('#playing-rating-5').removeClass('star-gold').removeClass('star-silver').addClass('star-'+star5);
			$(this).css({'left':'100%'}).animate({'left':'0px','opacity':'1'}, 1000, 'linear');
		});
	}
	
	hrequest.html.updateRating = function (songId, rating, isPlaying) {
		var star1 = (rating > 0 ? 'gold' : 'silver');
		var star2 = (rating > 1 ? 'gold' : 'silver');
		var star3 = (rating > 2 ? 'gold' : 'silver');
		var star4 = (rating > 3 ? 'gold' : 'silver');
		var star5 = (rating > 4 ? 'gold' : 'silver');
		// update isPlaying but also in case the same song was changed in an open song list.
		if (isPlaying || hrequest.latestUpdateInfo.songId == songId) {
			$('#playing-rating-1').removeClass('star-gold').removeClass('star-silver').addClass('star-'+star1);
			$('#playing-rating-2').removeClass('star-gold').removeClass('star-silver').addClass('star-'+star2);
			$('#playing-rating-3').removeClass('star-gold').removeClass('star-silver').addClass('star-'+star3);
			$('#playing-rating-4').removeClass('star-gold').removeClass('star-silver').addClass('star-'+star4);
			$('#playing-rating-5').removeClass('star-gold').removeClass('star-silver').addClass('star-'+star5);
		}
		// always update the song regardless of isPlaying as it may be in an open song list.
		$('#song-'+(isPlaying?hrequest.latestUpdateInfo.songId:songId)+'-rating-1').removeClass('star-gold').removeClass('star-silver').addClass('star-'+star1);
		$('#song-'+(isPlaying?hrequest.latestUpdateInfo.songId:songId)+'-rating-2').removeClass('star-gold').removeClass('star-silver').addClass('star-'+star2);
		$('#song-'+(isPlaying?hrequest.latestUpdateInfo.songId:songId)+'-rating-3').removeClass('star-gold').removeClass('star-silver').addClass('star-'+star3);
		$('#song-'+(isPlaying?hrequest.latestUpdateInfo.songId:songId)+'-rating-4').removeClass('star-gold').removeClass('star-silver').addClass('star-'+star4);
		$('#song-'+(isPlaying?hrequest.latestUpdateInfo.songId:songId)+'-rating-5').removeClass('star-gold').removeClass('star-silver').addClass('star-'+star5);
	}
	
	hrequest.html.clearRequests = function () {
		hrequest.requests.html('');
	};
	
	hrequest.html.generateRequests = function (requests) {
		// clear the old songs.
		hrequest.html.clearRequests();
		
		requests.forEach(function (song) {
			hrequest.html.addRequest(song.id, song.name, song.rating);
		});
	}
	
	hrequest.html.addRequest = function (songId, name, rating) {
		var html = '<div class="hr-song hr-request">'+name+'</div>';
		hrequest.requests.append(html);
	};
	
	// attach search textbox events to the search functions.
	hrequest.searchsections.on('input', function() {hrequest.html.searchSections(hrequest.searchsections.val());});
	hrequest.searchsongs.on('input', function() {hrequest.html.searchSongs(hrequest.searchsongs.val());});
	
	////////////////////////////////////////////////////////////////////////////////////////////////
	
	// fix bug that .append() does not work on mobile.
	hrequest.forceRepaintOnMobile = function (obj) {
		//obj.hide();
		//obj.get(0).offsetHeight;
		//obj.show();
		
		var n = document.createTextNode(' ');
		obj.append(n);
		setTimeout(function(){n.parentNode.removeChild(n)}, 0);
		
		//obj.trigger('create');
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////
	// MAIN
	////////////////////////////////////////////////////////////////////////////////////////////////

	hrequest.main = function () {
		
		var callback = function (data) {

			switch(data.task) {
				case 'error':
					break;
					
				// general update with all statistics.
				case 'update':
					hrequest.latestUpdateInfo = data; // store
					var percentage = Math.floor((data.songPosition / data.songLength) * 100);
					$('#hr-song-progress').css('width', percentage + '%');
					// the song has changed.
					if (data.songId != hrequest.lastSongId) {
						hrequest.lastSongId = data.songId;
						hrequest.lastSongRating = data.songRating;
						hrequest.html.nextSong(data.songId, data.songName, data.songRating, data.sectionName);
					// the song has not changed.
					} else {
						// but if the current song rating did change (some other user on the internet).
						if (data.songRating != hrequest.lastSongRating) {
							hrequest.lastSongRating = data.songRating;
							hrequest.html.updateRating(data.songId, data.songRating, true);
						}
					}
					// the requests have changed.
					if (data.requestsId != hrequest.requestsId) {
						hrequest.requestsId = data.requestsId;
						hrequest.html.generateRequests(data.requests);
					}
					break;
			}
			
			setTimeout(hrequest.main, 2000);
		}
		
		$.get({url: '/hrequest.main/', cache: false}, function (data) {
			callback(data[0]);
		}, 'json').fail(function (e) {
			callback({task:'error'});
		});
		
	}
	
	hrequest.main();
	
	// make sure we display the initial sections.
	
	var callback = function (data) {
		// on failure, try again.
		if (data === undefined) { setTimeout(1000, function () {hrequest.database.getSections(callback);}); return; }
		// on success, display them.
		data.forEach(function (section) {
			hrequest.html.addSection(section.id, section.name);
		});
		hrequest.forceRepaintOnMobile(hrequest.sections);
	}
	
	hrequest.database.getSections(callback);
});