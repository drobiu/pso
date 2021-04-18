import java.util.Random;

int n = 30; // number of agents
int g = 5; // number of goals
float c1 = 0.0001f;
float c2 = 0.0001f;
int it = 1;

ArrayList<PVector> points = new ArrayList<PVector>();
ArrayList<PVector> velocities = new ArrayList<PVector>();

ArrayList<PVector> goals = new ArrayList<PVector>();
float[] goalWeights = new float[g * (g + 2)];

ArrayList<PVector> bests = new ArrayList<PVector>();
float[] fits = new float[n];
PVector best = new PVector();
float bestFit = Float.MIN_VALUE;

ArrayList<PVector> history = new ArrayList<PVector>();

boolean conv = false;
float lastB = -1f;

float[] map;
float high = Float.MIN_VALUE;
float low = Float.MAX_VALUE;
PVector realBest;

Random rand = new Random();

void setup() {
  background(#bfbfbf);
  size(640, 480);
  
  for (int i = 0; i < n; i++) {
    points.add(new PVector(rand.nextFloat() * width, rand.nextFloat() * height));
    velocities.add(new PVector(rand.nextFloat() - 0.5f, rand.nextFloat() - 0.5f));
    bests.add(new PVector());
  }
  
  for (int i = 0; i < g + 2; i++) {
    for (int j = 0; j < g; j++) {
      goals.add(new PVector(map(i, 0, g + 2, 100, width + width / (g + 2) - 100), 
        map(j, 0, g, 100, height + height / g - 100)));
      goalWeights[i * g + j] = (float)rand.nextGaussian();
    }  
  }
  
  map = new float[width * height];
  
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
      float fitness = fitness(new PVector(i, j));
      map[i * height + j] = fitness;
      if (fitness > high) realBest = new PVector(i, j);
      high = max(fitness, high);
      low = min(fitness, low);
    }
  }
}

void draw() {
  background(#bfbfbf);
  
  if (it % 200 == 0) {
    colorMode(HSB);
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        
        stroke(map(map[i * height + j], low, high, 20, 235), 200, 200);
        point(i, j);
        
      }
    }
  }
  
  
  fill(#ff0000);
  for (int i = 0; i < g * (g + 2); i++) {
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
  
  fill(#0f0fff);
  ellipse(best.x, best.y, 12, 12);
  fill(#0fff0f);
  ellipse(realBest.x, realBest.y, 12, 12);
}

float fitness(PVector p) {
  float result = 10f;
  for (int i = 0; i < g * (g + 2); i++) {
    result += sqrt(goals.get(i).dist(p)) * goalWeights[i] / 100f;
  }
  //println(result);
  return result;
}

void updateVel(PVector vel, PVector point, PVector pBest, PVector cBest) {
  PVector p = pBest.sub(point).mult(c1 * rand.nextFloat())
   .add(cBest.sub(point).mult(c2 * (it / 100) * rand.nextFloat()));
  vel.add(p).limit(2);
}
