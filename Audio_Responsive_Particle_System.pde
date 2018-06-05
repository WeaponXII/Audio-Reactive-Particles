import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

Minim minim;
AudioInput player;
AudioOutput out;
AudioInput in;
FFT fft;
BeatDetect beat;
ParticleSystem ps;

void setup() {
  size(1024, 780);
  minim = new Minim( this );
  
  player = minim.getLineIn(Minim.STEREO,1024);
  
  fft = new FFT (player.bufferSize(), 1024);
  beat = new BeatDetect(); 
  ps = new ParticleSystem(new PVector(width, height/2));
}

void draw() {
  background(0);
  ps.addParticle();
  ps.run();
  fft.forward(player.mix);
  
}


// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;

  ParticleSystem(PVector position) {
    origin = position.copy();
    particles = new ArrayList<Particle>();
  }

  void addParticle() {
    particles.add(new Particle(origin));
  }

  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
}


// A simple Particle class

class Particle {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float lifespan;

  Particle(PVector l) {
    acceleration = new PVector(0-fft.getBand(50), 0-(fft.getBand(50)));
    velocity = new PVector(random(-1, 0), random(-3, -1));
    position = l.copy();
    lifespan = 300;
  }

  void run() {
    update();
    display();
  }

  // Method to update position
  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    lifespan -= 1.0;
  }

  // Method to display
  void display() {
    stroke(255, lifespan);
    fill(255, lifespan);
    ellipse(position.x, position.y,fft.getBand(50), fft.getBand(50));
  
    // detect boundary collision
  // right
  if (position.x > width) {
    position.x = width;
    velocity.x *= -1;
  }
  // left 
  if (position.x < 0) {
    position.x = 0;
    velocity.x *= -1;
  }
  // top
  if (position.y < height) {
    position.y = height; 
  }
  }
  // Is the particle still useful?
  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
}
void stop()
{
  player.close();
  minim.stop();
}
}
