//scene
var container;
var screenWidth, screenHeight, ratio=1;
var scene, view_camera, renderer, track_controls;	
var calc_camera;

var plane1Material,plane2Material;;
var modelMaterial;

var planeScreen2;
var image = 'img/diffuse	.jpg';
function init(){

	screenWidth = window.innerWidth;
	screenHeight = window.innerHeight*0.99;

	simulationDiv = document.getElementById('simulation');
	container = document.getElementById( 'container' );
	container.width = screenWidth;
	container.height = screenHeight;

	renderer = new THREE.WebGLRenderer({canvas:container, preserveDrawingBuffer: true});
	renderer.setClearColor(0xcccccc);
	renderer.setSize(screenWidth, screenHeight);

	//scene
	scene = new THREE.Scene();

// Create light
	var light = new THREE.PointLight(0xffffff, 1.0);
	light.position.set(0.0,12.5,0.0);
	scene.add(light);

	//camera

	var L = 0.6;
	view_camera = new THREE.PerspectiveCamera(60, screenWidth/screenHeight, 0.01, 5000);
	view_camera.position.x = 0.5*1.5;
	view_camera.position.y = 0.75*1.5;
	view_camera.position.z = 0.5*1.5;
	// view_camera.position.x = 1.0;
	// view_camera.position.y = 1.0;
	// view_camera.position.z = 0.5;
	view_camera.lookAt(new THREE.Vector3(0.0,0,0.0));
	// view_camera.rotation.x = -2*Math.PI/2;
	// x: 0.02003957673652057, y: 1.6471910068654099, z: 0.6948529461665989}
	
	// view_camera.rotateX	
	scene.add(view_camera);

	track_controls = new THREE.TrackballControls(view_camera);
	track_controls.target.set(0,0,0);
	track_controls.zoomSpeed = 0.1;
	track_controls.rotateSpeed = 2.0;
	var axisHelper = new THREE.AxisHelper( 5 );
	scene.add( axisHelper );
	//---------plane1 uses image as texture ----------
	//material
	plane1Material = new THREE.MeshPhongMaterial( { color: 0xdddddd, 
					specular: 0x002200, shininess: 30,side: THREE.DoubleSide} );

	plane1Material.map = THREE.ImageUtils.loadTexture(image);
	// plane1Material.bumpMap = THREE.ImageUtils.loadTexture('img/diffuse.jpg');
	// plane1Material.bumpScale = 0.01;
	plane1Material.displacementMap = THREE.ImageUtils.loadTexture(image);
	plane1Material.displacementScale =0.01;


	var geometry1 = new THREE.PlaneGeometry(1 , 1, 32*2*2,32*2*2	);
	var planeScreen1 = new THREE.Mesh( geometry1, plane1Material );
	planeScreen1.rotateX(-3.14/2);
	// planeScreen1.rotateZ(-3.14/2);
	scene.add( planeScreen1 );


	//---------plane2 uses textureBuffer as texture ----------
	//now setup the simulation plane

	//scene: same scene;

	//camera: orto  camera centered 

	calc_camera = new THREE.OrthographicCamera( -0.5, 0.5, 
					0.5, -0.5, - 500, 1000 );
	calc_camera.rotateX(-Math.PI/2);
	// calc_camera.rotateZ(-Math.PI/2);
	calc_camera.position.x = 1.0;
	scene.add(calc_camera);

	//material
	var vshader = "shaders/vshader.glsl";
	var mFshader = "shaders/mFshader.glsl";

	mUniforms = {
		t: {type: 'f', value:0.0}
	}
	modelMaterial = new THREE.ShaderMaterial({
		uniforms: mUniforms,
		vertexShader: $.ajax(vshader, {async:false}).responseText,
		fragmentShader: $.ajax(mFshader,{async:false}).responseText
	});

	mTextureBuffer = new THREE.WebGLRenderTarget( 256, 256, 
			 					{minFilter: THREE.LinearFilter,
		                         magFilter: THREE.LinearFilter,
		                         format: THREE.RGBAFormat,
		                         type: THREE.FloatType});

	
	//geometry
	var geometry2 = new THREE.PlaneGeometry(1 , 1, 32*2*2,32*2*2	);
	plane2Material = new THREE.MeshPhongMaterial( { color: 0x000000, 
					specular: 0xffffff, shininess: 120.0*4.0,side: THREE.DoubleSide} );	
	planeScreen2 = new THREE.Mesh( geometry2, modelMaterial );
	planeScreen2.rotateX(-3.14/2);
	// planeScreen2.rotateZ(-3.14/2);
	planeScreen2.position.x = 1.0;
	scene.add( planeScreen2 );	

	renderer.render(scene, calc_camera, mTextureBuffer, true);

	//add a third plane to show the final image
	// image + bump from webglrendertarget

	//first render just the webglrendertarget
	plane3Material = new THREE.MeshPhongMaterial( { color: 0xdddddd, 
					specular: 0x00ff00, shininess: 480,side: THREE.DoubleSide} );	
	

	plane3Material.map = THREE.ImageUtils.loadTexture(image);
	plane3Material.bumpMap = mTextureBuffer;
	plane3Material.bumpScale = 0.1/2;
	plane3Material.displacementMap = mTextureBuffer;
	plane3Material.displacementScale =0.1/2;


	var geometry3 = new THREE.PlaneGeometry(1 , 1, 32*2*2,32*2*2	);
	var planeScreen3 = new THREE.Mesh( geometry3, plane3Material );
	planeScreen3.rotateX(-3.14/2);
	// planeScreen3.rotateZ(-3.14/2);
	planeScreen1.position.z = 1.0;
	scene.add( planeScreen3 );


	//render
	render();
}

function render(){
	mUniforms.t.value = mUniforms.t.value + 1;
	renderer.render(scene, calc_camera, mTextureBuffer, true);

	track_controls.update();	
	renderer.render(scene,view_camera);	
	requestAnimationFrame(render);

}