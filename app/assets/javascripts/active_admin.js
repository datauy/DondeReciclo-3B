//= require active_admin/base
jQuery(document).ready(function($){
  var $collapsables = $('.collapsable-section');
  $collapsables.each(function(i){
    var $label = $(this).find('.expand-area').filter(':first');
    var $fields = $(this).find('.sub-item').filter(':first');
    $label.click(function(e){
      $fields.slideToggle(200);
      if ( $label.hasClass('down') ) {
        $label.removeClass('down');
      }
      else {
        $label.addClass('down');
      }
    });
    $(this).find('input').click(function(e){
      parent_selected($collapsables[i]);
    });
    parent_selected($collapsables[i]);
    $fields.slideToggle(200);
    console.log(i);
  });
});
function parent_selected(item) {
  //Hijo chequeado
  if ( $(item).find('.sub-item input:checked').length ) {
    //Padre chequeado?
    if ( !$(item).find('.primary input:checked').length ) {
      $(item).find('.primary input').prop("indeterminate", true);
    }
  }
}
