// ==UserScript==
// @name           cz - My Tickets Mods
// @namespace      cz
// @description    Hide Empty Queues, collapse MyOnHold, expand Customer column
// @version        2.2.1
// @include        https://gravity.corp.neospire.net/*
// @require        http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js
// ==/UserScript==

var now = new Date().getTime();
var tickerCacheTime = 1000 * 86400 * 8; // 8 days

// { custId: {t: ticker, e: expires_getTime} }
var tickerCache = {};
// { custId: [td1, td2, .. tdN] }
var tickerLoading = {length: 0};

function loadTickerCache() {
	var tmp = GM_getValue('cache_ticker', '{}');
	eval ('tickerCache = ' + tmp);
	if (tickerCache == undefined) {
		tickerCache = {};
	}
	$.each(tickerCache, function(i) {
		if (now > this.e) {
			delete tickerCache[i];
		}
	});
}

function saveTickerCache() {
	// I don't know how expensive GM_setValue() is, but I like to minimize calling it
	if (tickerLoading.length == 0) GM_setValue('cache_ticker', tickerCache.toSource());
}

function getTicker(custId, cell) {
	// parseInt() just as a method of preventing hax0r requests
	custId = parseInt(custId);
	if (tickerCache[custId]) return tickerCache[custId].t;
	if (tickerLoading[custId]) {
		tickerLoading[custId].push(cell);
		return 0;
	}
	tickerLoading.length++;
	tickerLoading[custId] = [cell];
	$.get('/customers.viewCustomer?customerId=' + custId, function(data) {
		/* damn stack overflow on the NeoSpire page...  Bummer
		var t = $('th:contains(Ticker:)', data).parent().find('td div').text().replace(/^\s+|\s+$/g, '');
		*/
		var t = data.replace(/\n/g, '').replace(/\s+/g, ' ').match(/<th style="text-align: left;" valign='top'>Ticker:<\/th> <td > <div >\s*(\S+)\s*<\/div>/)
		if (t && t[1] && t[1].length > 0 && (t = t[1].replace('&nbsp;', '')) && t.length > 0) {
			tickerCache[custId] = {
				t: t,
				e: now + tickerCacheTime,
			};
			$.each(tickerLoading[custId], function() {
				$(this).text(tickerCache[custId].t);
			});
		} else {
			tickerCache[custId] = {
				t: '',
				e: now + Math.floor(tickerCacheTime / 4),
			};
		}
		delete tickerLoading[custId];
		tickerLoading.length--;
		saveTickerCache();
	});
	return 0;
}

function scrubEmptyQueues() {
    $('h2').filter(function() {
		return $(this).text().match(/^0 .+? Tickets /);
	}).parent().parent().remove();
}

function hideMyOnHoldQueue() {
	$('#MyOnHoldTicketsHidden').css('display', 'inline');
	$('#MyOnHoldTicketsShown').css('display', 'none');
}

function scrubExtraBRs() {
	$('*:not(td) > br').remove();
}

function useCustomerTickers() {
	$('body').append('<div id="cust_tip" style="background-color: #ffffe1; z-index: 9999; position: absolute; display: none; text-align: left; font-size: 14px; border: 1px solid #000000; padding: 3px;"></div>');
	// shorten customer names if necessary (until a ticker is available)
	$('a[href*=customers.viewCustomer?customerId=]').each(function() {
		var custId = $(this).attr('href').match(/customerId=(\d+)/)[1];
		var ticker = getTicker(custId, this);
		var oldText = $(this).text();
		$(this).text(ticker || $(this).text().replace(' - ' + custId, '').replace(custId + ' - ', '').replace(/,? *(?:corp|inc|l\.?l\.?c|l\.?p|l\.?t\.?d)\b\.?/gi, ''));
		if ($(this).text().length > 30)
			$(this).text($(this).text().replace(/[ ]/gi, ''));
		if ($(this).text().length > 30)
			$(this).text($(this).text().slice(0, 16) + '...' + $(this).text().slice(-11));
		$(this).hover(function() {
			$('#cust_tip').text(oldText).css({
				'left': $(this).offset().left + 5,
				'top': $(this).offset().top - 24,
			}).show();
		}, function() {
			$('#cust_tip').hide();
		});
	});
}

function modifyCells() {
	var maxMinutes = 120;
	var LASTEDITED = /Last Edited/;
	$('table.sortable').each(function(t, table) {
		var custIdx = -1;
		var editIdx = -1;
		$(this).find('th').each(function(i) {
			if ($(this).text() === 'Customer') {
				custIdx = i;
			} else if ($(this).text().match(LASTEDITED)) {
				editIdx = i;
			}
		});
		if (custIdx === -1 && editIdx === -1) return true;
		// color-code last-edit column
		$(this).find('tr').slice(1).find('td:eq(' + editIdx + ')').each(function(i) {
//			console.log('i = ' + i + '; text = ' + $(this).text());
			var s = $(this).text().match(/0*(\d+)\/0*(\d+)\/0*(\d+) 0*(\d+):0*(\d+)/); // yuck! whatever...
			if (!s) return true;
//			console.log(s.map(function(a) { return a + ' (' + parseInt(a) + ')';}));
			var when = new Date();
			when.setFullYear(parseInt(s[3]) + 2000);
			when.setMonth(parseInt(s[1]) - 1);
			when.setDate(parseInt(s[2]));
			when.setHours(parseInt(s[4]));
			when.setMinutes(parseInt(s[5]));
			when.setSeconds(0);
			var minDiff = parseFloat((now - when.getTime()) / 60000);
//			if (minDiff > maxMinutes) minDiff = maxMinutes;
			var red = 255 - parseInt(minDiff * 2);
			var bgColor = 'rgb(255, ' + red + ', ' + red + ')';
			$(this).css('background-color', bgColor).find('div > div').css({
				'background-color': bgColor,
				'color': bgColor,
			})
		});
	});
}

function fixSeniorNotes() {
	var i = 0;
	$('th:contains(Senior Notes:)').parent().find('td').each(function() {
		$(this).prepend('(<a id="show_senior_notes" href="javascript:;">show all</a>)');
		$('#show_senior_notes').click(function() {
			$(this).parent().find('span').show();
		});
	}).find('span').each(function() {
		var id = 'senior_notes_' + i++;
		this.id = id;
		$(this).prepend('<div>(<a id="hide_' + id + '" href="javascript:;">hide</a>)</div>');
		$('#hide_' + id).click(function(i) {
			$('#' + id).slideToggle('slow');
		});
	});
}

function reMarkup() {
	$('table.defaulttable thead, table.sortable thead, div.sdmenu div span').css('color', '#ffffff');
}

loadTickerCache();

var thisUrl = window.location.href;
if (thisUrl.match(/tickets\.myTickets/)) {
	scrubEmptyQueues();
	hideMyOnHoldQueue();
	modifyCells();
	scrubExtraBRs();
}
if (thisUrl.match(/tickets\.(?:view|edit)Ticket/)) {
	fixSeniorNotes();
}
useCustomerTickers();
reMarkup();

