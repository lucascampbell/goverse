//remove blind and setup event handlers for menu
 jQuery(document).ready(function ($) {
   $('#blind').remove();

   var h,w,mw,mh,mvx,mvy;
  
   h = $("#wrapper").height();
   w = $("#wrapper").width();
   
   mw = $("#menu").width();
   mh = $("#menu").height();
   mvx = (w / 2) - (mw / 2);
   mvy = (h / 2) + (mh / 2);
   
   //place menu correctly on screen
   resetMenu();

   //load all photos initially
   	$('#wscroll').load('/app/Quote/ajax_images',{width: w},function(){
		imagesScroll.refresh();
    });
    
   //This is the touchclick event, opens the menu          
   $("#wrapper").click(function(e) { 
     var w,mw, mvx;
     e.preventDefault();
   
     //Google analytics
     _gaq.push(['_trackEvent', 'menu']);
   
     w = $("#wrapper").width();
     mw = $("#menu").width();
     mvx = (w / 2) - (mw / 2);
   
     $("#menu").show();
     $("#header").show();
   
     //If menu visible and background clicked, close menu and repopulate with topics
     if ($('#quotemenucontainer').is(':visible')) {
       $('#quotemenucontainer').hide();
       $('#thelist').load('/app/Quote/ajax_topics',function(){
       myScroll.refresh();
       myScroll.scrollTo(0,0);}); 
     } else {
       //Run transition animation to show menu    
       $("#menu").css('left', mvx + 'px');       
       $("#menu").css('webkitTransitionDuration','500ms');
       $("#menu").css('webkitTransform','translate3d(0,-' + mvy + 'px,0)');               
     } 
   });
  
   //do not close form if user clicks on search bar
   $("#searchform").click(function(e){
     e.stopPropagation();
   })

   //when quotecontainer is show with favorite it block wrapper so we must hide it with favorites if clicked
   $('#quotemenucontainer').click(function(){
	   backtoquote();
   });

   //Buttonclick events
   $("#backtoquote").click(function(e) {
     e.preventDefault();
     _gaq.push(['_trackEvent', 'backtoquote']);
     $("#menu").css('webkitTransitionDuration','500ms');
     $("#menu").css('webkitTransform','translate3d(0,' + mvy + 'px,0)');
   });       
   
   $("#addtofavorites").click(function(e) {
     e.preventDefault();
     $("#header").hide();
     //If already favorite, unset favorite flag
     if (carousel.masterPages[carousel.currentMasterPage].firstChild.className == 'y') {          
       $('#thelist').load('/app/Quote/{' + id() + '}/unset_favorite',function(){
         myScroll.refresh();
         myScroll.scrollTo(0,0);
         $('#quotemenucontainer').show();
       });                              
     }
     else {
         //Set favorite flag
         $('#thelist').load('/app/Quote/{' + id() + ',' + image() + '}/set_favorite',function(){
         	myScroll.refresh();
         	myScroll.scrollTo(0,0);
         	$('#quotemenucontainer').show();
         });       
     }
     $("#menu").css('webkitTransitionDuration','500ms');
     $("#menu").css('webkitTransform','translate3d(0,' + mvy + 'px,0)');
     _gaq.push(['_trackEvent', 'addtofavorites', id(), image()]);       
   });  
   
   $("#showfavorites").click(function(e) {
     e.preventDefault();            
     $("#header").hide();    
     $('#thelist').load('/app/Quote/ajax_favorites',function(resp){
     	myScroll.refresh();
     	myScroll.scrollTo(0,0);
        //only show container if there are favorites to show
        if(resp != "")
     		$('#quotemenucontainer').show();
     });
     _gaq.push(['_trackEvent', 'addtofavorites', id(), image()]);                               
     $("#menu").css('webkitTransitionDuration','500ms');
     $("#menu").css('webkitTransform','translate3d(0,' + mvy + 'px,0)');      
   }); 
   
   $("#shareemail").click(function(e) {
     e.preventDefault();
     _gaq.push(['_trackEvent', 'shareemail', id(), image()]);
     window.location.href = 'mailto:?subject=Inspiration&body=View Quote here http://blazing-day-5340.herokuapp.com/' + id() + '/' + image();   
   });
   
   $("#newsubmit").click(function(e) {
     e.preventDefault();
     _gaq.push(['_trackEvent', 'newsubmit', id(), image()]);
     window.location.href = 'mailto:@gmail.com?subject=New Inspiration&body=Please add my photo / quote to Quotes for even more inspiration.';   
   });
   
   $("#findquote").click(function(e) {
     e.preventDefault();
     $('#search').val('');                                  
     $('#quotemenucontainer').show();  
     myScroll.refresh();
     $("#menu").hide();
     $("#menu").css('webkitTransitionDuration','0ms');
     $("#menu").css('webkitTransform','translate3d(0,' + mvy + 'px,0)');
   });

  $("#choosephoto").click(function(e) {
	 e.preventDefault();
	 _gaq.push(['_trackEvent', 'choosephoto']);
     var w = $("#wrapper").width();
     var h = $("#wrapper").height();
     //Run transition animation to show images    
     $("#menu").hide();
     $('#wcontainer').show();
     $('#wrapper').css('background-color','black');
	 imagesScroll.refresh();
	 imagesScroll.scrollTo(0,0);
     //window.location.href = '/app/Quote/{'+ id() +'}/photos';  
  });      
   
   $("#searchform").submit(function(e){  
     e.preventDefault();
     $('#thelist').load('/app/Quote/search_result',{tag: $('#search').val()},function(){
       myScroll.refresh();
       myScroll.scrollTo(0,0);});        
       $('#search').blur();
     });
   });

function id() {  
  return carousel.masterPages[carousel.currentMasterPage].firstChild.id;  
}
function image() {
  return carousel.masterPages2[carousel.currentMasterPage2].firstChild.id;
}
function currentQuote() {  
  return carousel.masterPages[carousel.currentMasterPage].firstChild;  
}
function currentImage(){
 return	carousel.masterPages2[carousel.currentMasterPage2]
}

function onCompletion () {
	// Here modify the DOM in any way, eg: by adding LIs to the scroller UL

	setTimeout(function () {
		imagesScroll.refresh();
	}, 0);
};

// when favorites is clicked it takes over wrapper div disabling closing event handler
function backtoquote(){
	if ($('#quotemenucontainer').is(':visible')) {
       $('#quotemenucontainer').hide();
       $('#thelist').load('/app/Quote/ajax_topics',function(){
       	 myScroll.refresh();
       	 myScroll.scrollTo(0,0);
	   });
	}
};

function swap_image(img){
	$('#wrapper').css('background-color','');
	el = carousel.masterPages2[carousel.currentMasterPage2].querySelector('img');     
	el.src = "/public/photos/"+img+".jpg";
	el.id = img;
    $('#wcontainer').hide();
    $("#menu").hide();
    $("#menu").css('webkitTransitionDuration','0ms');
    $("#menu").css('webkitTransform','translate3d(0,0px,0)');
	setFavText();
};

function setFavText() {
  var w, mw, mvx;
  if (currentQuote().className == 'y') {    
    $('#favspan').text('Remove from Favorites');
    } else {
    $('#favspan').text('Add to Favorites');
  }
  w = $("#wrapper").width();
  mw = $("#menu").width();
  mvx = (w / 2) - (mw / 2);
  $("#menu").css('left', mvx + 'px');
};

function resetMenu() {
  var h,w,mw,mh,mvx,mvy;
  $("#menu").css('webkitTransitionDuration','0ms');
  h = $("#wrapper").height();
  w = $("#wrapper").width();
  
  mw = $("#menu").width();
  mh = $("#menu").height();
  mvx = (w / 2) - (mw / 2);
  mvy = (h / 2) + (mh / 2);
  
  $("#menu").css('left', mvx + 'px');
  $("#menu").css('top', h + 'px');
}
function switchQuote(that,id) {
  that.style.background = '#aaaaaa';
  $.getJSON('/app/Quote/{'+ id +'}/json') .complete(function(data) {
    slides = jQuery.parseJSON(data.responseText);          
    carousel.options.numberOfPages = slides.length;
    $('#quotemenucontainer').hide();
            
    for (i=0; i<3; i++) {
        page = i==0 ? slides.length-1 : i-1;
        //if (i == carousel.currentMasterPage) { page = 0;}
        el = carousel.masterPages[i].querySelector('span');        
        el.css = "text-align:left;";
        el.innerHTML = slides[page].text;
        el.className = slides[page].favorite;
        el.id = slides[page].id;  
     }
    setFavText();
 });
 
 $('#thelist').load('/app/Quote/ajax_topics',function(){
    myScroll.refresh();
    myScroll.scrollTo(0,0);}); 
}

function switchQuoteImage(that,id,image) {
  that.style.background = '#aaaaaa';
  $.getJSON('/app/Quote/{'+ id +'}/ajax_quote') .complete(function(data) {
    slides = jQuery.parseJSON(data.responseText);          
    carousel.options.numberOfPages = slides.length;
    carousel.masterPages2[carousel.currentMasterPage2].firstChild.src = "/public/photos/" + image + ".jpg";
    $('#quotemenucontainer').hide();
            
    for (i=0; i<3; i++) {
        page = i==0 ? slides.length-1 : 1;
        if (i == carousel.currentMasterPage) { page = 0;}
        el = carousel.masterPages[i].querySelector('span');        
        el.css = "text-align:left;";
        el.innerHTML = slides[page].text;
        el.className = slides[page].favorite;
        el.id = slides[page].id;  
    }
	setFavText();
 });
 
  $('#thelist').load('/app/Quote/ajax_topics',function(){
       myScroll.refresh();
       myScroll.scrollTo(0,0);});               
}
  
  
function switchQuoteImagePush(id,image) {  
  $.getJSON('/app/Quote/{'+ id +'}/json') .complete(function(data) {
    slides = jQuery.parseJSON(data.responseText);          
    carousel.options.numberOfPages = slides.length;
    carousel.masterPages2[carousel.currentMasterPage2].firstChild.src = "/public/photos/" + image + ".jpg";
    $('#quotemenucontainer').hide();
            
    for (i=0; i<3; i++) {
        page = i==0 ? slides.length-1 : i-1;
        //if (i == carousel.currentMasterPage) { page = 0;}
        el = carousel.masterPages[i].querySelector('span');        
        el.css = "text-align:left;";
        el.innerHTML = slides[page].text;
        el.className = slides[page].favorite;
        el.id = slides[page].id;  
    }
	setFavText();
  });
 
  $('#thelist').load('/app/Quote/ajax_topics',function(){
	  myScroll.refresh();
	  myScroll.scrollTo(0,0);});               
}
    
function switchTopic(that,topicId) {
  that.style.background = '#aaaaaa'; 
  $.getJSON('/app/Quote/{'+ topicId +'}/json_by_topic_id') .complete(function(data) {
    slides = jQuery.parseJSON(data.responseText);          
    carousel.options.numberOfPages = slides.length;
    $('#quotemenucontainer').hide();
            
    for (i=0; i<3; i++) {
        page = i==0 ? slides.length-1 : i-1;
        //if (i == carousel.currentMasterPage) { page = 0;}
        el = carousel.masterPages[i].querySelector('span');        
        el.css = "text-align:left;";
        el.innerHTML = slides[page].text;
        el.className = slides[page].favorite;
        el.id = slides[page].id;  
    }
    setFavText();
  });
  
   $('#thelist').load('/app/Quote/ajax_topics',function(){
       myScroll.refresh();
       myScroll.scrollTo(0,0);
   });
}
