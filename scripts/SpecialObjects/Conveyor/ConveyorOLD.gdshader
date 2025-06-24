shader_type canvas_item;

//void vertex() {
	// Called for every vertex the material is visible on.
//}
uniform int color : hint_range(0, 2) = 0;


void fragment() {
	//https://www.rgbtohex.net/hex-to-rgb/

	vec4 col1 = vec4(191, 255, 177, 255) / 255.0;
	vec4 col2 = vec4(113, 224, 91, 255) / 255.0;
	vec4 col3 = vec4(93, 198, 72, 255) / 255.0;
	vec4 col4 = vec4(82, 176, 64, 255) / 255.0;

	vec4 col1Default = col1;
	vec4 col2Default = col2;
	vec4 col3Default = col3;
	vec4 col4Default = col4;

	if (color == 1){
		col1 = vec4(252,255,177,255) / 255.0;
		col2 = vec4(249,255,118,255) / 255.0;
		col3 = vec4(240,246,82,255) / 255.0;
		col4 = vec4(213,220,57,255) / 255.0;
	}
	else if (color == 2){
		col1 = vec4(255,177,177,255) / 255.0;
		col2 = vec4(237,120,120,255) / 255.0;
		col3 = vec4(220,89,89,255) / 255.0;
		col4 = vec4(198,72,72,255) / 255.0;
	}

	vec4 pixelColor = texture(TEXTURE, UV);
	if (color != 0){
		if (pixelColor == col1Default){
			 COLOR = col1;
		}
		else if (pixelColor == col2Default){
			 COLOR = col2;
		}
		else if (pixelColor == col3Default){
			 COLOR = col4;
		}
		else if (pixelColor == col4Default){
			 COLOR = col4;
		}
		//COLOR = vec4(60, 0, 177, 255);
	}


	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
