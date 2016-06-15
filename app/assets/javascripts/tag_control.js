// Controls addition and removal of tags
$(document).ready( function(){
  // Switch between the add-tag link and the new-tag input
  $('.add-tag').click(function () {
    $(this).fadeOut( 50, function() {
      var new_input = $(this).siblings('.new-tag')
      new_input.fadeIn();
      new_input.find('input').focus();
    });
  });
  // Set up the tag removal buttons (for initial page load and new tags)
  function initialize_remove_tags() {
    $('.cedar-remove-tag').click(function (e) {
      var tag_parent = $(e.target).parents('.cedar-tag-parent')
      var tag_item_type = tag_parent.parent().attr('data-tag-item-type')
      var tag_item_id = tag_parent.parent().attr('data-tag-item-id')
      var tag_to_remove = tag_parent.find('span')[0].innerText.slice(1)
      $.ajax({
        type: 'POST',
        url: '/' + tag_item_type + 's/' + tag_item_id + '/remove_tag',
        data: {tag: tag_to_remove}
      });
      tag_parent.fadeOut(200);
    });
  };
  initialize_remove_tags();
  function initialize_new_tag(text, container) {
    var tag_item_type = container.siblings('.cedar-tags').attr('data-tag-item-type')
    var tag_item_id = container.siblings('.cedar-tags').attr('data-tag-item-id')
    sanitized_text = sanitize_input(text)
    // If there is nothing left after sanitizing the text, don't do anything
    if (sanitized_text == '') {return false}
    $.ajax({
      type: 'POST',
      url: '/' + tag_item_type + 's/' + tag_item_id + '/add_tag',
      data: {tag: sanitized_text}
    });
    // Create a new tag using that value
    container.parents('td').children('.cedar-tags').append(
      "<div class='cedar-tag-parent' style='white-space:nowrap;'>\
        <span class='label label-primary cedar-tag'>\
          <i class='glyphicon glyphicon-tag'></i> " + sanitized_text + "\
        </span>\
        <button class='btn btn-danger btn-xs cedar-remove-tag'>\
          <i class='glyphicon glyphicon-remove'></i> <span class='sr-only'> Remove " + sanitized_text + "</span>\
        </button>\
      </div>"
    );
    initialize_remove_tags();
    // Hide the input box and show the Add link again
    container.fadeOut( 50, function() {
      container.find('input')[0].value = '';
      container.parents('td').children('.add-tag').fadeIn();
    });
  }
  // Only allow letters, numbers, and spaces in tags
  var tag_regex = /[^0-9A-Z ]/gi
  function sanitize_input(text) {
    return text.replace(tag_regex, '').trim();
  }
  // On click of the button or pressing the enter key, try to create a new tag
  $('.new-tag button').click(function(e){
    var container = $(e.target).parents('.new-tag')
    var new_tag_text = container.find('input')[0].value
    initialize_new_tag(new_tag_text, container);
  });
  $('.new-tag input').bind('enterKey',function(e){
    var new_tag_text = e.target.value
    var container = $(e.target).parents('.new-tag')
    initialize_new_tag(new_tag_text, container);
  });
  $('.new-tag input').keyup(function(e){
    if(tag_regex.test(e.target.value))
      {
        $(this).tooltip('show')
        e.target.value = sanitize_input(e.target.value)
      }
    if(e.keyCode == 13)
      {
        $(this).trigger('enterKey');
      }
  });
});
