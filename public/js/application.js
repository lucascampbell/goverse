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
   tab_w = w/3 - 42;
   $('.btm_item').css('width',tab_w);
   
   if (currentQuote().className == 'y')
	   $('#addtofavorites').css('opacity','1')
	
   //hide nav at bottom until tab
   //$('#bottom_nav').hide();
   resetMenu();
   //try and register device for push if it hasn't been already
   $.get("/app/Quote/device_token")

   //call s3 to get server images
   $.get('/app/Quote/load_images')

   //load all photos initially
   	$('#wscroll').load('/app/Quote/ajax_images',{width: w},function(){
		imagesScroll.refresh();
		imagesScroll.scrollTo(0,0)
    });
  
   $("#newquote").click(function(e){
	   e.preventDefault();
	   $('#quoteformcontainer').show();
	   $("#menu").hide();
   });

   $("#updatedb").click(function(e){
	  e.preventDefault();
	  _gaq.push(['_trackPageview', '/updatedb']); 
	  $('#updatetext')[0].innerHTML = "Updating...";
	  $('#updatedb').attr('id','');
	  $.get('/app/Quote/updatedb')
   })
   
   $("#quoteform").submit(function(e){
	  _gaq.push(['_trackPageview', '/submitquoteform']); 
	  e.preventDefault();
	  var book     = $('#book').val();
	  var citation = $('#citation').val();
	  var quote    = $('#quote').val();
	  var errors   = null;

	  if(book.length < 1){
		$('#lbook')[0].innerHTML += "&nbsp;<font color='red'>(required)</font>";
		errors = true;
	  }
	  if(citation.length < 1){
		$('#lcitation')[0].innerHTML += "&nbsp;<font color='red'>(required)</font>";
		errors = true;
	  }
	  if(quote.length < 1){
		$('#lquote')[0].innerHTML += "&nbsp;<font color='red'>(required)</font>";
		errors = true;
	  }

	  if(errors == null){
		  $('#quoteformcontainer').hide()
		  $.post('/app/Quote/quote_submit',{book:book,citation:citation,quote:quote})
		  $('#book').val("");
		  $('#citation').val("");
		  $('#quote').val("");
	   }
	});
  
   //This is the touchclick event, opens the menu          
   $("#swrapper").click(function(e) { 
     var w,mw, mvx;
     e.preventDefault();
   
     //Google analytics
     _gaq.push(['_trackPageview', 'menu']);
   
     w = $("#wrapper").width();
     mw = $("#menu").width();
     mvx = (w / 2) - (mw / 2);
   
     
   
     //If menu visible and background clicked, close menu and repopulate with topics
     if ($('#quotemenucontainer').is(':visible')) {
       $('#quotemenucontainer').hide();
       $('#thelist').load('/app/Quote/ajax_topics',function(){
       myScroll.refresh();
       myScroll.scrollTo(0,0);}); 
     } 
      
     // else {
     // 	 	$("#menu").css('webkitTransitionDuration','500ms');
     // 	    $("#menu").css('webkitTransform','translate3d(0,' + mvy + 'px,0)');
     //      }
     //Run transition animation to show menu
     else{
   	   $("#menu").show();
       $("#header").show();
       $("#menu").css('left', mvx + 'px');
       $("#menu").css('webkitTransitionDuration','500ms');
       $("#menu").css('webkitTransform','translate3d(0,-' + mvy + 'px,0)'); 
    }         
     $("#quoteformcontainer").hide();
   });

   $('#wrapper').click(function(e){
	  if ($('#bottom_nav').is(':visible')){
		$('#bottom_nav').hide();
	  }
	  else{
		$('#bottom_nav').show();
	  }
   });
  
   //do not close form if user clicks on search bar
   // $("#searchform").click(function(e){
   //      e.stopPropagation();
   //    });

   //when quotecontainer is shown with favorite it blocks wrapper so we must hide it with favorites if clicked
   // $('#quotemenucontainer').click(function(){
   // 	   backtoquote();
   //    });

   //Buttonclick events
   $("#backtoquote").click(function(e) {
     e.preventDefault();
     _gaq.push(['_trackPageview', '/backtoquote']); 
     $("#menu").css('webkitTransitionDuration','500ms');
     $("#menu").css('webkitTransform','translate3d(0,' + mvy + 'px,0)');
   });       
   
   $("#addtofavorites").click(function(e) {
     e.preventDefault();
	 _gaq.push(['_trackPageview', '/addtofavorites' + id() +"," + image()]); 
     $("#header").hide();
     //If already favorite, unset favorite flag
     if (carousel.masterPages[carousel.currentMasterPage].firstChild.className == 'y') {          
       $.get('/app/Quote/{' + id() + '}/unset_favorite')
	  $('#addtofavorites').css('opacity','.5')
	   carousel.masterPages[carousel.currentMasterPage].firstChild.className = 'n'
		 //,function(){
         //myScroll.refresh();
         //myScroll.scrollTo(0,0);
         //$('#quotemenucontainer').show();
       //});                              
     }
     else {
         //Set favorite flag
		 $.get('/app/Quote/{' + id() + ','+image()+'}/set_favorite')
		 $('#addtofavorites').css('opacity','1')
		 carousel.masterPages[carousel.currentMasterPage].firstChild.className = 'y'
         // $('#thelist').load('/app/Quote/{' + id() + ',' + image() + '}/set_favorite',function(){
         // 	        
         //          	myScroll.refresh();
         //          	myScroll.scrollTo(0,0);
                  	//$('#quotemenucontainer').show();
         //          });       
     }
     $("#menu").css('webkitTransitionDuration','500ms');
     $("#menu").css('webkitTransform','translate3d(0,' + mvy + 'px,0)');          
   });  
   
   $("#showfavorites").click(function(e) {
     e.preventDefault();      
     _gaq.push(['_trackPageview', 'showfavorites']);  
	 $("#header").hide();     
     $("#header_fav").show();    
     $('#thelist').load('/app/Quote/ajax_favorites',function(resp){
		//only show container if there are favorites to show
	 	if(resp != ""){
     		$('#quotemenucontainer').show();
     		myScroll.refresh();
     		myScroll.scrollTo(0,0);
		}
     });                    
     $("#menu").css('webkitTransitionDuration','500ms');
     $("#menu").css('webkitTransform','translate3d(0,' + mvy + 'px,0)');      
   }); 
   
   $("#shareemail").click(function(e) {
     e.preventDefault();
     _gaq.push(['_trackPageview', 'shareemail']);
     var quote = currentQuote().innerHTML;
     var topic = 'Inspiration';
     $.get("/app/Quote/get_topic?id="+id(),function(resp){
	 	topic = resp;
	    window.location.href = 'mailto:?subject='+topic+'&body='+quote;  
     })
      
   });
   
   $("#findquote").click(function(e) {
	$.get("/app/Quote/device_token")
     e.preventDefault();
	if ($('#quotemenucontainer').is(':visible')) {
		backtoquote()
	}
	else{
	     _gaq.push(['_trackPageview', 'findquote']);
	     $('#search').val('');
	     $("#header_fav").hide();
	     $("#header").show();                              
	     $('#quotemenucontainer').show();  
	     myScroll.refresh();
	     $("#menu").hide();
	     $("#menu").css('webkitTransitionDuration','0ms');
	     $("#menu").css('webkitTransform','translate3d(0,' + mvy + 'px,0)');
     }
   });

  $("#choosephoto").click(function(e) {
	 e.preventDefault();
	 _gaq.push(['_trackPageview', 'choosephoto']);
     var w = $("#wrapper").width();
     var h = $("#wrapper").height();
     //Run transition animation to show images    
     $("#menu").hide();
     $('#wrapper').css('background-color','black');
     $('#wcontainer').show();
     imagesScroll.refresh();
	 imagesScroll.scrollTo(0,0);
     //window.location.href = '/app/Quote/{'+ id() +'}/photos';  
  });      
   
   $("#searchform").submit(function(e){  
     e.preventDefault();
     var term = $('#search').val()
	_gaq.push(['_trackPageview', 'searchform/' + term]);
     $('#thelist').load('/app/Quote/search_result',{tag: term},function(){
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
	$.get('/app/Live/get_image_link?image=' + img, function(resp){
		el.src = resp;
	})    
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
    $('#addtofavorites').css('opacity','1')
    } else {
    $('#addtofavorites').css('opacity','.5')
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
  $.getJSON('/app/Quote/{'+ id +'}/ajax_quote') .complete(function(data) {
    slides = jQuery.parseJSON(data.responseText);  
    $("#topic_header")[0].innerHTML = slides[0]['topic'];          
    carousel.options.numberOfPages = slides.length;
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

function switchQuoteImage(that,id,image) {
  that.style.background = '#aaaaaa';
  $.getJSON('/app/Quote/ajax_quote?id=' + id + '&image=' + image) .complete(function(data) {
    slides = jQuery.parseJSON(data.responseText);
    $("#topic_header")[0].innerHTML = slides[0]['topic'];            
    carousel.options.numberOfPages = slides.length;
    carousel.masterPages2[carousel.currentMasterPage2].firstChild.src = slides[0]['image_url'];
    carousel.masterPages2[carousel.currentMasterPage2].firstChild.id  = image;
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
    
function switchTopic(that,topicId) {
  that.style.background = '#aaaaaa'; 
  $.getJSON('/app/Quote/{'+ topicId +'}/json_by_topic_id') .complete(function(data) {
    slides = jQuery.parseJSON(data.responseText);
    //change the topic on the screen
    $("#topic_header")[0].innerHTML = slides[0]['topic'];         
    carousel.options.numberOfPages = slides.length;
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
       myScroll.scrollTo(0,0);
   });
}

function toggle_updatedb(){
	  $('#updatetext')[0].innerHTML = "Get Updates";
	  $('#updatedb').attr('id','updatedb');
}
