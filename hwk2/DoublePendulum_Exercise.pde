// // Double Pendulum
// // CSCI 5611 Physical Simulation [Exercise]
// // Stephen J. Guy <sjguy@umn.edu>

// // This code is a simple example of a physics simulation
// // using Position Based Dynamics to simulate a double pendulum.

// // 1. In this example I scale the scene so that the window is 10 units wide (so we can think in meters rather 
// //    than pixels). Confirm I'm doing this math correctly by printing out the height of the base node and node 1.
// //    It should be about 5 meters for the base (since the base is at (5, 5)) and 4 meters for node 1 (since it's 
// //    a meter below the base). Remember that the y axis is flipped in Processing (so the top of the screen is 0).
// // 2. Currently, I am only computing the kinetic energy of the base and node 1. Update the energy computation to
// //    to also compute the potential energy of the base and node 1. The potential energy of a node is given by:
// //    PE = m * g * h, where m is the mass of the node, g is the acceleration due to gravity, and h is the height
// //    of the node. (Assume the mass of each node is 1 kg).
// //    HINT: The total energy should be ~100 J (KE + PE) at the start of the simulation.
// // 3. Right now, we are only simulating a single pendulum (base and a single node attached to it). Add a second
// //    node to the rendering. The second node should be attached to the first node with a link length of 1 meter.
// //    Draw both the node and the link to the node. The second node should be at (7, 5) at the start of the simulation.
// //    Don't worry about simulating the second node yet, we'll do that in the next step.
// // 4. Once the node and the link are rendering correctly, it's time to update the simulation to animate the new node.
// //    First update the physics simulation to compute the position, velocity, and last_position of the second node.
// //    Then update the constraint solver to constrain the distance between the first and second node to the link length.
// //    Finally, update the velocity of the new node based on constraint resolution.
// //    With this step complete, you should have a working double pendulum simulation.
// // 5. Update the energy computation to also compute the kinetic and potential energy of the second node, and account
// //    for this energy in the total energy computation. 
// //    HINT: The total energy should now be ~150 J (KE + PE) at the start of the simulation.
// // 6. In theory, the total energy of the system should be conserved. However, if you run the simulation for a while
// //    you'll notice that the total energy slowly increases due to inaccuracies in our numerical integration. To fix
// //    this we can use more sub-steps in our simulation. 
// //    How many simulation sub-step are needed such that we loose less than 10% of the total energy after 1 minute of
// //    simulated time has passed?

// // Challenge:
// //  - Add a third node to the pendulum
// //  - Move your simulation to 3D. You'll need to add a z coordinate to the nodes and links, and update the rendering
// //    but the physics simulation should be the same!

// Camera camera;

// void setup() {
//   size(500, 500, P3D);
//   surface.setTitle("Double Pendulum");
//   scene_scale = width / 10.0f;
//   camera = new Camera();
//   camera.position = new PVector(322, 217, 163.21);
//   camera.theta = -12.128;
//   camera.phi = -0.345;
// }

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

// // Link length
// float link_length = 1.0;

// // Nodes
// Vec2 base_pos = new Vec2(5, 5);
// Node base = new Node(base_pos);
// Node node1 = new Node(new Vec2(6, 5));
// Node node2 = new Node(new Vec2(7, 5)); // TODO: Add this node 

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
//   }
//   camera.HandleKeyPressed();
// }

// void keyReleased()
// {
//   camera.HandleKeyReleased();
// }


// void update_physics(float dt) {
//   // Semi-implicit Integration
//   node1.last_pos = node1.pos;
//   node1.vel = node1.vel.plus(gravity.times(dt));
//   node1.pos = node1.pos.plus(node1.vel.times(dt));

//   // TODO: Simulate node 2's position & velocity
//   node2.last_pos = node2.pos;
//   node2.vel = node2.vel.plus(gravity.times(dt));
//   node2.pos = node2.pos.plus(node2.vel.times(dt));

//   // Constrain the distance between nodes to the link length
//   for (int i = 0; i < 4; i++) {
//     Vec2 delta = node1.pos.minus(base.pos);
//     float delta_len = delta.length();
//     float correction = delta_len - link_length;
//     Vec2 delta_normalized = delta.normalized();
//     node1.pos = node1.pos.minus(delta_normalized.times(correction / 2));
//     base.pos = base.pos.plus(delta_normalized.times(correction / 2));

//     // TODO: Constrain distance between node2 and node1
//     //       Make sure you update the position of both notes!
//     Vec2 delta2 = node2.pos.minus(node1.pos);
//     float delta2_len = delta2.length();
//     float correction2 = delta2_len - link_length;
//     Vec2 delta2_normalized = delta2.normalized();
//     node2.pos = node2.pos.minus(delta2_normalized.times(correction2 / 2));
//     node1.pos = node1.pos.plus(delta2_normalized.times(correction2 / 2));

//     base.pos = base_pos; // Fix the base node in place
//   }

//   // Update the velocities (PBD)
//   base.vel = base.pos.minus(base.last_pos).times(1 / dt);
//   node1.vel = node1.pos.minus(node1.last_pos).times(1 / dt);
//   node2.vel = node2.pos.minus(node2.last_pos).times(1 / dt);
//   // TODO: Update the velocity of node 2 based on its positions
// }

// boolean paused = false;

// // void keyPressed() {
// //   if (key == ' ') {
// //     paused = !paused;
// //   }
// // }

// float time = 0;
// void draw() {
//   float dt = 1.0 / 20; //Dynamic dt: 1/frameRate;
//   camera.Update(dt);
//   if (!paused) {
//     for (int i = 0; i < sub_steps; i++) {
//       time += dt / sub_steps;
//       update_physics(dt / sub_steps);
//     }
//   }

//   // Compute the total energy (should be conserved)
//   float kinetic_energy = 0;
//   kinetic_energy += 0.5 * base.vel.lengthSqr(); // KE = (1/2) * m * v^2
//   kinetic_energy += 0.5 * node1.vel.lengthSqr();
//   kinetic_energy += 0.5 * node2.vel.lengthSqr();

//   float height_base = (height - base.pos.y * scene_scale) / scene_scale;
//   float height_1 = (height - node1.pos.y * scene_scale) / scene_scale; // height of node 1
//   float height_2 = (height - node2.pos.y * scene_scale) / scene_scale; // height of node 2
//   // TODO: Print out height_base, and height_1
//   println("height_base:", height_base);
//   println("height_1:", height_1);
//   println("height_2:", height_2);

//   float potential_energy = 0; // PE = m*g*h
//   potential_energy += gravity.length() * height_base;
//   potential_energy += gravity.length() * height_1;
//   potential_energy += gravity.length() * height_2;
//   float total_energy = kinetic_energy + potential_energy;
//   println("t:", time, " energy:", total_energy);

//   background(255);
//   stroke(0);
//   strokeWeight(2);

//   // Draw Nodes (green with black outline)
//   //fill(0, 255, 0);
//   fill(0,200,100);          //Green material
  
//   specular(120, 120, 180);  //Setup lights… 
//   ambientLight(90,90,90);   //More light…
//   lightSpecular(255,255,255); shininess(20);  //More light…
//   directionalLight(200, 200, 200, -1, 1, -1); //More light…
//   pushMatrix();
//   stroke(0);
//   strokeWeight(0.02 * scene_scale);
//   translate(base.pos.x * scene_scale, base.pos.y * scene_scale, -50);
//   sphere(0.3 * scene_scale);
//   popMatrix();

//   pushMatrix();
//   translate(node1.pos.x * scene_scale, node1.pos.y * scene_scale, -50);
//   sphere(0.3 * scene_scale);
//     popMatrix();

//   pushMatrix();
//   translate(node2.pos.x * scene_scale, node2.pos.y * scene_scale, -50);
//   sphere(0.3 * scene_scale);
//     popMatrix();

//   // translate(-node2.pos.x * scene_scale, -node2.pos.y * scene_scale, 50);

//   //ellipse(base.pos.x * scene_scale, base.pos.y * scene_scale, 0.3 * scene_scale, 0.3 * scene_scale);
//   //ellipse(node1.pos.x * scene_scale, node1.pos.y * scene_scale, 0.3 * scene_scale, 0.3 * scene_scale);
//   //// TODO: Draw node_2
//   //ellipse(node2.pos.x * scene_scale, node2.pos.y * scene_scale, 0.3 * scene_scale, 0.3 * scene_scale);

//   // Draw Links (black)
//   stroke(0);
//   strokeWeight(0.02 * scene_scale);
//   line(base.pos.x * scene_scale, base.pos.y * scene_scale, -50, node1.pos.x * scene_scale, node1.pos.y * scene_scale, -50);
//   line(node1.pos.x * scene_scale, node1.pos.y * scene_scale, -50, node2.pos.x * scene_scale, node2.pos.y * scene_scale, -50);
//   // TODO: Add link between node_1 and node_2
// }



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
