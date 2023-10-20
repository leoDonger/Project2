public class Vec3 {
 public float x, y, z;

 public Vec3(float x, float y, float z) {
   this.x = x;
   this.y = y;
   this.z = z;
 }

 public String toString() {
   return "(" + x + "," + y + "," + z + ")";
 }

 public float length() {
   return sqrt(x * x + y * y + z * z);
 }

 public float lengthSqr() {
   return x * x + y * y + z * z;
 }

 public Vec3 plus(Vec3 rhs) {
   return new Vec3(x + rhs.x, y + rhs.y, z + rhs.z);
 }

 public void add(Vec3 rhs) {
   x += rhs.x;
   y += rhs.y;
   z += rhs.z;
 }

 public Vec3 minus(Vec3 rhs) {
   return new Vec3(x - rhs.x, y - rhs.y, z - rhs.z);
 }

 public void subtract(Vec3 rhs) {
   x -= rhs.x;
   y -= rhs.y;
   z -= rhs.z;
 }

 public Vec3 times(float rhs) {
   return new Vec3(x * rhs, y * rhs, z * rhs);
 }

 public void mul(float rhs) {
   x *= rhs;
   y *= rhs;
   z *= rhs;
 }

 public void clampToLength(float maxL) {
   float magnitude = sqrt(x * x + y * y + z * z);
   if (magnitude > maxL) {
     x *= maxL / magnitude;
     y *= maxL / magnitude;
     z *= maxL / magnitude;
   }
 }

 public void setToLength(float newL) {
   float magnitude = sqrt(x * x + y * y + z * z);
   x *= newL / magnitude;
   y *= newL / magnitude;
   z *= newL / magnitude;
 }

 public void normalize() {
   float magnitude = sqrt(x * x + y * y + z * z);
   x /= magnitude;
   y /= magnitude;
   z /= magnitude;
 }

 public Vec3 normalized() {
   float magnitude = sqrt(x * x + y * y + z * z);
   return new Vec3(x / magnitude, y / magnitude, z / magnitude);
 }

 public float distanceTo(Vec3 rhs) {
   float dx = rhs.x - x;
   float dy = rhs.y - y;
   float dz = rhs.z - z;
   return sqrt(dx * dx + dy * dy + dz * dz);
}

Vec3 interpolate(Vec3 a, Vec3 b, float t) {
 return a.plus((b.minus(a)).times(t));
}

float interpolate(float a, float b, float t) {
 return a + ((b - a) * t);
}

float dot(Vec3 a, Vec3 b) {
 return a.x * b.x + a.y * b.y + a.z * b.z;
}

// 2D cross product is a funny concept
// ...its the 3D cross product but with z = 0
// ... (only the resulting z component is not zero so we just store it as a scalar)
// float cross(Vec3 a, Vec3 b) {
//  return a.x * b.y - a.y * b.x;
// }
Vec3 cross(Vec3 a, Vec3 b) {
  float crossX = a.y * b.z - a.z * b.y;
  float crossY = a.z * b.x - a.x * b.z;
  float crossZ = a.x * b.y - a.y * b.x;

  return new Vec3(crossX, crossY, crossZ);
}


Vec3 projAB(Vec3 a, Vec3 b) {
 return b.times(a.x * b.x + a.y * b.y + a.z * b.z);
}

// Vec3 perpendicular(Vec3 a) {
//  return new Vec3(-a.y, a.x);
// }

Vec3 perpendicular(Vec3 a) {
  // Using the cross product with the unit vector along the x-axis, y-axis or z-axis
  // depending on the given vector to ensure we don't cross with a zero vector
  Vec3 b;
  if (a.x != 0 || a.y != 0) {
      b = new Vec3(0, 0, 1); // Using unit z-axis vector
  } else {
      b = new Vec3(0, 1, 0); // Using unit y-axis vector if a is along the z-axis
  }
  return cross(a, b);
}
}


//boolean colliding(Circle c1, Circle c2){ // check
//    float dist = (c2.center.minus(c1.center)).length();
//    return dist <= (c1.radius + c2.radius);
//}



// Camera

class Camera
{
 Camera()
 {
   position      = new PVector( 0, 0, 0 ); // initial position
   theta         = 0; // rotation around Y axis. Starts with forward direction as ( 0, 0, -1 )
   phi           = 0; // rotation around X axis. Starts with up direction as ( 0, 1, 0 )
   moveSpeed     = 50;
   turnSpeed     = 1.57; // radians/sec
   boostSpeed    = 10;  // extra speed boost for when you press shift
    
   // dont need to change these
   shiftPressed = false;
   negativeMovement = new PVector( 0, 0, 0 );
   positiveMovement = new PVector( 0, 0, 0 );
   negativeTurn     = new PVector( 0, 0 ); // .x for theta, .y for phi
   positiveTurn     = new PVector( 0, 0 );
   fovy             = PI / 4;
   aspectRatio      = width / (float) height;
   nearPlane        = 0.1;
   farPlane         = 10000;
 }
void Update(float dt)
 {
   theta += turnSpeed * ( negativeTurn.x + positiveTurn.x)*dt;
    
   // cap the rotation about the X axis to be less than 90 degrees to avoid gimble lock
   float maxAngleInRadians = 85 * PI / 180;
   phi = min( maxAngleInRadians, max( -maxAngleInRadians, phi + turnSpeed * ( negativeTurn.y + positiveTurn.y ) * dt ) );
    
   // re-orienting the angles to match the wikipedia formulas: https://en.wikipedia.org/wiki/Spherical_coordinate_system
   // except that their theta and phi are named opposite
   float t = theta + PI / 2;
   float p = phi + PI / 2;
   PVector forwardDir = new PVector( sin( p ) * cos( t ),   cos( p ),   -sin( p ) * sin ( t ) );
   PVector upDir      = new PVector( sin( phi ) * cos( t ), cos( phi ), -sin( t ) * sin( phi ) );
   PVector rightDir   = new PVector( cos( theta ), 0, -sin( theta ) );
   PVector velocity   = new PVector( negativeMovement.x + positiveMovement.x, negativeMovement.y + positiveMovement.y, negativeMovement.z + positiveMovement.z );
   position.add( PVector.mult( forwardDir, moveSpeed * velocity.z * dt ) );
   position.add( PVector.mult( upDir,      moveSpeed * velocity.y * dt ) );
   position.add( PVector.mult( rightDir,   moveSpeed * velocity.x * dt ) );
    
   aspectRatio = width / (float) height;
   perspective( fovy, aspectRatio, nearPlane, farPlane );
   camera( position.x, position.y, position.z,
           position.x + forwardDir.x, position.y + forwardDir.y, position.z + forwardDir.z,
           upDir.x, upDir.y, upDir.z );
 }
  
 // only need to change if you want difrent keys for the controls
 void HandleKeyPressed()
 {
   if ( key == 'w' || key == 'W' ) positiveMovement.z = 1;
   if ( key == 's' || key == 'S' ) negativeMovement.z = -1;
   if ( key == 'a' || key == 'A' ) negativeMovement.x = -1;
   if ( key == 'd' || key == 'D' ) positiveMovement.x = 1;
   if ( key == 'q' || key == 'Q' ) positiveMovement.y = 1;
   if ( key == 'e' || key == 'E' ) negativeMovement.y = -1;
    
   if ( key == 'r' || key == 'R' ){
    //  Camera defaults = new Camera();
    //  position = defaults.position;
    //  theta = defaults.theta;
    //  phi = defaults.phi;
    position = new PVector(409.45, 300, -2378.703);
    theta = -118.64556;
    phi = -0.048;
    obstacle.pos = new Vec3(300.77/scene_scale, 340/scene_scale, -2555/scene_scale);

    for (int i = 0; i < col_num; i++) {
      for (int j = 0; j < row_num; j++) {
        nodes_mesh[i][j] = new Node(new Vec3(base_pos.x + j * link_length, base_pos.y, base_pos.z - i * link_length));
        // nodes_mesh[i][j].radius = 0.05 * scene_scale;
        nodes_mesh[i][j].radius = 0.05;
      }
    }
   }
    
   if ( keyCode == LEFT )  negativeTurn.x = 1;
   if ( keyCode == RIGHT ) positiveTurn.x = -0.5;
   if ( keyCode == UP )    positiveTurn.y = 0.5;
   if ( keyCode == DOWN )  negativeTurn.y = -1;
    
   if ( keyCode == SHIFT ) shiftPressed = true; 
   if (shiftPressed){
     positiveMovement.mult(boostSpeed);
     negativeMovement.mult(boostSpeed);
   }

   if ( key == 'p' || key == 'P'){
     println("position:", position.x, position.y, position.z);
     println("theta:", theta);
     println("phi:", phi);

   }
 }

   void HandleKeyReleased()
 {
   if ( key == 'w' || key == 'W' ) positiveMovement.z = 0;
   if ( key == 'q' || key == 'Q' ) positiveMovement.y = 0;
   if ( key == 'd' || key == 'D' ) positiveMovement.x = 0;
   if ( key == 'a' || key == 'A' ) negativeMovement.x = 0;
   if ( key == 's' || key == 'S' ) negativeMovement.z = 0;
   if ( key == 'e' || key == 'E' ) negativeMovement.y = 0;
    
   if ( keyCode == LEFT  ) negativeTurn.x = 0;
   if ( keyCode == RIGHT ) positiveTurn.x = 0;
   if ( keyCode == UP    ) positiveTurn.y = 0;
   if ( keyCode == DOWN  ) negativeTurn.y = 0;
    
   if ( keyCode == SHIFT ){
     shiftPressed = false;
     positiveMovement.mult(1.0/boostSpeed);
     negativeMovement.mult(1.0/boostSpeed);
   }
 }
  
 // only necessary to change if you want different start position, orientation, or speeds
 PVector position;
 float theta;
 float phi;
 float moveSpeed;
 float turnSpeed;
 float boostSpeed;
  
 // probably don't need / want to change any of the below variables
 float fovy;
 float aspectRatio;
 float nearPlane;
 float farPlane;  
 PVector negativeMovement;
 PVector positiveMovement;
 PVector negativeTurn;
 PVector positiveTurn;
 boolean shiftPressed;
};
