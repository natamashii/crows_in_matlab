function write32bitctx(inpicture,name)
% arguments: (rgb) and (filename without .ctx extension)
%
% created 5/1/98  --GR

directories

rgb(:,:,1)=(inpicture(:,:,1))';
rgb(:,:,2)=(inpicture(:,:,2))';
rgb(:,:,3)=(inpicture(:,:,3))';

x_size=size(rgb,1)
y_size=size(rgb,2)

picture=zeros(x_size,y_size,4);
picture(1:x_size,1:y_size,2:4)=rgb;

temp=reshape(picture,1,prod(size(picture)));
temp=reshape(temp,x_size*y_size,4);
picture_data=reshape(temp',prod(size(picture)),1);

	wfile = strcat(dir_ctx, name,'.ctx');
	fid2 = fopen(wfile, 'w');
	ctx_length = length(picture_data) + 18;
	ctx_image = zeros(1, ctx_length);
	ctx_image(11) = 32; % bpp
	ctx_image(13) = x_size; % width
	ctx_image(15) = y_size; % height
	ctx_image(17) = 1; % #frames
	ctx_image(19:ctx_length) = picture_data;
	fwrite(fid2, ctx_image, 'uint8');
	fclose(fid2);
	