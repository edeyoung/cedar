// Controls checking and unchecking of measures and validations
$(document).ready( function(){
  $('#checkAll').click(function () {
    $('.check').prop('checked', true);
  });
  $('#checkNone').click(function () {
    $('.check').prop('checked', false);
  });
  $('.checkByTag').click(function () {
    var tag = $(this)[0].innerText.replace(/[^0-9A-Z]/gi, '_').slice(1)
    $('.check.tag-' + tag).prop('checked', true);
  });
});
