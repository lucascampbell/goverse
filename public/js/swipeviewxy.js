/*!
 * SwipeView v0.10 ~ Copyright (c) 2011 Matteo Spinelli, http://cubiq.org
 * Released under MIT license, http://cubiq.org/license
 */

var SwipeView = (function(){
	var hasTouch = 'ontouchstart' in window,
		resizeEvent = 'onorientationchange' in window ? 'orientationchange' : 'resize',
		startEvent = hasTouch ? 'touchstart' : 'mousedown',
		moveEvent = hasTouch ? 'touchmove' : 'mousemove',
		endEvent = hasTouch ? 'touchend' : 'mouseup',
		cancelEvent = hasTouch ? 'touchcancel' : 'mouseup',

		SwipeView = function (el, options) {
			var i,
				div,
				className,
				pageIndex,
				lastEvent;

			this.wrapper = typeof el == 'string' ? document.querySelector(el) : el;
			this.options = {
				text: null,
				numberOfPages: 3,
				numberOfPhotos: 3,
				snapThreshold: null,
				hastyPageFlip: false,
				loop: true
			};
		
			// User defined options
			for (i in options) this.options[i] = options[i];
			this.wrapper.style.overflow = 'hidden';
			this.wrapper.style.position = 'relative';
			
			this.masterPages = [];
			this.masterPages2 = [];
			

			div = document.createElement('div');
			div.id = 'swipeview-slider2';
			div.style.cssText = 'z-index:-1;position:absolute;top:0;height:100%;width:100%;-webkit-transition-duration:0;-webkit-transform:translate3d(0,0,0);-webkit-transition-timing-function:ease-out';
			this.wrapper.appendChild(div);
			this.slider2 = div;
			
			div = document.createElement('div');
			div.id = 'swipeview-slider';
			div.style.cssText = 'text-align:left;position:absolute;top:0;height:100%;width:100%;-webkit-transition-duration:0;-webkit-transform:translate3d(0,0,0);-webkit-transition-timing-function:ease-out';
			this.wrapper.appendChild(div);
			this.slider = div;
			
			this.refreshSize();

			for (i=-1; i<2; i++) {
				div = document.createElement('div');
				div.id = 'swipeview-masterpage-' + (i+1);
				div.style.cssText = '-webkit-transform:translateZ(0);position:absolute;top:0;height:100%;width:100%;left:' + i*100 + '%';
				if (!div.dataset) div.dataset = {};
				pageIndex = i == -1 ? this.options.numberOfPages - 1 : i;
				div.dataset.pageIndex = pageIndex;
				div.dataset.upcomingPageIndex = pageIndex;
				
				if (!this.options.loop && i == -1) div.style.visibility = 'hidden';

				this.slider.appendChild(div);
				this.masterPages.push(div);
			}
			
			for (i=-1; i<2; i++) {
				div = document.createElement('div');
				div.id = 'swipeview-masterpage2-' + (i+1);
				div.style.cssText = '-webkit-transform:translateZ(0);position:absolute;top:0;height:100%;width:100%;top:' + i*100 + '%';
				if (!div.dataset) div.dataset = {};
				pageIndex = i == -1 ? this.options.numberOfPhotos - 1 : i;
				div.dataset.pageIndex = pageIndex;
				div.dataset.upcomingPageIndex = pageIndex;
				
				if (!this.options.loop && i == -1) div.style.visibility = 'hidden';

				this.slider2.appendChild(div);
				this.masterPages2.push(div);
			}
			
			className = this.masterPages[1].className;
			this.masterPages[1].className = !className ? 'swipeview-active' : className + ' swipeview-active';
			className = this.masterPages2[1].className;
			this.masterPages2[1].className = !className ? 'swipeview-active' : className + ' swipeview-active';

			
			
			window.addEventListener(resizeEvent, this, false);
			this.wrapper.addEventListener(startEvent, this, false);
			this.wrapper.addEventListener(moveEvent, this, false);
			this.wrapper.addEventListener(endEvent, this, false);
			this.slider.addEventListener('webkitTransitionEnd', this, false);
			this.slider2.addEventListener('webkitTransitionEnd', this, false);

/*			if (!hasTouch) {
				this.wrapper.addEventListener('mouseout', this, false);
			}*/
		};
	
	SwipeView.prototype = {
		currentMasterPage: 1,
		currentMasterPage2: 1,
		direction: 0,
		x: 0,
		y: 0,
		page: 0,
		pageIndex: 0,
		customEvents: [],
		
		onFlip: function (fn) {
			this.wrapper.addEventListener('swipeview-flip', fn, false);
			this.customEvents.push(['flip', fn]);
		},
		onFlipY: function (fn) {
			this.wrapper.addEventListener('swipeview-flipY', fn, false);
			this.customEvents.push(['flipY', fn]);
		},
		onMoveOut: function (fn) {
			this.wrapper.addEventListener('swipeview-moveout', fn, false);
			this.customEvents.push(['moveout', fn]);
		},

		onMoveIn: function (fn) {
			this.wrapper.addEventListener('swipeview-movein', fn, false);
			this.customEvents.push(['movein', fn]);
		},
		
		onTouchStart: function (fn) {
			this.wrapper.addEventListener('swipeview-touchstart', fn, false);
			this.customEvents.push(['touchstart', fn]);
		},

		destroy: function () {
			var i, l;
			for (i=0, l=this.customEvents.length; i<l; i++) {
				this.wrapper.removeEventListener('swipeview-' + this.customEvents[i][0], this.customEvents[i][1], false);
			}
			
			this.customEvents = [];
			
			// Remove the event listeners
			window.removeEventListener(resizeEvent, this, false);
			this.wrapper.removeEventListener(startEvent, this, false);
			this.wrapper.removeEventListener(moveEvent, this, false);
			this.wrapper.removeEventListener(endEvent, this, false);
			this.slider.removeEventListener('webkitTransitionEnd', this, false);
			this.slider2.removeEventListener('webkitTransitionEnd', this, false);

/*			if (!hasTouch) {
				this.wrapper.removeEventListener('mouseout', this, false);
			}*/
		},
		

		refreshSize: function () {
			this.wrapperWidth = this.wrapper.clientWidth;
			this.wrapperHeight = this.wrapper.clientHeight;
			this.pageWidth = this.wrapperWidth;
			this.pageHeight = this.wrapperHeight;
			this.maxX = -this.options.numberOfPages * this.pageWidth + this.wrapperWidth;
			this.maxY = -this.options.numberOfPhotos * this.pageHeight + this.wrapperHeight;
			this.snapThreshold = this.options.snapThreshold === null ?
				Math.round(this.pageWidth * 0.15) :
				/%/.test(this.options.snapThreshold) ?
					Math.round(this.pageWidth * this.options.snapThreshold.replace('%', '') / 100) :
					this.options.snapThreshold;
			this.snapThresholdY = this.options.snapThreshold === null ?
				Math.round(this.pageHeight * 0.15) :
				/%/.test(this.options.snapThreshold) ?
					Math.round(this.pageHeight * this.options.snapThreshold.replace('%', '') / 100) :
					this.options.snapThreshold;
		},
							

		handleEvent: function (e) {
			switch (e.type) {
				case startEvent:
					lastStartEvent = e.timeStamp;
					this.__start(e);
					break;
				case moveEvent:
					this.__move(e);
					break;
				case cancelEvent:
				case endEvent:
					//if (e.timeStamp-lastStartEvent < 100) {
					//	showMenu(e);
					//	}
						this.__end(e);
						
					break;
				case resizeEvent:
					this.__resize();
					break;
				case 'webkitTransitionEnd':
					if (e.target == this.slider && !this.options.hastyPageFlip) this.__flip();
					if (e.target == this.slider2 && !this.options.hastyPageFlip) this.__flipY();
					break;
			}
		},


		/**
		*
		* Pseudo private methods
		*
		*/
		__pos: function (x) {
			this.x = x;
			this.slider.style.webkitTransform = 'translate3d(' + x + 'px,0,0)';
		},
		__posY: function (y) {
			this.y = y;
			this.slider2.style.webkitTransform = 'translate3d(0,' + y + 'px,0)';
		},

		__resize: function () {
			window.location.href = '/app/Quote/{' + this.masterPages[this.currentMasterPage].firstChild.id + ',' + this.masterPages2[this.currentMasterPage2].firstChild.id + '}/show_by_id';
		//	this.refreshSize();
		//	this.slider.style.webkitTransitionDuration = '0';
		//	this.__pos(-this.page * this.pageWidth);
		//	carousel.masterPages2[0].firstChild.style.height = $('#wrapper').height() + 'px';
		//	carousel.masterPages2[0].firstChild.style.width = $('#wrapper').width() + 'px';
		//	carousel.masterPages2[1].firstChild.style.height = $('#wrapper').height() + 'px';
		//	carousel.masterPages2[1].firstChild.style.width = $('#wrapper').width() + 'px';
		//	carousel.masterPages2[2].firstChild.style.height = $('#wrapper').height() + 'px';
		//	carousel.masterPages2[2].firstChild.style.width = $('#wrapper').width() + 'px';
		//	resetMenu();
		},

		__start: function (e) {
			//e.preventDefault();

			if (this.initiated) return;
			
			var point = hasTouch ? e.touches[0] : e;
			
			this.initiated = true;
			this.moved = false;
			this.thresholdExceeded = false;
			this.startX = point.pageX;
			this.startY = point.pageY;
			this.pointX = point.pageX;
			this.pointY = point.pageY;
			this.stepsX = 0;
			this.stepsY = 0;
			this.directionX = 0;
			this.directionY = 0;
			this.directionLocked = false;
			
/*			var matrix = getComputedStyle(this.slider, null).webkitTransform.replace(/[^0-9-.,]/g, '').split(',');
			this.x = matrix[4] * 1;*/

			this.slider.style.webkitTransitionDuration = '0';
			this.slider2.style.webkitTransitionDuration = '0';
			
			this.__event('touchstart');
		},
		
		__move: function (e) {
			if (!this.initiated) return;

			var point = hasTouch ? e.touches[0] : e,
				deltaX = point.pageX - this.pointX,
				deltaY = point.pageY - this.pointY,
				newX = this.x + deltaX,
				newY = this.y + deltaY,
				dist = Math.abs(point.pageX - this.startX),
				distY = Math.abs(point.pageY - this.startY);
				
			this.moved = true;
			this.pointX = point.pageX;
			this.pointY = point.pageY;
			this.directionX = deltaX > 0 ? 1 : deltaX < 0 ? -1 : 0;
			this.directionY = deltaY > 0 ? 1 : deltaY < 0 ? -1 : 0;
			this.stepsX += Math.abs(deltaX);
			this.stepsY += Math.abs(deltaY);

			// We take a 10px buffer to figure out the direction of the swipe
			if (this.stepsX < 10 && this.stepsY < 10) {
//				e.preventDefault();
				return;
			}
		



			this.directionLocked = true;
			e.preventDefault();

			if (!this.options.loop && (newX > 0 || newX < this.maxX)) {
				newX = this.x + (deltaX / 2);
			}
			
			if (!this.options.loop && (newY > 0 || newY < this.maxY)) {
				newY = this.y + (deltaY / 2);
			}

			if (!this.thresholdExceeded && dist >= this.snapThreshold) {
				this.thresholdExceeded = true;
				this.__event('moveout');
			} else if (this.thresholdExceeded && dist < this.snapThreshold) {
				this.thresholdExceeded = false;
				this.__event('movein');
			}
			if (!this.thresholdExceeded && distY >= this.snapThresholdY) {
				this.thresholdExceeded = true;
				this.__event('moveout');
			} else if (this.thresholdExceeded && distY < this.snapThresholdY) {
				this.thresholdExceeded = false;
				this.__event('movein');
			}
			
/*			if (newX > 0 || newX < this.maxX) {
				newX = this.x + (deltaX / 2);
			}*/
			if (this.stepsY > this.stepsX) {
				this.direction = 1;
				this.__posY(newY);
				
			}else{
				this.direction = 0;
				this.__pos(newX);
			}
				
			
		},
		
		__end: function (e) {
			if (!this.initiated) return;
			var point = hasTouch ? e.changedTouches[0] : e,
				dist = Math.abs(point.pageX - this.startX);
				distY = Math.abs(point.pageY - this.startY);
				
			this.initiated = false;
			
			if (!this.moved) return;

			if (!this.options.loop && (this.x > 0 || this.x < this.maxX)) {
				dist = 0;
				this.__event('movein');
			}
			if (!this.options.loop && (this.y > 0 || this.y < this.maxY)) {
				distY = 0;
				this.__event('movein');
			}

			// Check if we exceeded the snap threshold
			if (this.direction === 0 && dist < this.snapThreshold) {
				//this.slider.style.webkitTransitionDuration = '300ms';
				this.slider.style.webkitTransitionDuration = Math.floor(300 * dist / this.snapThreshold) + 'ms';
				this.__pos(-this.page * this.pageWidth);
				return;
			}
			if (this.direction == 1 && distY < this.snapThresholdY) {
				this.slider2.style.webkitTransitionDuration = Math.floor(300 * dist / this.snapThresholdY) + 'ms';
				//this.slider2.style.webkitTransitionDuration = '300ms';
				this.__posY(-this.page * this.pageHeight);
				return;
			}
            if (this.direction === 0){
			this.__checkPosition();
            }
            if (this.direction == 1){
			this.__checkPositionY();
            }
		},
		
		__checkPosition: function () {
			var pageFlip,
				pageFlipIndex,
				className;
				this.masterPages[this.currentMasterPage].className = this.masterPages[this.currentMasterPage].className.replace(/(^|\s)swipeview-active(\s|$)/, '');
	
			// Flip the page
			if (this.directionX > 0) {
				this.page = -Math.ceil(this.x / this.pageWidth);
				this.currentMasterPage = (this.page + 1) - Math.floor((this.page + 1) / 3) * 3;
				this.pageIndex = this.pageIndex === 0 ? this.options.numberOfPages - 1 : this.pageIndex - 1;

				pageFlip = this.currentMasterPage - 1;
				pageFlip = pageFlip < 0 ? 2 : pageFlip;
				this.masterPages[pageFlip].style.left = this.page * 100 - 100 + '%';

				pageFlipIndex = this.page - 1;
			} else {
				this.page = -Math.floor(this.x / this.pageWidth);
				this.currentMasterPage = (this.page + 1) - Math.floor((this.page + 1) / 3) * 3;
				this.pageIndex = this.pageIndex == this.options.numberOfPages - 1 ? 0 : this.pageIndex + 1;

				pageFlip = this.currentMasterPage + 1;
				pageFlip = pageFlip > 2 ? 0 : pageFlip;
				this.masterPages[pageFlip].style.left = this.page * 100 + 100 + '%';

				pageFlipIndex = this.page + 1;
			}

			// Add active class to current page
			className = this.masterPages[this.currentMasterPage].className;
			/(^|\s)swipeview-active(\s|$)/.test(className) || (this.masterPages[this.currentMasterPage].className = !className ? 'swipeview-active' : className + ' swipeview-active');

			// Add loading class to flipped page
			className = this.masterPages[pageFlip].className;
			/(^|\s)swipeview-loading(\s|$)/.test(className) || (this.masterPages[pageFlip].className = !className ? 'swipeview-loading' : className + ' swipeview-loading');
			
			pageFlipIndex = pageFlipIndex - Math.floor(pageFlipIndex / this.options.numberOfPages) * this.options.numberOfPages;
			this.masterPages[pageFlip].dataset.upcomingPageIndex = pageFlipIndex;		// Index to be loaded in the newly flipped page

			this.slider.style.webkitTransitionDuration = '500ms';
			
			newX = -this.page * this.pageWidth;

			// Hide the next page if we decided to disable looping
			if (!this.options.loop) {
				this.masterPages[pageFlip].style.visibility = newX === 0 || newX == this.maxX ? 'hidden' : '';
			}

			if (this.x == newX) {
				this.__flip();		// If we swiped all the way long to the next page (extremely rare but still)
			} else {
				this.__pos(newX);
				if (this.options.hastyPageFlip) this.__flip();
			}
	
		},
		
		__checkPositionY: function () {
			var pageFlip,
				pageFlipIndex,
				className;

			this.masterPages2[this.currentMasterPage2].className = this.masterPages2[this.currentMasterPage2].className.replace(/(^|\s)swipeview-active(\s|$)/, '');

			// Flip the page
			if (this.directionY > 0) {
				this.page = -Math.ceil(this.y / this.pageHeight);
				this.currentMasterPage2 = (this.page + 1) - Math.floor((this.page + 1) / 3) * 3;
				this.pageIndex = this.pageIndex === 0 ? this.options.numberOfPhotos - 1 : this.pageIndex - 1;

				pageFlip = this.currentMasterPage2 - 1;
				pageFlip = pageFlip < 0 ? 2 : pageFlip;
				this.masterPages2[pageFlip].style.top = this.page * 100 - 100 + '%';

				pageFlipIndex = this.page - 1;
			} else {
				this.page = -Math.floor(this.y / this.pageHeight);
				this.currentMasterPage2 = (this.page + 1) - Math.floor((this.page + 1) / 3) * 3;
				this.pageIndex = this.pageIndex == this.options.numberOfPhotos - 1 ? 0 : this.pageIndex + 1;

				pageFlip = this.currentMasterPage2 + 1;
				pageFlip = pageFlip > 2 ? 0 : pageFlip;
				this.masterPages2[pageFlip].style.top = this.page * 100 + 100 + '%';

				pageFlipIndex = this.page + 1;
			}

			// Add active class to current page
			className = this.masterPages2[this.currentMasterPage2].className;
			/(^|\s)swipeview-active(\s|$)/.test(className) || (this.masterPages2[this.currentMasterPage2].className = !className ? 'swipeview-active' : className + ' swipeview-active');

			// Add loading class to flipped page
			className = this.masterPages2[pageFlip].className;
			/(^|\s)swipeview-loading(\s|$)/.test(className) || (this.masterPages2[pageFlip].className = !className ? 'swipeview-loading' : className + ' swipeview-loading');
			
			pageFlipIndex = pageFlipIndex - Math.floor(pageFlipIndex / this.options.numberOfPhotos) * this.options.numberOfPhotos;
			this.masterPages2[pageFlip].dataset.upcomingPageIndex = pageFlipIndex;		// Index to be loaded in the newly flipped page

			this.slider2.style.webkitTransitionDuration = '500ms';
			
			newY = -this.page * this.pageHeight;

			// Hide the next page if we decided to disable looping
			if (!this.options.loop) {
				this.masterPages2[pageFlip].style.visibility = newY === 0 || newY == this.maxY ? 'hidden' : '';
			}

			if (this.y == newY) {
				this.__flipY();		// If we swiped all the way long to the next page (extremely rare but still)
			} else {
				this.__posY(newY);
				if (this.options.hastyPageFlip) this.__flipY();
			}
		},
		
		__flip: function () {
			this.__event('flip');

			for (var i=0; i<3; i++) {
				this.masterPages[i].className = this.masterPages[i].className.replace(/(^|\s)swipeview-loading(\s|$)/, '');		// Remove the loading class
				this.masterPages[i].dataset.pageIndex = this.masterPages[i].dataset.upcomingPageIndex;
			}
		},
		__flipY: function () {
			this.__event('flipY');

			for (var i=0; i<3; i++) {
				this.masterPages2[i].className = this.masterPages2[i].className.replace(/(^|\s)swipeview-loading(\s|$)/, '');		// Remove the loading class
				this.masterPages2[i].dataset.pageIndex = this.masterPages2[i].dataset.upcomingPageIndex;
			}
		},
		
		__event: function (type) {
			var ev = document.createEvent("Event");
			
			ev.initEvent('swipeview-' + type, true, true);

			this.wrapper.dispatchEvent(ev);
		}
	};

	return SwipeView;
})();