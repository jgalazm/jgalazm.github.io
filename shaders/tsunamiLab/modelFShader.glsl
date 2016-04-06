varying vec2 vUv;
uniform sampler2D tSource;
uniform vec2 delta;
uniform vec2 texel;

uniform float gx;
uniform float rx;
uniform float ry;
uniform float g;
uniform float xmin;
uniform float xmax;
uniform float ymin;
uniform float ymax;
uniform float zmin;
uniform float zmax;


float openBoundary(vec4 u_ij, vec4 u_ijm, vec4 u_imj,
	float h_ij, float h_ijm){
	
	float eta=0.0;
	float k = 1.0; //debug thing
	//to test if im catching the right texels;
// 	//boundaries
	
	//j=0
	if (vUv.y <=k*delta.y){ 
		if (vUv.x > k*delta.x && vUv.x <=1.0-k*delta.x){
			if (h_ij>gx){
				float cc = sqrt(g*h_ij);
				float uh = 0.5*(u_ij.g+u_imj.g);
				float uu = sqrt(uh*uh+ u_ij.b*u_ij.b);
				float zz = uu/cc;
				if (u_ij.b>0.0){
					zz = -zz;
				}
				eta = zz;
			}
			else {
				eta = 0.0;	
			}
		}
	}

	//j=ny
	else if (vUv.y>1.0-k*delta.y) {
		if (vUv.x > k*delta.x && vUv.x <=1.0-k*delta.x){
			if (h_ij>gx){
				float cc = sqrt(g*h_ij);
				float uh = 0.5*(u_ij.g+u_imj.g);
				float uu = sqrt(uh*uh + u_ijm.b*u_ijm.b);
				float zz = uu/cc;
				if (u_ijm.b<0.0){
					zz = -zz;
				}
				eta = zz;
			}
			else {
				eta = 0.0;

			}
		}
	}

	// i = 0
	if (vUv.x <=k*delta.x){ 
		//j in range(1,ny-1)
		if (vUv.y > k*delta.y && vUv.y <=1.0-k*delta.y){
			if (h_ij>gx){
				float cc = sqrt(g*h_ij);
				float uh;
				if (h_ijm>gx){
					uh =  0.5*(u_ij.b+u_ijm.b);
				}
				else{
					uh = u_ij.b;
				}
				float uu = sqrt(uh*uh+u_ij.g*u_ij.g);
				float zz = uu/cc;
				if (u_ij.g>0.0){
					zz = -zz;
				}
				eta = zz;
			}
			else {
				eta = 0.0;
			}
		}
	}
	else if (vUv.x >1.0-k*delta.x){ // i = nx
		if (vUv.y >= k*delta.y && vUv.y <=1.0-k*delta.y){
			if (h_ij>gx){
				float cc = sqrt(g*h_ij);
				float uh = 0.5*(u_ij.b+u_ijm.b);
				float uu = sqrt(uh*uh+u_imj.g*u_imj.g);
				float zz = uu/cc;
				if (u_imj.g<0.0){
					zz = -zz;
				}
				eta = zz;
			}
			else {
				eta = 0.0;
			}
		}	  
	}


	// i = 0, j = 0
	if (vUv.x <= k*delta.x && vUv.y <= k*delta.y){
		if (h_ij>gx){
			float cc = sqrt(g*h_ij);
			float qx = u_ij.g;
			float qy = u_ij.b;
			float uu = sqrt(qx*qx+qy*qy);
			float zz = uu/cc;
			if (qx>0.0|| qy>0.0){
				zz = -zz;
			}
			eta = zz;

		}
		else {
			eta = 0.0;
		}		
	}
   
	// // i = 0, j = ny
	if (vUv.x<= k*delta.x && vUv.y > 1.0-k*delta.y){
		if (h_ij>gx){
			float cc = sqrt(g*h_ij);
			float qx = u_ij.g;
			float qy = u_ijm.b;
			float uu = sqrt(qx*qx+qy*qy);
			float zz = uu/cc;
			if (qx>0.0 || qy<0.0){
				zz = -zz;
			}
			eta = zz;

		}
		else {
			eta = 0.0;
		}
	}

	// // i = nx, j = 0
	if (vUv.x > 1.0 - k*delta.x && vUv.y <= k*delta.y){
		if (h_ij>gx){
			float cc = sqrt(g*h_ij);
			float qx = u_imj.g;
			float qy = u_ij.b;
			float uu = sqrt(qx*qx+qy*qy);
			float zz = uu/cc;
			if (qx<0.0 || qy>0.0){
				zz = -zz;
			}
			eta = zz;
		}
		else {
			eta = 0.0;
		}
	}
	
	// i = nx, j = ny
	if (vUv.x >  1.0 - k*delta.x && vUv.y > 1.0-k*delta.y){
		if (h_ij>gx){
			float cc = sqrt(g*h_ij);
			float qx = u_imj.g;
			float qy = u_ijm.b;
			float uu = sqrt(qx*qx+qy*qy);
			float zz = uu/cc;
			if (qx<0.0 || qy<0.0){
				zz = -zz;
			}
			eta = zz;
		}
		else {
			eta = 0.0;
		}
	}				
	return eta;
	
}
void main()
{
	// u = (eta, p, q, h)
	// eta: free surface
	// p: x-momentum
	// q: y-momentum
	// h: water depth, >0 if wet, <0 if dry.

	//old vals
	vec4 u_ij = texture2D(tSource,vUv);

	//neighbors old vals
	vec4 u_imj = texture2D(tSource, vUv+vec2(-1.0*delta.x,0.0));
	vec4 u_ipj = texture2D(tSource, vUv+vec2(delta.x,0.0));
	vec4 u_ijm = texture2D(tSource, vUv+vec2(0.0,-1.0*delta.y));
	vec4 u_ijp = texture2D(tSource, vUv+vec2(0.0,delta.y));

	vec4 u_ipjm = texture2D(tSource, vUv+vec2(delta.x,-1.0*delta.y));
	vec4 u_imjp = texture2D(tSource, vUv+vec2(-1.0*delta.x,delta.y));
	

	//new vals
	vec4 u2_ij, u2_ipj, u2_ijp;

	//bati depth vals
	float h_ij = -(u_ij.a*(zmax-zmin)+zmin);
	float h_ipj = -(u_ipj.a*(zmax-zmin)+zmin);
	float h_ijp = -(u_ijp.a*(zmax-zmin)+zmin);
	float h_ijm = -(u_ijm.a*(zmax-zmin)+zmin);

	//mass equation
	if (h_ij >gx){
		u2_ij.r = u_ij.r -rx*(u_ij.g-u_imj.g) - ry*(u_ij.b - u_ijm.b);
	}
	else{
		u2_ij.r = 0.0;
	}
	if (h_ipj >gx){

		u2_ipj.r = u_ipj.r -rx*(u_ipj.g-u_ij.g)-ry*(u_ipj.b - u_ipjm.b);
	}
	else{
		u2_ipj.r = 0.0;
	}
	if (h_ijp >gx){
		
		u2_ijp.r = u_ijp.r -rx*(u_ijp.g - u_imjp.g) -ry*(u_ijp.b - u_ij.b);
	}
	else{
		u2_ijp.r = 0.0;
	}	
	

	//handle boundaries (Open)
	if (vUv.x<=1.0*delta.x || vUv.x>1.0-1.0*delta.x || 
		vUv.y <=1.0*delta.y || vUv.y>1.0-1.0*delta.y){
		u2_ij.r = openBoundary(u_ij, u_ijm, u_imj, h_ij, h_ijm);
	}


	// x -momentum
	if (vUv.x<1.0-delta.x && vUv.y<1.0-delta.y){
		if ((h_ij>gx) && (h_ipj>gx)){
			float hM = 0.5*(h_ij+h_ipj) + 0.5*(u2_ij.r+u2_ipj.r);
			u2_ij.g = u_ij.g - g*rx*hM*(u2_ipj.r-u2_ij.r);
		}
		else{
			u2_ij.g = 0.0;
		}			
	}
	else{
		u2_ij.g = 0.0;
	}

	// y - momentum
	if (vUv.x<1.0-delta.x && vUv.y<1.0-delta.y){
		if ( (h_ij>gx) && (h_ijp>gx)){
			float hN = 0.5*(h_ij + h_ijp) + 0.5*(u2_ij.r+u2_ijp.r);
			u2_ij.b = u_ij.b - g*ry*hN*(u2_ijp.r-u2_ij.r);
		}
		else{
			u2_ij.b = 0.0;
		}		
	}
	else{
		u2_ij.b = 0.0;
	}


	u2_ij.a = u_ij.a;

	//sometimes .. it just blows up
	if (abs(u2_ij.r)>50.0){
		u2_ij.r = 0.0;
		u2_ij.g = 0.0;
		u2_ij.b = 0.0;
	}

	gl_FragColor = vec4(u2_ij);
}