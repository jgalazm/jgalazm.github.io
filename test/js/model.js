// set the scene size
var WIDTH = window.innerWidth,
  HEIGHT = window.innerHeight;

// set some camera attributes
var VIEW_ANGLE = 45,
  ASPECT = WIDTH / HEIGHT,
  NEAR = 0.1,
  FAR = 10000;

// get the DOM element to attach to
// - assume we've got jQuery to hand
var $container = $('#container');

// create a WebGL renderer, camera
// and a scene
var renderer = new THREE.WebGLRenderer();
var camera =
  new THREE.PerspectiveCamera(
    VIEW_ANGLE,
    ASPECT,
    NEAR,
    FAR);

var scene = new THREE.Scene();

// add the camera to the scene
scene.add(camera);

// the camera starts at 0,0,0
// so pull it back
camera.position.z = 300;

// start the renderer
renderer.setSize(WIDTH, HEIGHT);

// attach the render-supplied DOM element
$container.append(renderer.domElement);

//------------------------------------------------
var uniforms = {
  amplitude: {
    type: 'f', // a float
    value: 0
  }
};

var vShader = $('#vertexshader');
var fShader = $('#fragmentshader');

// create the material
var shaderMaterial = new THREE.ShaderMaterial({
  uniforms: uniforms,
  vertexShader:   vShader.text(),
  fragmentShader: fShader.text()
  });


// set up the sphere geometry
var radius = 50, segments = 16, rings = 16;

var sphereGeom = new THREE.SphereBufferGeometry( radius, segments,  rings)

var verts = sphereGeom.getAttribute('position').array;
var values = new Float32Array(verts.length)
for (var v = 0; v < verts.length; v++) {
  values[v]=Math.random() * 30;
}
sphereGeom.addAttribute('displacement',new THREE.BufferAttribute( values,1 ))

// create a new mesh with  the sphereMaterial
var sphere = new THREE.Mesh(sphereGeom ,  shaderMaterial);

// now populate the array of attributes

// add the sphere to the scene
scene.add(sphere);

// create a point light
var pointLight =
  new THREE.PointLight(0xFFFFFF);

// set its position
pointLight.position.x = 10;
pointLight.position.y = 50;
pointLight.position.z = 130;

// add to the scene
scene.add(pointLight);

// draw! and animate!

var frame = 0;
function update() {

  // update the amplitude based on
  // the frame value.
  uniforms.amplitude.value =
    Math.sin(frame);

  // update the frame counter
  frame += 0.1;

  renderer.render(scene, camera);

  // set up the next call
  requestAnimationFrame(update);
}

requestAnimationFrame(update);
