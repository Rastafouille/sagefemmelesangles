jQuery(document).ready(function(){


		var heights = jQuery(".txt_pres").map(function ()
    	{
        	return jQuery(this).height();
    	}).get();

		maxHeight = Math.max.apply(null, heights);
		jQuery( ".txt_pres" ).css( "min-height", maxHeight);
	/*******************************************************************************/
	
		var heights = jQuery(".ttl_pres").map(function ()
    	{
        	return jQuery(this).height();
    	}).get();

		maxHeight = Math.max.apply(null, heights);
		jQuery( ".ttl_pres" ).css( "min-height", maxHeight);
	
        /****************************add class to parent has specific child class or html tag*************************/
        //jQuery('.child_class').parent().addClass('New_parent_class');


        /****************************add class to child has specific (class or html tag) and parent class*************************/
        //jQuery('.parent_class .child_balise_or_class').addClass('New_child_class');
    

        /****************************clone element*************************/
        //jQuery('.balise_or_class').clone().appendTo('.balise_or_class');

	jQuery("<div class='pastille'><div class='title_elem'>Nos Sages-Femmes</div><div class='pastille_elem'><h4>Julie Durafour</h4><a href='tel:0623291534'>06 23 29 15 34</a><br><a class='a_btn' href='https://www.doctolib.fr/sage-femme/avignon/julie-durafour/booking/telehealth-suggestion?profile_skipped=true' target='_blank'>Prise de rendez-vous Doctolib</a><h4>Catherine Quetin</h4><a href='tel:06 74 53 87 33'>06 74 53 87 33</a><br><a class='a_btn' href='https://www.doctolib.fr/sage-femme/les-angles/catherine-quetin/booking/motives?profile_skipped=true&specialityId=34&telehealth=false&placeId=practice-182937' target='_blank'>Prise de rendez-vous Doctolib</a><h4>Bérengère ANDRE</h4><a href='tel:07 56 13 60 42'>07 56 13 60 42</a><br><a class='a_btn' href='https://www.doctolib.fr/sage-femme/les-angles/berengere-andre/booking/motives?profile_skipped=true&specialityId=34&telehealth=false&placeId=practice-451743' target='_blank'>Prise de rendez-vous Doctolib</a></div></div>").appendTo(jQuery('.page-template '));

        /**************************** delete title balise when hover images *************************/
        jQuery('img').removeAttr('title');
        jQuery('.gallery a, .wpmf-gallery a').removeAttr('title');


        /**************************** add icons reseaux menu mobile *************************/
        jQuery('<a href="https://www.google.com/search?q=julie+durafour&oq=julie+durafour&gs_lcrp=EgZjaHJvbWUyBggAEEUYOTINCAEQLhivARjHARiABDIHCAIQLhiABDIHCAMQABiABDIHCAQQABiABDIGCAUQRRg9MgYIBhBFGD0yBggHEEUYPdIBCDE4NTVqMGo3qAIAsAIA&sourceid=chrome&ie=UTF-8#lrd=0x12b5ed3de1f6c225:0xc44e4007d91cac5d,1,,,," target="_blank" class="icon_mobil_menu" ><i class="fab fa-google"></i></a>').appendTo(jQuery('.fusion-mobile-menu-icons'));
  
  
        /**************************** add scroll effect to a link on click *************************/
        //jQuery(".Onepage_link > a").addClass("fusion-one-page-text-link");
        
    
        /**************************** add link to politicy's rgpd testimonial's form *************************/
        if(jQuery('.wpmtst-form .field-rgpd .checkbox-label').length){
          jQuery('.wpmtst-form .field-rgpd .checkbox-label').empty();
          jQuery('.wpmtst-form .field-rgpd .checkbox-label').append("En soumettant ce formulaire, j'accepte la <a class='dib' target='_blank' href='/politique-de-confidentialite/'><u>politique de confidentialité</u></a>");
        }
    
        /**************************** add link to politicy's google testimonial's form *************************/
        if(jQuery('.wpmtst-form .field-anti_spam_google .before').length){
          jQuery('.wpmtst-form .field-anti_spam_google .before').empty();
          jQuery('.wpmtst-form .field-anti_spam_google .before').append("<span class='recaptcha_acc'>Ce site est protégé par reCAPTCHA. <a target='_blank' href='https://policies.google.com/privacy' rel='noopener'><u>les règles de confidentialité</u></a> et <a target='_blank' href='https://policies.google.com/terms' rel='noopener'><u>les conditions d'utilisation</u></a> de Google s\'appliquent.</span>");
        }
    
        /**************************** move rgpd google to end of form *************************/
        jQuery('.wpmtst-form .field-anti_spam_google').appendTo('.wpmtst-form .wpmtst-submission-form');
    

        /***************** Scale the centred item of Slide-Anything **************/
        /*jQuery('.section_prestations .owl-carousel').on('translate.owl.carousel', function(e){
            idx = e.item.index;
            jQuery('.owl-item.center-item').removeClass('center-item');
            jQuery('.owl-item').eq(idx+1).addClass('center-item');
        });*/


        /***************** Equal (min-height) for textes,titles, exc in inline blocs **************/
        var max_heightTxt =(classes)=>{
            var max_height_txt = jQuery(classes).map(function (){return jQuery(this).height();}).get();
            minHeightTxt = Math.max.apply(null, max_height_txt);
            jQuery( classes ).css( "min-height",minHeightTxt );
        }
        
        //dupliquer le code suivant ou cas de besoin d'autres element de méme hauteur !
        max_heightTxt('.txt-class');
        
        /************************** End Function *************************/


        /**************** Begin Function : contact form 7 with animated placeholder input ****************/
        jQuery('input, textarea,.sp-label,.wpmtst-form .form-field').focus(function(){
            jQuery(this).parents('.input-label,.wpmtst-form .form-field').addClass('focused');
        });
        jQuery('.sp-label').click(function(){
            jQuery(this).parents('.input-label,.wpmtst-form .form-field').addClass('focused');
            jQuery(this).parents('.input-label,.wpmtst-form .form-field').find('input,.wpmtst-form .form-field input').focus();
            jQuery(this).parents('.input-label,.wpmtst-form .form-field').find('textarea,.wpmtst-form .form-field textarea').focus();
        });
        jQuery('input, textarea').blur(function(){
            var inputValue = jQuery(this).val();
            if ( inputValue == "" ) {
                jQuery(this).removeClass('filled');
                jQuery(this).parents('.input-label,.wpmtst-form .form-field').removeClass('focused');  
            } else {
                jQuery(this).addClass('filled');
            }
        });
        /************************************* End Function *************************************/
       
     
       /************************************* Begin Function : svg logo coherence footer *************************************/
//         jQuery('.coherence-logo img.svg').each(function(){
//             var $img = jQuery(this);
//             var imgID = $img.attr('id');
//             var imgClass = $img.attr('class');
//             var imgURL = $img.attr('src');
//             jQuery.get(imgURL, function(data) {
//                 // Get the SVG tag, ignore the rest
//                 var $svg = jQuery(data).find('svg');
//                 // Add replaced image's ID to the new SVG
//                 if(typeof imgID !== 'undefined') {
//                     $svg = $svg.attr('id', imgID);
//                 }
//                 // Add replaced image's classes to the new SVG
//                 if(typeof imgClass !== 'undefined') {
//                     $svg = $svg.attr('class', imgClass+' replaced-svg');
//                 }
//                 // Remove any invalid XML tags as per http://validator.w3.org
//                 $svg = $svg.removeAttr('xmlns:a');
//                 // Replace image with new SVG
//                 $img.replaceWith($svg);
//             });
//         });
        /************************************* End Function *************************************/

        /**************************** Begin Function : Edit default number of google reviews to show in different screens  *************************/
        /* change the values */
        /* 1920 */
        let count_rev_1920 = 3;

        /* 1360 */
        let count_rev_1360 = 3;

        /* 1024 */
        let count_rev_1024 = 2;

        /* 800 */
        let count_rev_800 = 2;
        
        /* 600 */
        let count_rev_600 = 1;

        /***** seting the new values *****/
        function set_count_review () {
            setTimeout(function() {
                /*** remove the default ****/
                jQuery('.ti-widget-container').removeClass(function (index, className) {
                    return (className.match (/(^|\s)ti-col-\S+/g) || []).join(' ');
                });
                /*** set the new class ****/
                let new_review_counts;
                let windowsize = jQuery(window).width();
                if (windowsize <= 600) {
                    new_review_counts = `ti-col-${count_rev_600} `;
                } else if (windowsize <= 800) {
                    new_review_counts = `ti-col-${count_rev_800} `;
                }else if (windowsize <= 1024) {
                    new_review_counts = `ti-col-${count_rev_1024} `;
                }else if (windowsize <= 1360) {
                    new_review_counts = `ti-col-${count_rev_1360} `;
                }else{
                    new_review_counts = `ti-col-${count_rev_1920} `;
                }

                jQuery('.ti-widget-container').addClass(new_review_counts);

            }, 1500);
        }

        set_count_review();

        /***** calling on the resize *****/
        jQuery( window ).resize(function () {
            set_count_review();
        });
        /**************************** End Function *************************/
    var equalizeHeights = (selector) => {
		// Reset min-height first
		jQuery(selector).css("min-height", "");
		// Get heights including padding
		var heights = jQuery(selector).map(function() {
		return jQuery(this).outerHeight();
		}).get();
		var maxHeight = Math.max.apply(null, heights);
		jQuery(selector).css("min-height", maxHeight);
		}
		// Appliquer aux blocs
			equalizeHeights('.text_presta');
			equalizeHeights('.titre_h2_prista');
		// Réappliquer lors du redimensionnement
		jQuery(window).resize(function() {
			equalizeHeights('.text_presta');
			equalizeHeights('.titre_h2_prista');
		});
		// Réappliquer après le chargement complet
		jQuery(window).on('load', function() {
			equalizeHeights('.text_presta');
			equalizeHeights('.titre_h2_prista');
		});
});


