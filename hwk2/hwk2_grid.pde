// import processing.data.*;

// // Create a Table object
// Table table;

// // Node struct
// class Node {
//   Vec2 pos;
//   Vec2 vel;
//   Vec2 last_pos;

//   Node(Vec2 pos) {
//     this.pos = pos;
//     this.vel = new Vec2(0, 0);
//     this.last_pos = pos;
//   }
// }

// Camera camera;
// float link_length = 0.2;
// int previous_second = 0;
// int total_second = 0;

// // Nodes
// Vec2 base_pos = new Vec2(5, 5);
// Vec2[] base_poses = new Vec2[] {new Vec2(5, 5), new Vec2(5, 5),new Vec2(5, 5), new Vec2(5, 5), new Vec2(5, 5)};
// Node[] nodes = new Node[20];
// Node[][] nodes_mesh = new Node[5][5];


// void setup() {
//   size(500, 500, P3D);
//   surface.setTitle("hwk2");
//   table = new Table();
//   //table.setTitle("dataset 1 with subsets=", sub_steps);
//   table.addColumn("Time");
//   table.addColumn("ERROR");
//   // writer = createWriter("dataset 1 with subsets=", sub_steps);
//   scene_scale = width / 10.0f;
//   camera = new Camera();
//   camera.position = new PVector(361, 254, 321);
//   camera.theta = -12.328;
//   camera.phi = -0.07;
//   smooth(8);
//   specular(120, 120, 180);
//   ambientLight(90, 90, 90);
//   lightSpecular(255, 255, 255);
//   shininess(20);
//   directionalLight(361, 254, 321, -1, 1, -1);

//   for (int i = 0; i < 5; i++) {
//     for (int j = 0; j < 5; j++) {
//       nodes_mesh[i][j] = new Node(new Vec2(base_pos.x + i * link_length, base_pos.y));
//     }
//   }
// }


// // Gravity
// Vec2 gravity = new Vec2(0, 10);


// // Scaling factor for the scene
// float scene_scale = width / 10.0f;

// // Physics Parameters
// int relaxation_steps = 1;
// int sub_steps = 100;

// void keyPressed()
// {
//   if (key == ' ') {
//     paused = !paused;
//   }else if (key == 'l'){
//     println("writing csv file");
//     String title = "datasetWithSubsets_" + sub_steps + "RelaSteps_" + relaxation_steps + "Error.csv";
//     // String title = "datasetWithSubsets_" + sub_steps + "RelaSteps_" + relaxation_steps + ".csv";
//     saveTable(table, title);
//   }
//   camera.HandleKeyPressed();
// }

// void keyReleased()
// {
//   camera.HandleKeyReleased();
// }

// float total_length_error(){
//   float ideal_length = link_length * 19;
//   float actual_length = 0;
//   for (int i = 0; i < nodes_mesh.length; i++) {
//     for (int j = 1; j < nodes_mesh[0].length; j++) {
//       actual_length += (nodes_mesh[i][j].pos.minus(nodes_mesh[i][j-1].pos)).length();
//     }
//   }
//   for (int i = 1; i < nodes_mesh.length; i++) {
//     actual_length += (nodes_mesh[i][0].pos.minus(nodes_mesh[i-1][0].pos)).length();
//   }

//   return ideal_length - actual_length;
// }

// float total_energy(){
//   float kinetic_energy = 0;
//   float potential_energy = 0; // PE = m*g*h

//   for (int i = 0; i < nodes_mesh.length; i++) {
//     for (int j = 0; j < nodes_mesh[0].length; j++) {
//       kinetic_energy += 0.5 * nodes_mesh[i][j].vel.lengthSqr();

//       float height_base = (height - nodes_mesh[i][j].pos.y * scene_scale) / scene_scale;
//       potential_energy += gravity.length() * height_base;
//     }
//   }

//   float total_energy = kinetic_energy + potential_energy;
//   // println("t:", time, " energy:", total_energy);
//   return total_energy;
// }

// void update_physics(float dt) {
//   // Semi-implicit Integration

//   for (int i = 0; i < nodes_mesh.length; i++) {
//     for (int j = 0; j < nodes_mesh[0].length; j++) {
//       nodes_mesh[i][j].last_pos = nodes_mesh[i][j].pos;
//       nodes_mesh[i][j].vel = nodes_mesh[i][j].vel.plus(gravity.times(dt));
//       nodes_mesh[i][j].pos = nodes_mesh[i][j].pos.plus(nodes_mesh[i][j].vel.times(dt));
//     }
//   }
  

//   // Constrain the distance between nodes to the link length
//   for (int k = 0; k < relaxation_steps; k++) {
//     for (int i = 0; i < nodes_mesh.length; i++) {
//       for (int j = 1; j < nodes_mesh[0].length; j++) {
//         Vec2 delta = nodes_mesh[i][j].pos.minus(nodes_mesh[i][j-1].pos);
//         float delta_len = delta.length();
//         float correction = delta_len - link_length;
//         Vec2 delta_normalized = delta.normalized();
//         nodes_mesh[i][j].pos = nodes_mesh[i][j].pos.minus(delta_normalized.times(correction / 2));
//         nodes_mesh[i][j-1].pos = nodes_mesh[i][j-1].pos.plus(delta_normalized.times(correction / 2));
//       }
//       nodes_mesh[i][0].pos = base_poses[i];
//     }
//   }
//   for (int j = 0; j < nodes.length; j++) {
//     nodes[j].vel = nodes[j].pos.minus(nodes[j].last_pos).times(1 / dt);
//   }

//   for (int i = 0; i < nodes_mesh.length; i++) {
//     for (int j = 0; j < nodes_mesh[0].length; j++) {
//       nodes_mesh[i][j].vel = nodes_mesh[i][j].pos.minus(nodes_mesh[i][j].last_pos).times(1 / dt);
//     }
//   }

//   println("total length error: ", total_length_error());
// }

// boolean paused = false;

// float time = 0;
// void draw() {
//   float dt = 1.0 / 20; //Dynamic dt: 1/frameRate;
//   camera.Update(dt);
//   if (!paused) {
//     for (int i = 0; i < sub_steps; i++) {
//       time += dt / sub_steps;
//       if (second() != previous_second && time < 30){
//         TableRow newRow = table.addRow();
//         newRow.setFloat("Time", time);
//         newRow.setFloat("ERROR", total_length_error());
//         writer.println(second())
//       }else{
//         println("press l");
//       }
//       update_physics(dt / sub_steps);
//     }
//   }

//   // Compute the total energy (should be conserved)
//   total_energy();


//   background(255);
//   stroke(0);
//   strokeWeight(2);
//   // Draw Nodes (green with black outline)
//   //fill(0, 255, 0);
//   fill(0,200,100);          //Green material


//   for (int i = 0; i < nodes_mesh.length; i++) {
//     for (int j = 0; j < nodes_mesh[0].length; j++) {
//       pushMatrix();
//       stroke(0);
//       strokeWeight(0.02 * scene_scale);
//       translate(nodes_mesh[i][j].pos.x * scene_scale, nodes_mesh[i][j].pos.y * scene_scale, -50 - (i * link_length * scene_scale));
//       sphere(0.07 * scene_scale);
//       popMatrix();

//       if (j < nodes_mesh[0].length-1){
//         pushMatrix();
//         line(nodes_mesh[i][j].pos.x * scene_scale, nodes_mesh[i][j].pos.y * scene_scale, -50 - (i * link_length * scene_scale), nodes_mesh[i][j+1].pos.x * scene_scale, nodes_mesh[i][j+1].pos.y * scene_scale, -50 - (i * link_length * scene_scale));
//         popMatrix();
//       }
//     }

//     if (i < nodes_mesh.length-1){
//       pushMatrix();
//       line(nodes_mesh[i][0].pos.x * scene_scale, nodes_mesh[i][0].pos.y * scene_scale, -50- (i * link_length * scene_scale), nodes_mesh[i+1][0].pos.x * scene_scale, nodes_mesh[i+1][0].pos.y * scene_scale, -50 - (i * link_length * scene_scale));
//       popMatrix();
//     }
//   }

// s}



// //---------------
// //Vec 2 Library
// //---------------

// //Vector Library
// //CSCI 5611 Vector 2 Library [Example]
// // Stephen J. Guy <sjguy@umn.edu>

// public class Vec2 {
//   public float x, y;

//   public Vec2(float x, float y) {
//     this.x = x;
//     this.y = y;
//   }

//   public String toString() {
//     return "(" + x + "," + y + ")";
//   }

//   public float length() {
//     return sqrt(x * x + y * y);
//   }

//   public float lengthSqr() {
//     return x * x + y * y;
//   }

//   public Vec2 plus(Vec2 rhs) {
//     return new Vec2(x + rhs.x, y + rhs.y);
//   }

//   public void add(Vec2 rhs) {
//     x += rhs.x;
//     y += rhs.y;
//   }

//   public Vec2 minus(Vec2 rhs) {
//     return new Vec2(x - rhs.x, y - rhs.y);
//   }

//   public void subtract(Vec2 rhs) {
//     x -= rhs.x;
//     y -= rhs.y;
//   }

//   public Vec2 times(float rhs) {
//     return new Vec2(x * rhs, y * rhs);
//   }

//   public void mul(float rhs) {
//     x *= rhs;
//     y *= rhs;
//   }

//   public void clampToLength(float maxL) {
//     float magnitude = sqrt(x * x + y * y);
//     if (magnitude > maxL) {
//       x *= maxL / magnitude;
//       y *= maxL / magnitude;
//     }
//   }

//   public void setToLength(float newL) {
//     float magnitude = sqrt(x * x + y * y);
//     x *= newL / magnitude;
//     y *= newL / magnitude;
//   }

//   public void normalize() {
//     float magnitude = sqrt(x * x + y * y);
//     x /= magnitude;
//     y /= magnitude;
//   }

//   public Vec2 normalized() {
//     float magnitude = sqrt(x * x + y * y);
//     return new Vec2(x / magnitude, y / magnitude);
//   }

//   public float distanceTo(Vec2 rhs) {
//     float dx = rhs.x - x;
//     float dy = rhs.y - y;
//     return sqrt(dx * dx + dy * dy);
//   }
// }

// Vec2 interpolate(Vec2 a, Vec2 b, float t) {
//   return a.plus((b.minus(a)).times(t));
// }

// float interpolate(float a, float b, float t) {
//   return a + ((b - a) * t);
// }

// float dot(Vec2 a, Vec2 b) {
//   return a.x * b.x + a.y * b.y;
// }

// // 2D cross product is a funny concept
// // ...its the 3D cross product but with z = 0
// // ... (only the resulting z component is not zero so we just store it as a scalar)
// float cross(Vec2 a, Vec2 b) {
//   return a.x * b.y - a.y * b.x;
// }

// Vec2 projAB(Vec2 a, Vec2 b) {
//   return b.times(a.x * b.x + a.y * b.y);
// }

// Vec2 perpendicular(Vec2 a) {
//   return new Vec2(-a.y, a.x);
// }


// // Camera

// class Camera
// {
//   Camera()
//   {
//     position      = new PVector( 0, 0, 0 ); // initial position
//     theta         = 0; // rotation around Y axis. Starts with forward direction as ( 0, 0, -1 )
//     phi           = 0; // rotation around X axis. Starts with up direction as ( 0, 1, 0 )
//     moveSpeed     = 50;
//     turnSpeed     = 1.57; // radians/sec
//     boostSpeed    = 10;  // extra speed boost for when you press shift
    
//     // dont need to change these
//     shiftPressed = false;
//     negativeMovement = new PVector( 0, 0, 0 );
//     positiveMovement = new PVector( 0, 0, 0 );
//     negativeTurn     = new PVector( 0, 0 ); // .x for theta, .y for phi
//     positiveTurn     = new PVector( 0, 0 );
//     fovy             = PI / 4;
//     aspectRatio      = width / (float) height;
//     nearPlane        = 0.1;
//     farPlane         = 10000;
//   }
// void Update(float dt)
//   {
//     theta += turnSpeed * ( negativeTurn.x + positiveTurn.x)*dt;
    
//     // cap the rotation about the X axis to be less than 90 degrees to avoid gimble lock
//     float maxAngleInRadians = 85 * PI / 180;
//     phi = min( maxAngleInRadians, max( -maxAngleInRadians, phi + turnSpeed * ( negativeTurn.y + positiveTurn.y ) * dt ) );
    
//     // re-orienting the angles to match the wikipedia formulas: https://en.wikipedia.org/wiki/Spherical_coordinate_system
//     // except that their theta and phi are named opposite
//     float t = theta + PI / 2;
//     float p = phi + PI / 2;
//     PVector forwardDir = new PVector( sin( p ) * cos( t ),   cos( p ),   -sin( p ) * sin ( t ) );
//     PVector upDir      = new PVector( sin( phi ) * cos( t ), cos( phi ), -sin( t ) * sin( phi ) );
//     PVector rightDir   = new PVector( cos( theta ), 0, -sin( theta ) );
//     PVector velocity   = new PVector( negativeMovement.x + positiveMovement.x, negativeMovement.y + positiveMovement.y, negativeMovement.z + positiveMovement.z );
//     position.add( PVector.mult( forwardDir, moveSpeed * velocity.z * dt ) );
//     position.add( PVector.mult( upDir,      moveSpeed * velocity.y * dt ) );
//     position.add( PVector.mult( rightDir,   moveSpeed * velocity.x * dt ) );
    
//     aspectRatio = width / (float) height;
//     perspective( fovy, aspectRatio, nearPlane, farPlane );
//     camera( position.x, position.y, position.z,
//             position.x + forwardDir.x, position.y + forwardDir.y, position.z + forwardDir.z,
//             upDir.x, upDir.y, upDir.z );
//   }
  
//   // only need to change if you want difrent keys for the controls
//   void HandleKeyPressed()
//   {
//     if ( key == 'w' || key == 'W' ) positiveMovement.z = 1;
//     if ( key == 's' || key == 'S' ) negativeMovement.z = -1;
//     if ( key == 'a' || key == 'A' ) negativeMovement.x = -1;
//     if ( key == 'd' || key == 'D' ) positiveMovement.x = 1;
//     if ( key == 'q' || key == 'Q' ) positiveMovement.y = 1;
//     if ( key == 'e' || key == 'E' ) negativeMovement.y = -1;
    
//     if ( key == 'r' || key == 'R' ){
//       Camera defaults = new Camera();
//       position = defaults.position;
//       theta = defaults.theta;
//       phi = defaults.phi;
//     }
    
//     if ( keyCode == LEFT )  negativeTurn.x = 1;
//     if ( keyCode == RIGHT ) positiveTurn.x = -0.5;
//     if ( keyCode == UP )    positiveTurn.y = 0.5;
//     if ( keyCode == DOWN )  negativeTurn.y = -1;
    
//     if ( keyCode == SHIFT ) shiftPressed = true; 
//     if (shiftPressed){
//       positiveMovement.mult(boostSpeed);
//       negativeMovement.mult(boostSpeed);
//     }

//     if ( key == 'p' || key == 'P'){
//       println("position:", position.x, position.y, position.z);
//       println("theta:", theta);
//       println("phi:", phi);
//     }
    
//   }

//     void HandleKeyReleased()
//   {
//     if ( key == 'w' || key == 'W' ) positiveMovement.z = 0;
//     if ( key == 'q' || key == 'Q' ) positiveMovement.y = 0;
//     if ( key == 'd' || key == 'D' ) positiveMovement.x = 0;
//     if ( key == 'a' || key == 'A' ) negativeMovement.x = 0;
//     if ( key == 's' || key == 'S' ) negativeMovement.z = 0;
//     if ( key == 'e' || key == 'E' ) negativeMovement.y = 0;
    
//     if ( keyCode == LEFT  ) negativeTurn.x = 0;
//     if ( keyCode == RIGHT ) positiveTurn.x = 0;
//     if ( keyCode == UP    ) positiveTurn.y = 0;
//     if ( keyCode == DOWN  ) negativeTurn.y = 0;
    
//     if ( keyCode == SHIFT ){
//       shiftPressed = false;
//       positiveMovement.mult(1.0/boostSpeed);
//       negativeMovement.mult(1.0/boostSpeed);
//     }
//   }
  
//   // only necessary to change if you want different start position, orientation, or speeds
//   PVector position;
//   float theta;
//   float phi;
//   float moveSpeed;
//   float turnSpeed;
//   float boostSpeed;
  
//   // probably don't need / want to change any of the below variables
//   float fovy;
//   float aspectRatio;
//   float nearPlane;
//   float farPlane;  
//   PVector negativeMovement;
//   PVector positiveMovement;
//   PVector negativeTurn;
//   PVector positiveTurn;
//   boolean shiftPressed;
// };
