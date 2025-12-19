var uploader = Qiniu.uploader({
  runtimes: 'html5,html4',
  browse_button: 'avatar_image_key_button',
  uptoken_url: '/uptoken',
  unique_names: true,
  save_key: false,
  domain: '<%= Settings.qiniu.public.domain %>',
  get_new_uptoken: false,
  container: 'container',
  max_file_size: '100mb',
  max_retries: 3,
  dragdrop: true,
  drop_element: 'container',
  chunk_size: '4mb',
  auto_start: true,
  init: {
    'FileUploaded': function(up, file, info) {
      var res = $.parseJSON(info);
      $('#avatar_image_key_id').val(res.key);
    },
    'Error': function(up, err, errTip) {}
  }
});

function htmlToElement(html_str) {
  var template = document.createElement('template');
  template.innerHTML = html_str.trim();
  return template.content.firstChild;
}
