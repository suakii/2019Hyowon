class Bird {
  float x, y, r, velocity, lift, fitness ;
  int score ;
  PVector vel;
  Boolean alive ;
  color c ;
  float rate ;
  String[] history ;
  NeuralNet brain;
  float GRAVITY = .8 ;


  Bird() {
    init();
    c = color(random(256), random(256), random(256));
    rate = .1 ;
    history = new String[1];
    history[0] = this.hashCode() + ","+c ;
    brain = new NeuralNet(8, 16, 2, "sigmoid");
  }
  Bird(Bird papa) {
    init();
    if (random(1)<rate) r = papa.r+randomGaussian() ;
    brain = new NeuralNet(papa.brain);
    brain.mutate(papa.rate);
    rate = papa.rate*.98;
    c = color(red(papa.c)+randomGaussian(), green(papa.c)+randomGaussian(), blue(papa.c)+randomGaussian()) ;
    history = new String[papa.history.length+1];
    for (int i=0; i<papa.history.length; i++) 
      history[i]=papa.history[i];
    
    history[history.length-1] = this.hashCode() + ","+c ;
  }
  void init() {
    x = 50.0;
    y = height/2.0;
    r = 16.0;
    velocity=0.;
    lift = -8.0;
    fitness = 0.;
    score = 0;
    rate = .1 ;
    alive = true ;
  }
  void show() {
    strokeWeight(1);
    fill(c, 127);
    stroke(255);
    ellipse(x, y, r*2, r*2);
  }

  void up() {
    velocity += lift ;
  }
  void update() {
    velocity += GRAVITY ;
    velocity *= 0.9 ;
    y+=velocity;
    score++ ;
  }
  
  
  void think(ArrayList<Pipe> pipes) {
    Pipe pClosest = pipes.get(0);
    for (int i = 1; i < pipes.size(); i++) {
      if ( pipes.get(i).x < pClosest.x  &&  pipes.get(i).x > x ) 
        pClosest = pipes.get(i) ;
    }

    // Now create the inputs to the neural network
    Double[] inputs = new Double[8];
   
    // x position of closest pipe
    inputs[0] = (double)map(pClosest.x, x, width, -1, 1);
    
    // top of closest pipe opening
    inputs[1] = (double)map(pClosest.top, 0, height, -1, 1);
    
    // height of closest pipe opening
    inputs[2] = (double)map(height - pClosest.bottom - pClosest.top, 0, height, -1, 1);
    
    // bird's y position
    inputs[3] = (double)map(y, 0, height, -1, 1);
    
    // bird's y velocity
    inputs[4] = (double)map(velocity, 0, height, -1, 1);
    // bird's size
    inputs[5] = (double)map(r, 0, 20, -1, 1);  
    // Gravity
    inputs[6] = (double)map(GRAVITY, 0, 10, -1, 1);
    // Lift
    inputs[7] = (double)map(lift, -20, 0, -1, 1);
    // Get the outputs from the network
    Double[] action = brain.predict(inputs);
    // Decide to jump or not!
    if (action[1] > action[0]) up();
  }
}
