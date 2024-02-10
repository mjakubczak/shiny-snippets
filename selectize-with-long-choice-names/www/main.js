function format_item(option, escape) {
  var p = escape(option.label);
  var ps = text_abstract(p, 30);  // you can control the final length here
  return '<div class="my-option">' + 
    '<span class="my-item" title="' + p + '">' + ps + '</span>' + 
    '</div>';
}

function text_abstract(text, length) {
  if (text == null) {
    return "";
  }
  if (text.length <= length) {
    return text;
  }
  return text.substring(0, length) + "...";
}
