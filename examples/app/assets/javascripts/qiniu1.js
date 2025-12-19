var Qiniu1 = new QiniuJsSDK;

var uploader1 = Qiniu1.uploader({
  runtimes: 'html5,html4',
  browse_button: 'certificate_image_key_button',
  uptoken_url: '/private_uptoken',
  unique_names: true,
  save_key: false,
  domain: '<%= Settings.qiniu.private.domain %>',
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
      $('#certificate_image_key_id').val(res.key);
    },
    'Error': function(up, err, errTip) {}
  }
});