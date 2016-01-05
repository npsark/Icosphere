import damkjer.ocd.*;

PrintWriter fileObj;
Camera camera1;

ArrayList verts = new ArrayList(), orig = new ArrayList();
ArrayList tris = new ArrayList();

float offx;
float offy;
float offz;

boolean str = false;

void setup() {
  size(700, 700, P3D);
  //colorMode(HSB, 360, 100, 100);

  camera1 = new Camera(this, 0, 0, 13);
  mouseClicked();
  noiseSeed(millis());
  

  reset();
}

void reset() {
  verts.clear();
  orig.clear();
  tris.clear();

  float t = (1.0 + sqrt(5.0)) / 2.0;


  addVert(new PVector(-1, t, 0));
  addVert(new PVector( 1, t, 0));
  addVert(new PVector(-1, -t, 0));
  addVert(new PVector( 1, -t, 0));

  addVert(new PVector( 0, -1, t));
  addVert(new PVector( 0, 1, t));
  addVert(new PVector( 0, -1, -t));
  addVert(new PVector( 0, 1, -t));

  addVert(new PVector( t, 0, -1));
  addVert(new PVector( t, 0, 1));
  addVert(new PVector(-t, 0, -1));
  addVert(new PVector(-t, 0, 1));


  addTri(0, 11, 5);
  addTri(0, 5, 1);
  addTri(0, 1, 7);
  addTri(0, 7, 10);
  addTri(0, 10, 11);

  //5 adjacent faces 
  addTri(1, 5, 9);
  addTri(5, 11, 4);
  addTri(11, 10, 2);
  addTri(10, 7, 6);
  addTri(7, 1, 8);

  // 5 faces around point 3
  addTri(3, 9, 4);
  addTri(3, 4, 2);
  addTri(3, 2, 6);
  addTri(3, 6, 8);
  addTri(3, 8, 9);

  // 5 adjacent faces 
  addTri(4, 9, 5);
  addTri(2, 4, 11);
  addTri(6, 2, 10);
  addTri(8, 6, 7);
  addTri(9, 8, 1); 


  //float yo = random(10);
  offx = random(3);
  offy = random(3);
  offz = random(3);
  //println(offx, offy, offz);
}



void addVert(PVector p) {
  //float a = atan2(p.y, p.x);
  //float b = atan2(p.z, p.x);
  //float c = atan2(p.z, p.y);
  float m = 1;
  float length = p.mag()* noise( p.x*m + offx, p.y*m + offy,  p.z*m + offz  );
  verts.add(new PVector(p.x/length, p.y/length, p.z/length));
  //orig.add(new PVector(p.x/length, p.y/length, p.z/length));
}

void updateVerts() {
  for (int i=0; i<verts.size (); i++) {
    PVector v = (PVector)orig.get(i);
    PVector v2 = (PVector)verts.get(i);
    
    float a = atan2(v.y,v.x), b = atan2(v.x,v.z), c = atan2(v.y,v.z);
    float x = v.x, y = v.y, z = v.z;//cos(a*.5 + offx), y = cos(b*.5), z = sin(c*.5);
    
    v2.normalize();
    
    float m = millis()*.0005;
    float n = noise( x*2 + m,y*2 + m,z*2 + m);//sin(noise(x*1+m,y*1+m,z*1+m)*PI);
    
    v2.mult( n*4 );
  }
}


void addTri(int A, int B, int C) {
  tris.add(new PVector(A, B, C));
}

int getMiddlePoint(int p1, int p2) {

  PVector point1 = (PVector)verts.get(p1);//(PVector)orig.get(p1);
  PVector point2 = (PVector)verts.get(p2);//(PVector)orig.get(p2);
  PVector middle = new PVector(
  (point1.x + point2.x) / 2.0, 
  (point1.y + point2.y) / 2.0, 
  (point1.z + point2.z) / 2.0);

  addVert(middle);

  return verts.size()-1;
}


void refine() {
  // refine triangles
  for (int i = 0; i < 1; i++) {
    ArrayList tris2 = new ArrayList();
    for (int j=0; j<tris.size (); j++) {
      PVector tri = (PVector)tris.get(j);

      // replace triangle by 4 triangles
      int a = getMiddlePoint( (int)(tri.x), (int)(tri.y) );
      int b = getMiddlePoint( (int)(tri.y), (int)(tri.z) );
      int c = getMiddlePoint( (int)(tri.z), (int)(tri.x) );


      tris2.add(new PVector(tri.x, a, c));
      tris2.add(new PVector(tri.y, b, a));
      tris2.add(new PVector(tri.z, c, b));
      tris2.add(new PVector(a, b, c));
    }
    tris = tris2;
  }
}


void mouseClicked() {
  refine();
  println("Verts: " + verts.size());
}

void keyReleased() {
  if ( key == 's') {
    print("saving...");
    saveMeshObj();
    println("done.");
  } else if ( key == 'r' ) {
    reset();
  }/*else if(key == 'n'){
    offx = random(100);
    offy = random(100);
    offz = random(100);
    updateVerts();
  }*/else if (key == 't'){
    str = !str;
  }
}




void draw() {
  background(255);
  
  if(str){
    noStroke();
  }else{
    stroke(0);
  }

  fill(255, 0, 0);
  //updateVerts();
  beginShape(TRIANGLE);
  drawTris();
  endShape();

  

  camera1.feed();
  //saveFrame("frames/#####.tif");
}

void drawTris() {

  for (int i=0; i<tris.size (); i++) {

    PVector tri = (PVector)tris.get(i);
    PVector a, b, c;

    a = (PVector)verts.get((int)(tri.x));
    b = (PVector)verts.get((int)(tri.y));
    c = (PVector)verts.get((int)(tri.z));

    colorMode(HSB, 360, 100, 100);
    fill(sqrt(a.x*a.x + a.y*a.y + a.z*a.z)*70 + a.y*20, 100, 100);//abs(a.x)*100, abs(a.y)*100, abs(a.z)*100);
    colorMode(RGB, 255, 255, 255);
    vertex(a.x, a.y, a.z);
    vertex(b.x, b.y, b.z);
    vertex(c.x, c.y, c.z);
  }
}


void saveMeshObj() {


  fileObj = createWriter("mesh" + millis() + ".obj");

  for (int i=0; i<verts.size (); i++) {
    PVector v = (PVector)verts.get(i);
    fileObj.println("v " + v.x + " " + v.y + " " + v.z);
  }
  for (int i=0; i<tris.size (); i++) {
    PVector t = (PVector)tris.get(i);
    fileObj.println("f " + (t.x+1) + " " + (t.y+1) + " " + (t.z+1));
  }
  fileObj.flush();
  fileObj.close();
}


void mouseMoved() {
  //camera1.arc(radians(mouseY - pmouseY));
  //camera1.circle(radians(1));
  //camera1.look(radians(mouseX - pmouseX) / 2.0, radians(mouseY - pmouseY) / 2.0);
  camera1.tumble(radians(mouseX - pmouseX), radians(mouseY - pmouseY));
}

