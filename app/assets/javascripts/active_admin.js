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
    $(this).find('label.select_all').click(function(e){
      check_all($collapsables[i]);
    });
    $(this).find('label').click(function(e){
      parent_selected($collapsables[i]);
    });
    parent_selected($collapsables[i]);
    $fields.slideToggle(200);
  });
});
function check_all(item) {
  console.log(item);
  let res = $(item).find('.primary input').first().prop('checked');
  $(item).
    find('.sub-item input').
    each(function(i, box) { box.checked = res; });
}
function parent_selected(item) {
  var expand = $(item).find('.primary input');
  //Hijo chequeado
  if ( $(item).find('.sub-item input:checked').length ) {
    //Alguno no chequeado?
    if ( $(item).find('.sub-item input:not(:checked)').length ) {
      expand.prop("indeterminate", true);
    }
    else {
      expand.prop("indeterminate", false);
      expand.prop("checked", true);
    }
  }
  else {
    expand.prop("indeterminate", false);
    expand.prop("checked", false);
  }
}
