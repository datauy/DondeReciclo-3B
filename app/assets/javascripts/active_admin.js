//= require active_admin/base
jQuery(document).ready(function($){
  var $collapsables = $('.collapsable-section');
  $collapsables.each(function(i){
    var $label = $(this).find('.label').filter(':first');
    var $fields = $(this).find('.sub-item').filter(':first');
    $label.click(function(e){
        $fields.slideToggle(200);
    });
    $fields.slideToggle(200);
  });
});
