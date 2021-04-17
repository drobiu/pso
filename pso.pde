import java.util.Random;

int n = 3; // number of agents
int g = 4; // number of goals
float c1 = 0.01f;
float c2 = 0.001f;
int it = 1;

ArrayList<PVector> points = new ArrayList<PVector>();
ArrayList<PVector> velocities = new ArrayList<PVector>();
ArrayList<PVector> goals = new ArrayList<PVector>();
ArrayList<PVector> bests = new ArrayList<PVector>();
float[] fits = new float[n];
PVector best = new PVector();
float bestFit = 0f;

ArrayList<PVector> history = new ArrayList<PVector>();

Random rand = new Random();

void setup() {
  background(#bfbfbf);
  size(640, 480);
  
  for (int i = 0; i < n; i++) {
    points.add(new PVector(rand.nextFloat() * width, rand.nextFloat() * height));
    velocities.add(new PVector(rand.nextFloat() * 2 - 1, rand.nextFloat() * 2 - 1));
    bests.add(new PVector());
  }
  
  for (int i = 0; i < g; i++) {
    goals.add(new PVector(rand.nextFloat() * width, rand.nextFloat() * height));
  }
  
}

void draw() {
  background(#bfbfbf);
  fill(#ff0000);
  for (int i = 0; i < g; i++) {
    PVector goal = goals.get(i);
    ellipse(goal.x, goal.y, 10, 10);
  }
  
  stroke(#ff0000);
  for (int i = 0; i < history.size() - 1; i++) {
    PVector v = history.get(i);
    PVector w = history.get(i + 1);
    line(v.x, v.y, w.x, w.y);
  }
  
  stroke(#000000);
  fill(#ffffff);
  for (int i = 0; i < n; i++) {
    PVector p = points.get(i);
    float cFit = fitness(p);
    
    if (it % 10 == 0) history.add(best.copy());
    
    if (cFit > fits[i]) {
      fits[i] = cFit;
      bests.set(i, p.copy());
    }
    
    if (cFit > bestFit) {
      bestFit = cFit;
      best = p.copy();
    }
    
    ellipse(p.x, p.y, 12, 12);
    PVector end = p.copy().add(velocities.get(i).copy().mult(20));
    line(p.x, p.y, end.x, end.y);
    p.add(velocities.get(i));
    
    updateVel(velocities.get(i), p.copy(), bests.get(i).copy(), best.copy());
    it++;
  }
}

float fitness(PVector p) {
  float result = 100000f;
  for (PVector goal : goals) {
    result -= goal.dist(p);
  }
  return result;
}

void updateVel(PVector vel, PVector point, PVector pBest, PVector cBest) {
  PVector p = pBest.sub(point).mult(c1 * rand.nextFloat())
   .add(cBest.sub(point).mult(c2 * (it / 100) * rand.nextFloat()));
  vel.add(p).limit(2 - ((float) it / 10000));
}
