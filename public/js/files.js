let image_count = 0;

let make_upload = (num) => {
  	let file_control = $('<div>').attr({'class':'file-control col-sm-3',
										'id': 'file-control-' + num });

	let upload_area = $('<div>').attr('id','upload-area-' + num);
	let attach_file = $('<input type="file">').attr({'name': 'comment[attach_file_' + num + ']',
													 'style': 'display:none'});
	let upload_label = $('<label>').attr('class', 'btn btn-outline-primary').
		append('Select File').
		append(attach_file);
	upload_area.append(upload_label);

	let delete_area = $('<div>').attr('id','delete-area-' + num).
		append($('<div>').attr('class', 'd-flex justify-content-end').
			   append($('<span>').attr('class', 'fa fa-times',
									   'id', 'delete-' + num)));
	let image_preview = $('<img>').attr({ 'style':'width:148px; height:111px;',
										  'id': 'image_preview-' + num});

	file_control.append(upload_area);
	file_control.append(delete_area);
	file_control.append($('<div>').append(image_preview));
	image_preview.hide();

	upload_area.show();
	delete_area.hide();
	delete_area.on('click', (event) => {
		if ( image_count > 0 ) {
			let num = parseInt($(event.currentTarget).prop("id").replace(/delete-area-/, ''));
			$('#file-control-' + num).remove();
		} else {
			attach_file.val('');
			image_preview.removeAttr('src');
			upload_area.show();
			delete_area.hide();
		}
		image_count -= 1;
	});
	attach_file.on("change", (event) => {
		let file = $(event.currentTarget).prop("files")[0];
		let reader = new FileReader();
		reader.addEventListener('load', () => {
			let	preview;
			let	file_type = attach_file.prop('files')[0].type;
console.log(file_type);
			if ( file_type.match(/^image/) ) {
				preview = reader.result;
			} else {
				preview = `/images/content_types/${file_type}.png`
			}
			image_preview.attr('src', preview).show();
			upload_area.hide();
			delete_area.show();
		}, false);
		image_count += 1;
		reader.readAsDataURL(file);
		$('#file-list').prepend(make_upload(image_count));
	});

	return (file_control);
}

$(document).ready(function(){
	$('#file-list').append(make_upload(image_count));
});
