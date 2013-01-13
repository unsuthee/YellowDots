part of YellowDots;

class Environment 
{
  List<Capsule> capsules;
  Map<String,Agent> agents = {};
  Agent         _pacman;
  PacmanGame    _game;
  
  ////////////////////////////////////////////////////////////////////////////////

  Agent get pacman => _pacman;
  Agent get blinky => agents["Blinky"];
  Agent get pinky  => agents["Pinky"];
  Agent get inky   => agents["Inky"];
  Agent get pokey  => agents["Pokey"];

  ////////////////////////////////////////////////////////////////////////////////

  num chaseTime;
  num scatterTime;
  static const num chaseTimePeriod = 20000;
  static const num scatterTimePeriod = 7000;
  static const num PAUSE_AFTER_EATING_DURATION = 500; // ms

  ////////////////////////////////////////////////////////////////////////////////

  void setupAgents(Layout layout)
  {
    for (String name in layout.agentPos.keys)
    {
      Agent agent = null;
      var pos = layout.agentPos[name];
      // the initial position must be between pos[0] and pos[0] + 1
      Box2D box = new Box2D.AABB( x:pos[0]*DEF.SIZE_BLOCK+DEF.SIZE_BLOCK, 
                                  y:pos[1]*DEF.SIZE_BLOCK+DEF.SIZE_HALF_BLOCK, 
                                  width:DEF.SIZE_AGENT, 
                                  height:DEF.SIZE_AGENT);
      switch (name)
      {
        case "Pacman":
          agent = new PacmanAgent(env: this, box: box);
          _pacman = agent;
          break;
        case "Blinky":
          agent = new Blinky(env: this, box: box);
          agents[name] = agent;
          break;
        case "Pinky":
          agent = new Pinky(env: this, box: box);
          agents[name] = agent;
          break;
        case "Inky":
          agent = new Inky(env: this, box: box);
          agents[name] = agent;
          break;
        case "Pokey":
          agent = new Pokey(env: this, box: box);
          agents[name] = agent;
          break;
        default:
          break;
      }
      if (agent != null)
      {
        agent.onGameRestart();
      }
    }
  }
  
  Environment(PacmanGame game, Layout layout)
  {
    _game = game;
    capsules = new List<Capsule>();
    
    chaseTime = 0;
    scatterTime = scatterTimePeriod;

    for (final pos in layout.capsuleLookup)
    {
      capsules.add(new Capsule(tx:pos[0],ty:pos[1]));
    }
   
    setupAgents(layout);
  }
  
  ////////////////////////////////////////////////////////////////////////////////

  void requestCapsuleTakenEvent()
  {
    for (Agent ghost in agents.values)
    {
      ghost.OnCapsuleTaken();
    }
    pacman.OnCapsuleTaken();
  }
  
  void requestFrightenTimeEnd()
  {
    // ghost start to blink  
    for (Agent ghost in agents.values)
    {
      ghost.OnFrightenTimeEnd();
    }
    pacman.OnFrightenTimeEnd();
  }
 
  void restartGame()
  {
    _game.scoreboard.incLifeCount(-1);
    if (_game.scoreboard.lives == 0)
    {
      _game.setGameover();
    }
    setupAgents(_game.layout);
    _game.dirtyBackground();
  }
  
  void notifyPacmanEaten(Agent eater)
  {
    for (Agent ghost in agents.values)
    {
      ghost.onPacmanEaten(eater);
    }
    pacman.onPacmanEaten(eater);
  }
  
  ////////////////////////////////////////////////////////////////////////////////
 
  void update(num delta)
  {
    if (chaseTime > 0 && scatterTime <= 0)
    {
      chaseTime -= delta;
      if (chaseTime <= 0)
      {
        for (Agent ghost in agents.values)
        {
          ghost.OnForceScatter();
        }
        scatterTime = scatterTimePeriod;
      }
    }
    else if (chaseTime <= 0 && scatterTime > 0)
    {
      scatterTime -= delta;
      if (scatterTime <= 0)
      {
        for (Agent ghost in agents.values)
        {
          ghost.OnForceChase();
        }
        chaseTime = chaseTimePeriod;
      }
    }
    
    for(final capsule in capsules)
    {
      capsule.update(delta);
    }
    
    // check collision with ghosts
    
    var pacmanPos = [pacman.tilex, pacman.tiley];
    List<Agent> colliders = [];
    for(final agent in agents.values)
    {
       if (pacmanPos[0] == agent.tilex && pacmanPos[1] == agent.tiley)
       {
         colliders.add(agent);
       }
    }
    
    bool hasEatenGhost = false;
    if (colliders.length > 0)
    {
      for(Agent agent in colliders)
      {
        if (agent.isEatable())
        {
          agent.onGhostEaten();
          _game.scoreboard.incScore(Scoreboard.GHOST_SCORE);
          _game.scoreboard.drawScore();
          hasEatenGhost = true;
        }
        else if (!agent.isKO())
        {
          notifyPacmanEaten(agent);
          break;
        }
      }
    }
    
    if (hasEatenGhost)
    {
      _game.pauseGame(PAUSE_AFTER_EATING_DURATION);
    }
    
    bool hasCollide = false;
    if (colliders.length <= 0)
    {
      // check collision with capsules
      Capsule removedCapsule = null;
      for(final capsule in capsules)
      {
        if (pacmanPos[0] == capsule.tilex && pacmanPos[1] == capsule.tiley)
        {
          removedCapsule = capsule;
          requestCapsuleTakenEvent();
          _game.scoreboard.incScore(Scoreboard.CAPSULE_SCORE);
          _game.scoreboard.drawScore();
          hasCollide = true;
          break;
        }
      }
      
      if (removedCapsule != null)
      {
        int index = capsules.indexOf(removedCapsule);
        capsules.removeAt(index);
      }
    }
    
    if (!hasCollide)
    {
      // check collision with dots
      Maze maze = new Maze();
      if (maze.removeDotIfExists(row:pacmanPos[1],col:pacmanPos[0]))
      {
        _game.addRemovedDots(row:pacmanPos[1],col:pacmanPos[0]);
        //_game.dirtyBackground();
        _game.scoreboard.incScore(Scoreboard.DOT_SCORE);
        _game.scoreboard.drawScore();
      }
    }
    
    pacman.update(delta);
    for(final agent in agents.values)
    {
      agent.update(delta);
    }    
  }
  
  void draw(CanvasRenderingContext2D ctx)
  {
    for(final capsule in capsules)
    {
      capsule.draw(ctx, DEF.SIZE_AGENT);
    }
    
    pacman.draw(ctx);
    for(final agent in agents.values)
    {
      agent.draw(ctx);
    }    
  }
  
  ////////////////////////////////////////////////////////////////////////////////
}
