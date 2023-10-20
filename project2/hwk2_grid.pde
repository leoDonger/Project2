import java.util.HashSet;

// Node struct
class Node {
 Vec3 pos;
 Vec3 vel;
 Vec3 last_pos;
 float radius;

 Node(Vec3 pos) {
   this.pos = pos;
   this.vel = new Vec3(0, 0, 0);
   this.last_pos = pos;
   this.radius = 0;
 }
}

boolean colliding(Node c1, Node c2){
  float dist = (c2.pos.minus(c1.pos)).length();
  return dist <= (c1.radius + c2.radius);
}

float dot(Vec3 a, Vec3 b) {
 return a.x * b.x + a.y * b.y + a.z * b.z;
}

Vec3 cross(Vec3 a, Vec3 b) {
  float crossX = a.y * b.z - a.z * b.y;
  float crossY = a.z * b.x - a.x * b.z;
  float crossZ = a.x * b.y - a.y * b.x;

  return new Vec3(crossX, crossY, crossZ);
}

// void air_drag(Node[][] grid, float dt){
//  for (int i = 1; i < grid.length-1; i++) {
//     for (int j = 0; j < grid[i].length-1; j++) {
//       Node one = grid[i][j];
//       Node two = grid[i][j+1];
//       Node three = grid[i+1][j];
//       Node four = grid[i+1][j+1];

//       Vec3 f_total = new Vec3(0, 0, 0);
//       Vec3 v = (one.vel.plus(two.vel).plus(three.vel)).times(1/3).minus(air_v);

//       Vec3 n1 = cross(two.pos.minus(one.pos), three.pos.minus(one.pos)).normalized();
//       Vec3 n2_a_n = n1.times(v.length() * (dot(v, n1)) / (2 * n1.length()));
//       f_total.add(n2_a_n.times(c * -0.5 * p));

//       v = (four.vel.plus(two.vel).plus(three.vel)).times(1/3).minus(air_v);
//       Vec3 n2 = cross(two.pos.minus(four.pos), three.pos.minus(four.pos)).normalized();
//       n2_a_n = n2.times(v.length() * (dot(v, n2)) / (2 * n2.length()));
//       f_total.add(n2_a_n.times(c * -0.5 * p));

//       Vec3 acc = f_total.times(0.25);
//       println(acc.times(dt));
//       grid[i][j].vel = grid[i][j].vel.plus(acc.times(dt));
//       grid[i][j+1].vel = grid[i][j+1].vel.plus(acc.times(dt));
//       grid[i+1][j].vel = grid[i+1][j].vel.plus(acc.times(dt));
//       grid[i+1][j+1].vel = grid[i+1][j+1].vel.plus(acc.times(dt));

//       grid[i][j].pos = grid[i][j].pos.plus(grid[i][j].vel.times(dt));
//       grid[i][j+1].pos = grid[i][j+1].pos.plus(grid[i][j+1].vel.times(dt));
//       grid[i+1][j].pos = grid[i+1][j].pos.plus(grid[i+1][j].vel.times(dt));
//       grid[i+1][j+1].pos = grid[i+1][j+1].pos.plus(grid[i+1][j+1].vel.times(dt));
//     }
//   }
// }


// void air_drag(Node[][] grid, float dt){
//   Vec3[][] forces = new Vec3[grid.length][grid[0].length];  // To store the calculated forces
  
//   // Calculating forces
//   for (int i = 0; i < grid.length - 1; i++) {
//     for (int j = 0; j < grid[i].length - 1; j++) {
//       Node one = grid[i][j];
//       Node two = grid[i][j + 1];
//       Node three = grid[i + 1][j];
//       Node four = grid[i + 1][j + 1];

//       Vec3 f_total = calculateForce(one, two, three, air_v, c, p);
//       f_total.add(calculateForce(four, two, three, air_v, c, p));
      
//       forces[i][j] = f_total;
//       forces[i][j+1] = f_total;
//       forces[i+1][j] = f_total;
//       forces[i+1][j+1] = f_total;
//     }
//   }
  
//   // Applying forces to update velocities and positions
//   for (int i = 0; i < grid.length; i++) {
//     for (int j = 0; j < grid[i].length; j++) {
//       Vec3 acc = forces[i][j].times(0.25);  // Assuming equal distribution of force to nodes
//       grid[i][j].vel = grid[i][j].vel.plus(acc.times(dt));
//       grid[i][j].pos = grid[i][j].pos.plus(grid[i][j].vel.times(dt));
//     }
//   }
// }

// // New function to reduce repeated code
// Vec3 calculateForce(Node one, Node two, Node three, Vec3 air_v, float c, float p) {
//   Vec3 v = one.vel.plus(two.vel).plus(three.vel).times(1/3f).minus(air_v);
//   Vec3 normal = cross(two.pos.minus(one.pos), three.pos.minus(one.pos)).normalized();
//   Vec3 force = normal.times(v.length() * dot(v, normal) / (2 * normal.length())).times(c * -0.5 * p);
//   return force;
// }



void colliding_detection(Node[][] grid, Node obstacle, boolean self_collide){
  for (int i = 0; i < grid.length; i++) {
    for (int j = 0; j < grid[i].length; j++) {
      Node current = grid[i][j];
      if (colliding(current, obstacle)){
        collisionResponseStatic(current, obstacle, 0);
      }
      if (self_collide){
        for (int m = 0; m < grid.length; m++) {
          for (int n = 0; n < grid[m].length; n++) {
            if (i == m && j == n) continue;
            
            Node other = grid[m][n];
            
            if (colliding(current, other)) {
              collisionResponseElastic(current, other, 0.7);
            }
          }
        }
      }
    }
  }
}

void collisionResponseStatic(Node ball1, Node ball2, float cor){
  Vec3 normal = (ball1.pos.minus(ball2.pos)).normalized();
  ball1.pos = ball2.pos.plus(normal.times(ball2.radius+ball1.radius).times(1.05));
  Vec3 velNormal = normal.times(dot(ball1.vel, normal));
  ball1.vel.subtract(velNormal.times(1 + cor));
}

void collisionResponseElastic(Node ball1, Node ball2, float cor){
    Vec3 dir = (ball2.pos.minus(ball1.pos));
    float dist = dir.length();
    if (dist > ball1.radius+ball2.radius) return;
    dir = dir.normalized();

    float overlap = (ball1.radius + ball2.radius - dist) /2;
    ball1.pos.subtract((dir.times(overlap)).times(1.01));
    ball2.pos.add((dir.times(overlap)).times(1.01));


    float v1 = dot(ball1.vel, dir);
    float v2 = dot(ball2.vel, dir);

    float m1 = 0.1;
    float m2 = 0.1;

    float new_v1 = (m1 * v1 + m2 * v2 - m2 * (v1 - v2) * cor) / (m1 + m2);
    float new_v2 = (m1 * v1 + m2 * v2 - m1 * (v2 - v1) * cor) / (m1 + m2);

    ball1.vel.add(dir.times(new_v1 - v1));
    ball2.vel.add(dir.times(new_v2 - v2));
}

PImage img;
PImage ball;
PShape b;
PImage court;
Camera camera;
float link_length = 0.1;
int previous_second = 0;
int total_second = 0;
Node obstacle;
float p = 10;
float c = 50;
Vec3 air_v = new Vec3(1, 0 ,0);


int row_num = 34;
int col_num = 26;
Vec3 base_pos = new Vec3(5, 5, -50);
Node[][] nodes_mesh = new Node[col_num][row_num];
HashSet<IntTuple> intTuples = new HashSet<IntTuple>();
// IntList ripped_x = new IntList();
// IntList ripped_y = new IntList();

void setup() {
  size(500, 500, P3D);
  background(30, 30, 50);
  surface.setTitle("hwk2");
  scene_scale = width / 10.0f;
  camera = new Camera();
  // camera.position = new PVector(360.90, 304, -2432);
  camera.position = new PVector(409.45, 300, -2378.703);
  // camera.theta = -118.64556;
  camera.theta = -118.64;
  // camera.phi = -0.048;
  camera.phi = -0.048;
  smooth(8);

  img = loadImage("Img/rBVaI1kp1IyAMcARAACXUC_H0aY536.jpg");
  ball = loadImage("Img/ball.jpg");
  court = loadImage("Img/court.jpg");
  court.resize(width, height);
  obstacle = new Node(new Vec3(300.77/scene_scale, 340/scene_scale, -2555/scene_scale));
  // obstacle.radius = 0.3 * scene_scale;
  obstacle.radius = 0.5 ;
  noStroke();
  noFill();
  b = createShape(SPHERE, obstacle.radius * scene_scale);
  b.setTexture(ball);
  //mouse = getMouse()

  for (int i = 0; i < col_num; i++) {
    for (int j = 0; j < row_num; j++) {
      nodes_mesh[i][j] = new Node(new Vec3(base_pos.x + j * link_length, base_pos.y, base_pos.z - i * link_length));
      // nodes_mesh[i][j].radius = 0.05 * scene_scale;
      nodes_mesh[i][j].radius = 0.025;
    }
  }
}


// Gravity
Vec3 gravity = new Vec3(0, 3, 0);


// Scaling factor for the sceneS
float scene_scale = width / 10.0f;

// Physics Parameters
int relaxation_steps = 30;
int sub_steps = 3;


void mouseDragged(){
  obstacle.pos = new Vec3(mouseX /scene_scale, mouseY /scene_scale, obstacle.pos.z);
}

// void mouseWheel(MouseEvent event) {
//   float e = event.getCount();
//   obstacle.pos.z += e * 10;
// }

void keyPressed()
{
 if (key == ' ') {
   paused = !paused;
 }else if(key == 'n' || key == 'N'){
  use_air_drag = !use_air_drag;
  println("air drag");
 }
 camera.HandleKeyPressed();
}

void keyReleased()
{
 camera.HandleKeyReleased();
}

float total_length_error(){
 float ideal_length = link_length * 19;
 float actual_length = 0;
 for (int i = 0; i < nodes_mesh.length; i++) {
   for (int j = 1; j < nodes_mesh[0].length; j++) {
     actual_length += (nodes_mesh[i][j].pos.minus(nodes_mesh[i][j-1].pos)).length();
   }
 }
 for (int i = 1; i < nodes_mesh.length; i++) {
   actual_length += (nodes_mesh[i][0].pos.minus(nodes_mesh[i-1][0].pos)).length();
 }

 return ideal_length - actual_length;
}

float total_energy(){
 float kinetic_energy = 0;
 float potential_energy = 0; // PE = m*g*h

 for (int i = 0; i < nodes_mesh.length; i++) {
   for (int j = 0; j < nodes_mesh[0].length; j++) {
     kinetic_energy += 0.5 * nodes_mesh[i][j].vel.lengthSqr();

     float height_base = (height - nodes_mesh[i][j].pos.y * scene_scale) / scene_scale;
     potential_energy += gravity.length() * height_base;
   }
 }

 float total_energy = kinetic_energy + potential_energy;
 // println("t:", time, " energy:", total_energy);
 return total_energy;
}

void update_physics(float dt) {
 // Semi-implicit Integration

  // if(use_air_drag){
  //   air_drag(nodes_mesh, dt);
  // }

  for (int i = 0; i < nodes_mesh.length; i++) {
    for (int j = 0; j < nodes_mesh[0].length; j++) {
      if (use_air_drag){
        if (j<nodes_mesh[0].length-1 && i< nodes_mesh.length-1){
          Node one = nodes_mesh[i][j];
          Node two = nodes_mesh[i][j+1];
          Node three = nodes_mesh[i+1][j];
          Node four = nodes_mesh[i+1][j+1];

          Vec3 f_total = new Vec3(0, 0, 0);
          Vec3 v = (one.vel.plus(two.vel).plus(three.vel)).times(1/3f);
          // Vec3 v2;
          // if (v.x > 0){
          //   if (v.z > 0){
          //     v2 = new Vec3(-1, 0, -1);
          //   }else{
          //     v2 = new Vec3(-1, 0, 1);
          //   }
          // }else{
          //   if (v.z > 0){
          //     v2 = new Vec3(1, 0, -1);
          //   }else{
          //     v2 = new Vec3(1, 0, 1);
          //   }
          // }
          // v = v.minus(v2);

          Vec3 n1 = cross(two.pos.minus(one.pos), three.pos.minus(one.pos));
          Vec3 n2_a_n = n1.times(v.length() * (dot(v, n1)) / (2 * n1.length()));
          f_total.add(n2_a_n.times(c * -0.5f * p));

          // v = (four.vel.plus(two.vel).plus(three.vel)).times(1/3).minus(air_v);
          // Vec3 n2 = cross(two.pos.minus(four.pos), three.pos.minus(four.pos));
          // n2_a_n = n2.times(v.length() * (dot(v, n2)) / (2 * n2.length()));
          // f_total.add(n2_a_n.times(c * -0.5 * p));

          Vec3 acc = f_total.times(0.25);
          // println(acc.times(dt));
          nodes_mesh[i][j].vel = nodes_mesh[i][j].vel.plus(acc.times(dt));
          nodes_mesh[i][j+1].vel = nodes_mesh[i][j+1].vel.plus(acc.times(dt));
          nodes_mesh[i+1][j].vel = nodes_mesh[i+1][j].vel.plus(acc.times(dt));
          nodes_mesh[i+1][j+1].vel = nodes_mesh[i+1][j+1].vel.plus(acc.times(dt));
          }
        }

      nodes_mesh[i][j].last_pos = nodes_mesh[i][j].pos;
      nodes_mesh[i][j].vel = nodes_mesh[i][j].vel.plus(gravity.times(dt));
      nodes_mesh[i][j].pos = nodes_mesh[i][j].pos.plus(nodes_mesh[i][j].vel.times(dt));
    }
  }



  colliding_detection(nodes_mesh, obstacle, true);


 // Constrain the distance between nodes to the link length
  for (int k = 0; k < relaxation_steps; k++) {
    for (int i = 0; i < nodes_mesh.length; i++) {
      for (int j = 1; j < nodes_mesh[0].length; j++) {
        IntTuple a = new IntTuple(i, j);
        IntTuple b = new IntTuple(i, j-1);

        if (!intTuples.contains(a) || !intTuples.contains(b)){
          Vec3 delta = nodes_mesh[i][j].pos.minus(nodes_mesh[i][j-1].pos);
          float delta_len = delta.length();
          if (delta_len != link_length){
            if (delta_len / link_length > 3){
              intTuples.add(a);
              intTuples.add(b);
            }else{
              float correction = delta_len - link_length;
              Vec3 delta_normalized = delta.normalized();
              nodes_mesh[i][j].pos = nodes_mesh[i][j].pos.minus(delta_normalized.times(correction / 2));
              nodes_mesh[i][j-1].pos = nodes_mesh[i][j-1].pos.plus(delta_normalized.times(correction / 2));
            }
          }
        }
        
        if (i > 0) {
          // b = new IntTuple(i-1, j);
          // if (!intTuples.contains(a) || !intTuples.contains(b)){
            Vec3 delta = nodes_mesh[i][j].pos.minus(nodes_mesh[i-1][j].pos);
            float delta_len = delta.length();
            if (delta_len != link_length){
              // if (delta_len / link_length >3){
              //   intTuples.add(a);
              //   intTuples.add(b);
              // }else{
                float correction = delta_len - link_length;
                Vec3 delta_normalized = delta.normalized();
                nodes_mesh[i][j].pos = nodes_mesh[i][j].pos.minus(delta_normalized.times(correction / 2));
                nodes_mesh[i-1][j].pos = nodes_mesh[i-1][j].pos.plus(delta_normalized.times(correction / 2));
              // }
            }
          // }
        }
      }
      nodes_mesh[i][0].pos = base_pos.minus(new Vec3(0, 0, i * link_length));
    }
  }


 for (int i = 0; i < nodes_mesh.length; i++) {
   for (int j = 0; j < nodes_mesh[0].length; j++) {
     nodes_mesh[i][j].vel = nodes_mesh[i][j].pos.minus(nodes_mesh[i][j].last_pos).times(1 / dt);
   }



 }

//   println("total length error: ", total_length_error());
}

boolean paused = false;
boolean use_air_drag = false;

float time = 0;
void draw() {
 float dt = 1.0 / 20; //Dynamic dt: 1/frameRate;
 camera.Update(dt);
 if (!paused) {
   for (int i = 0; i < sub_steps; i++) {
     update_physics(dt / sub_steps);
   }
 }

 // Compute the total energy (should be conserved)
 total_energy();

// background(30, 30, 50);
background(court);

// background(0);

// pushMatrix();
// translate(width / 2, height / 2);
// scale(100);  // Scaling up the quad to cover the whole background
// texture(court);
// beginShape(QUADS);
// vertex(-1, -1, -1, 0, 0);
// vertex( 1, -1, -1, 1, 0);
// vertex( 1,  1, -1, 1, 1);
// vertex(-1,  1, -1, 0, 1);
// endShape();
// popMatrix();

  // stroke(0);
//  noStroke();
//  sphereDetail(170);
//  strokeWeight(2);
 // Draw Nodes (green with black outline)
 //fill(0, 255, 0);
  // fill(0,200,100);          //Green material
  ambient(250, 100, 100);
  // specular(120, 120, 180);
  ambientLight(40, 20,40);
  lightSpecular(255, 215, 215);
  directionalLight(185, 195, 255, -1, 1.25, -1);
  shininess(255);



  pushMatrix();
  noStroke();
  // translate(300.77, 320, -2570);
  translate(obstacle.pos.x * scene_scale, obstacle.pos.y * scene_scale, obstacle.pos.z * scene_scale);
  rotateX(frameCount * 0.01); 
  rotateY(frameCount * 0.01); 
  // texture(ball);
  shape(b);
  // sphere(obstacle.radius * scene_scale);
  popMatrix();


  // float width = 497;
  // float height = 866;

  float xRatio = 497 / nodes_mesh[0].length;
  float yRatio = 866 / nodes_mesh.length;

  int row_length = nodes_mesh[0].length;
  int col_length = nodes_mesh.length;

  // int col = 0;
  // while(col < col_length-1){
  //   int row = 0;
  //   beginShape();
  //   texture(img);
  //   while(row < row_length){
  //     vertex(nodes_mesh[col][row].pos.x * scene_scale, nodes_mesh[col][row].pos.y * scene_scale, nodes_mesh[col][row].pos.z * scene_scale, yRatio * col, xRatio * row);
  //     row++;
  //   }
  //   row--;
  //   col++;
  //   while(row >= 0){
  //     vertex(nodes_mesh[col][row].pos.x * scene_scale, nodes_mesh[col][row].pos.y * scene_scale, nodes_mesh[col][row].pos.z * scene_scale, yRatio * col, xRatio * row);
  //     row--;
  //   }
  //   row++;
  //   endShape();
  // }

  // int row = 0;
  // while(row < row_length-1){
  //   col = 0;
  //   beginShape();
  //   texture(img);
  //   while(col < col_length){
  //     vertex(nodes_mesh[col][row].pos.x * scene_scale, nodes_mesh[col][row].pos.y * scene_scale, nodes_mesh[col][row].pos.z * scene_scale, yRatio * col, xRatio * row);
  //     col++;
  //   }
  //   col--;
  //   row++;
  //   while(col >= 0){
  //     vertex(nodes_mesh[col][row].pos.x * scene_scale, nodes_mesh[col][row].pos.y * scene_scale, nodes_mesh[col][row].pos.z * scene_scale, yRatio * col, xRatio * row);
  //     col--;
  //   }
  //   col++;
  //   endShape();
  // }


for (int row = 0; row < row_length - 1; row++) {
    beginShape(TRIANGLE_STRIP); // Consider specifying the shape type, e.g., TRIANGLE_STRIP
    texture(img);

    for (int col = 0; col < col_length; col++) {
        int nextRow = row + 1; // To fix the increment of 'row' within the loop

        IntTuple a = new IntTuple(col, row);
        IntTuple b = new IntTuple(col, nextRow);
        if (!intTuples.contains(a) || !intTuples.contains(b)){
          vertex(nodes_mesh[col][row].pos.x * scene_scale, nodes_mesh[col][row].pos.y * scene_scale, nodes_mesh[col][row].pos.z * scene_scale, yRatio * col, xRatio * row);
          vertex(nodes_mesh[col][nextRow].pos.x * scene_scale, nodes_mesh[col][nextRow].pos.y * scene_scale, nodes_mesh[col][nextRow].pos.z * scene_scale, yRatio * col, xRatio * nextRow);
        }
    }

    endShape();
}

// for (int col = 0; col < col_length-1; col++) {
//     beginShape(TRIANGLE_STRIP); // Consider specifying the shape type, e.g., TRIANGLE_STRIP
//     texture(img);
//     for (int row = 0; row < row_length; row++) {
//         int nextCol = col + 1; // To fix the increment of 'row' within the loop

//         IntTuple a = new IntTuple(col, row);
//         IntTuple b = new IntTuple(nextCol, row);
//         if (!intTuples.contains(a) || !intTuples.contains(b)){
//           vertex(nodes_mesh[col][row].pos.x * scene_scale, nodes_mesh[col][row].pos.y * scene_scale, nodes_mesh[col][row].pos.z * scene_scale, yRatio * col, xRatio * row);
//           vertex(nodes_mesh[nextCol][row].pos.x * scene_scale, nodes_mesh[nextCol][row].pos.y * scene_scale, nodes_mesh[nextCol][row].pos.z * scene_scale, yRatio * nextCol, xRatio * row);
//         }
//     }
//     endShape();
// }




  // for (int j = 0; j < nodes_mesh[0].length; j++) {
  //   for (int i = 0; i < nodes_mesh.length; i++) {
  //     // pushMatrix();
  //     // stroke(0);
  //     // strokeWeight(0.02 * scene_scale);
  //     // translate(nodes_mesh[i][j].pos.x * scene_scale, nodes_mesh[i][j].pos.y * scene_scale, nodes_mesh[i][j].pos.z * scene_scale);
  //     vertex(nodes_mesh[i][j].pos.x * scene_scale, nodes_mesh[i][j].pos.y * scene_scale, nodes_mesh[i][j].pos.z * scene_scale, xRatio * j, yRatio * i);
  //     // sphere(nodes_mesh[i][j].radius * scene_scale);
  //     // popMatrix();/




  //     // if (j < nodes_mesh[0].length-1){
  //     //   pushMatrix();
  //     //   line(nodes_mesh[i][j].pos.x * scene_scale, nodes_mesh[i][j].pos.y * scene_scale, nodes_mesh[i][j].pos.z * scene_scale, nodes_mesh[i][j+1].pos.x * scene_scale, nodes_mesh[i][j+1].pos.y * scene_scale, nodes_mesh[i][j+1].pos.z * scene_scale);
  //     //   popMatrix();
  //     // }
  //     // if (i < nodes_mesh.length-1){
  //     //   pushMatrix();
  //     //   line(nodes_mesh[i][j].pos.x * scene_scale, nodes_mesh[i][j].pos.y * scene_scale, nodes_mesh[i][j].pos.z * scene_scale, nodes_mesh[i+1][j].pos.x * scene_scale, nodes_mesh[i+1][j].pos.y * scene_scale, nodes_mesh[i+1][j].pos.z * scene_scale);
  //     //   popMatrix();
  //     // }
  //   }
  // }




  // for (int i = 0; i < nodes_mesh.length; i++) {
  //   for (int j = 0; j < nodes_mesh[0].length; j++) {
  //     // pushMatrix();
  //     // stroke(0);
  //     // strokeWeight(0.02 * scene_scale);
  //     // translate(nodes_mesh[i][j].pos.x * scene_scale, nodes_mesh[i][j].pos.y * scene_scale, nodes_mesh[i][j].pos.z * scene_scale);
  //     vertex(nodes_mesh[i][j].pos.x * scene_scale, nodes_mesh[i][j].pos.y * scene_scale, nodes_mesh[i][j].pos.z * scene_scale, xRatio * j, yRatio * i);
  //     // sphere(nodes_mesh[i][j].radius * scene_scale);
  //     // popMatrix();




  //     // if (j < nodes_mesh[0].length-1){
  //     //   pushMatrix();
  //     //   line(nodes_mesh[i][j].pos.x * scene_scale, nodes_mesh[i][j].pos.y * scene_scale, nodes_mesh[i][j].pos.z * scene_scale, nodes_mesh[i][j+1].pos.x * scene_scale, nodes_mesh[i][j+1].pos.y * scene_scale, nodes_mesh[i][j+1].pos.z * scene_scale);
  //     //   popMatrix();
  //     // }
  //     // if (i < nodes_mesh.length-1){
  //     //   pushMatrix();
  //     //   line(nodes_mesh[i][j].pos.x * scene_scale, nodes_mesh[i][j].pos.y * scene_scale, nodes_mesh[i][j].pos.z * scene_scale, nodes_mesh[i+1][j].pos.x * scene_scale, nodes_mesh[i+1][j].pos.y * scene_scale, nodes_mesh[i+1][j].pos.z * scene_scale);
  //     //   popMatrix();
  //     // }
  //   }
  // }
}
