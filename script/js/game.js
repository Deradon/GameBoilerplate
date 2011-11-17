(function() {
  var Animation, Background, Bullet, Camera, Creep, Eventmanager, Game, Hero, Keyboard, Map, Shape, Spawner, Sprite, State, StateMainMap, Statemanager, Tile, Timer, Tower, TowerMap, Vector, root, stateclass;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  root = this;
  stateclass = {};
  Array.prototype.shuffle = function() {
    return this.sort(function() {
      return 0.5 - Math.random();
    });
  };
  Number.prototype.toHex = function(padding) {
    var hex;
    if (padding == null) {
      padding = 2;
    }
    hex = this.toString(16);
    while (hex.length < padding) {
      hex = "0" + hex;
    }
    return hex;
  };
  Timer = (function() {
    function Timer() {
      this.last_time = new Date().getTime();
      this.delta = 0;
    }
    Timer.prototype.punch = function() {
      var this_time;
      this_time = new Date().getTime();
      this.delta = this_time - this.last_time;
      this.last_time = this_time;
      return this.delta;
    };
    Timer.prototype.timeSinceLastPunch = function() {
      var this_time;
      this_time = new Date().getTime();
      return this_time - this.last_time;
    };
    Timer.prototype.fps = function() {
      return 1000 / this.delta;
    };
    return Timer;
  })();
  Vector = (function() {
    function Vector(x, y) {
      if (x == null) {
        x = 0;
      }
      if (y == null) {
        y = 0;
      }
      this.x = x;
      this.y = y;
    }
    Vector.prototype.clone = function() {
      return new Vector(this.x, this.y);
    };
    Vector.prototype.add = function(vec) {
      return new Vector(this.x + vec.x, this.y + vec.y);
    };
    Vector.prototype.subtract = function(vec) {
      return new Vector(this.x - vec.x, this.y - vec.y);
    };
    Vector.prototype.mult = function(num) {
      return new Vector(this.x * num, this.y * num);
    };
    Vector.prototype.length = function() {
      return Math.sqrt(this.x * this.x + this.y * this.y);
    };
    Vector.prototype.lengthSquared = function() {
      return this.x * this.x + this.y * this.y;
    };
    Vector.prototype.norm = function(factor) {
      var l;
      if (factor == null) {
        factor = 1;
      }
      l = this.length();
      if (l > 0) {
        return this.mult(factor / l);
      } else {
        return null;
      }
    };
    Vector.prototype.scalarProduct = function(vec) {
      return this.x * vec.x + this.y * vec.y;
    };
    Vector.prototype.sameDirection = function(vec) {
      if (this.lengthSquared() < this.add(vec).lengthSquared()) {
        return true;
      } else {
        return false;
      }
    };
    Vector.prototype.angleWith = function(vec) {
      return Math.acos(this.scalarProduct(vec) / this.length() * vec.length());
    };
    Vector.prototype.vectorProduct = function(vec) {
      return this;
    };
    Vector.prototype.projectTo = function(vec) {
      return vec.mult(this.scalarProduct(vec) / vec.lengthSquared());
    };
    Vector.intersecting = function(oa, a, ob, b) {
      var c, col, l, m, mu, mult, n;
      c = ob.subtract(oa);
      b = b.mult(-1);
      col = [];
      col[0] = a.clone();
      col[1] = b.clone();
      col[2] = c.clone();
      l = 0;
      m = 1;
      n = 2;
      mult = col[0].y / col[0].x;
      col[0].y = 0;
      col[1].y = col[1].y - (mult * col[1].x);
      col[2].y = col[2].y - (mult * col[2].x);
      mu = col[n].y / col[m].y;
      return ob.subtract(b.mult(mu));
    };
    Vector.prototype.print = function() {
      return "(" + this.x + ", " + this.y + ")";
    };
    return Vector;
  })();
  Eventmanager = (function() {
    function Eventmanager() {
      this.eventlist = {};
    }
    Eventmanager.prototype.register = function(event, callback) {
      if (this.eventlist[event] == null) {
        this.eventlist[event] = [];
      }
      return this.eventlist[event].push(callback);
    };
    Eventmanager.prototype.trigger = function(event, origin) {
      var callback, _i, _len, _ref, _results;
      _ref = this.eventlist[event];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        callback = _ref[_i];
        _results.push(callback(origin));
      }
      return _results;
    };
    return Eventmanager;
  })();
  Keyboard = (function() {
    function Keyboard() {
      var direction, _i, _len, _ref;
      this.keyarray = [];
      _ref = ['left', 'up', 'right', 'down', 'space'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        direction = _ref[_i];
        this.keyarray[direction] = false;
      }
      $("html").bind("keydown", __bind(function(event) {
        var directions;
        directions = {
          37: "left",
          38: "up",
          39: "right",
          40: "down",
          32: "space"
        };
        return this.keyarray[directions[event.which]] = true;
      }, this));
      $("html").bind("keyup", __bind(function(event) {
        var directions;
        directions = {
          37: "left",
          38: "up",
          39: "right",
          40: "down",
          32: "space"
        };
        return this.keyarray[directions[event.which]] = false;
      }, this));
    }
    Keyboard.prototype.key = function(which) {
      return this.keyarray[which];
    };
    return Keyboard;
  })();
  Game = (function() {
    function Game(width, height) {
      var canvas;
      this.width = width;
      this.height = height;
      this.gameloop = __bind(this.gameloop, this);
      canvas = $('<canvas/>').attr({
        "width": this.width,
        "height": this.height
      });
      $("body").append(canvas);
      this.ctx = canvas[0].getContext('2d');
      this.ctx.font = '400 18px Helvetica, sans-serif';
      this.loop = null;
      this.timer = new Timer;
    }
    Game.prototype.gameloop = function() {
      this.update();
      return this.render();
    };
    Game.prototype.start = function() {
      return this.loop = setInterval(this.gameloop, 1);
    };
    Game.prototype.stop = function() {
      return this.loop.clearInterval();
    };
    Game.prototype.update = function() {
      return this.timer.punch();
    };
    Game.prototype.render = function() {
      return this.ctx.fillText(this.timer.fps().toFixed(1), 20, 20);
    };
    return Game;
  })();
  Map = (function() {
    function Map(hash) {
      this.sprite = hash["sprite"];
      this.tiles = [];
      this.width = 0;
      this.height = 0;
      this.loadMapDataFromImage(hash["mapfile"], hash["pattern"], hash["callback"]);
    }
    Map.prototype.render = function(ctx) {
      var tile, _i, _len, _ref, _results;
      _ref = this.tiles;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tile = _ref[_i];
        _results.push(tile.render(ctx));
      }
      return _results;
    };
    Map.prototype.loadMapDataFromImage = function(file, pattern, callback) {
      var m, map;
      map = new Image();
      map.src = file;
      m = [];
      return $(map).load(__bind(function() {
        var canvas, col, ctx, data, green, i, p, row, s_tile, tile, type, type2, z, _i, _j, _len, _len2, _len3, _ref, _ref10, _ref11, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9, _step;
        canvas = document.createElement("canvas");
        this.width = map.width;
        this.height = map.height;
        canvas.width = map.width;
        canvas.height = map.height;
        ctx = canvas.getContext("2d");
        ctx.drawImage(map, 0, 0);
        data = ctx.getImageData(0, 0, map.width, map.height).data;
        for (i = 0, _len = data.length, _step = 4; i < _len; i += _step) {
          p = data[i];
          row = Math.floor((i / 4) / map.width);
          if ((_ref = m[row]) == null) {
            m[row] = [];
          }
          m[row].push([Number(data[i]).toHex(), Number(data[i + 1]).toHex(), Number(data[i + 2]).toHex(), Number(data[i + 3]).toHex()]);
        }
        switch (pattern) {
          case "towermap":
            for (row = 0, _ref2 = map.height - 2; 0 <= _ref2 ? row <= _ref2 : row >= _ref2; 0 <= _ref2 ? row++ : row--) {
              for (col = 0, _ref3 = map.width - 2; 0 <= _ref3 ? col <= _ref3 : col >= _ref3; 0 <= _ref3 ? col++ : col--) {
                type = "" + m[row][col][0] + m[row][col + 1][0] + m[row + 1][col][0] + m[row + 1][col + 1][0];
                type2 = "" + m[row][col][1] + m[row][col + 1][1] + m[row + 1][col][1] + m[row + 1][col + 1][1];
                green = parseInt(m[row][col][1], 16);
                z = 0;
                this.tiles.push(new Tile(this.sprite, type, type2, row, col, green, z));
              }
            }
            break;
          case "simple":
            for (row = 0, _ref4 = map.height - 1; 0 <= _ref4 ? row <= _ref4 : row >= _ref4; 0 <= _ref4 ? row++ : row--) {
              for (col = 0, _ref5 = map.width - 1; 0 <= _ref5 ? col <= _ref5 : col >= _ref5; 0 <= _ref5 ? col++ : col--) {
                type = "" + m[row][col][0];
                green = parseInt(m[row][col][1], 16);
                z = parseInt(m[row][col][2], 16);
                this.tiles.push(new Tile(this.sprite, type, type2, row, col, green, z));
              }
            }
            break;
          case "square":
            for (row = 0, _ref6 = map.height - 2; 0 <= _ref6 ? row <= _ref6 : row >= _ref6; 0 <= _ref6 ? row++ : row--) {
              for (col = 0, _ref7 = map.width - 2; 0 <= _ref7 ? col <= _ref7 : col >= _ref7; 0 <= _ref7 ? col++ : col--) {
                type = "" + m[row][col][0] + m[row][col + 1][0] + m[row + 1][col][0] + m[row + 1][col + 1][0];
                type2 = "" + m[row][col][1] + m[row][col + 1][1] + m[row + 1][col][1] + m[row + 1][col + 1][1];
                green = parseInt(m[row][col][1], 16);
                z = 0;
                this.tiles.push(new Tile(this.sprite, type, type2, row, col, green, z));
              }
            }
            break;
          case "cross":
            for (row = 1, _ref8 = map.height - 2; row <= _ref8; row += 2) {
              for (col = 1, _ref9 = map.width - 2; col <= _ref9; col += 2) {
                if (m[row][col][0] !== "00") {
                  type = "" + m[row - 1][col][0] + m[row][col + 1][0] + m[row + 1][col][0] + m[row][col - 1][0];
                  green = parseInt(m[row][col][1], 16);
                  z = parseInt(m[row][col][2], 16);
                  this.tiles.push(new Tile(this.sprite, type, type2, row / 2, col / 2, green, z));
                }
              }
            }
        }
        _ref10 = this.tiles;
        for (_i = 0, _len2 = _ref10.length; _i < _len2; _i++) {
          tile = _ref10[_i];
          if (tile.row && tile.col) {
            _ref11 = this.tiles;
            for (_j = 0, _len3 = _ref11.length; _j < _len3; _j++) {
              s_tile = _ref11[_j];
              if ((s_tile.row === (tile.row - 1)) && (tile.col === s_tile.col)) {
                tile.sourrounding["top"] = s_tile;
              }
              if ((s_tile.row === (tile.row + 1)) && (tile.col === s_tile.col)) {
                tile.sourrounding["bottom"] = s_tile;
              }
              if ((s_tile.row === tile.row) && ((tile.col + 1) === s_tile.col)) {
                tile.sourrounding["right"] = s_tile;
              }
              if ((s_tile.row === tile.row) && ((tile.col - 1) === s_tile.col)) {
                tile.sourrounding["left"] = s_tile;
              }
            }
          }
        }
        return callback();
      }, this));
    };
    Map.prototype.tileAtVector = function(vec) {
      var col, row, tile, _i, _len, _ref;
      col = Math.floor(vec.x / this.sprite.innerWidth);
      row = Math.floor(vec.y / this.sprite.innerHeight);
      _ref = this.tiles;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tile = _ref[_i];
        if (tile.col === col && tile.row === row) {
          return tile;
        }
      }
    };
    Map.prototype.vectorAtTile = function(col, row) {
      return new Vector(this.sprite.innerWidth * (col + 0.5), this.sprite.innerHeight * (row + 0.5));
    };
    return Map;
  })();
  Tile = (function() {
    function Tile(sprite, type, type2, row, col, green, z) {
      this.sprite = sprite;
      this.type = type;
      this.type2 = type2;
      this.row = row;
      this.col = col;
      this.green = green != null ? green : 0;
      this.z = z != null ? z : 0;
      this.sourrounding = {
        "left": null,
        "right": null,
        "top": null,
        "bottom": null
      };
    }
    Tile.prototype.isWalkable = function() {
      return this.type === "99999999";
    };
    Tile.prototype.isSpawner = function() {
      return this.type2 === "ffffffff";
    };
    Tile.prototype.isHeroSpawner = function() {
      return this.type2 === "55555555";
    };
    Tile.prototype.isHeroWalkable = function() {
      return this.type === "00000000";
    };
    Tile.prototype.isTarget = function() {
      return this.type2 === "aaaaaaaa";
    };
    Tile.prototype.render = function(ctx) {
      ctx.save();
      ctx.translate(this.col * this.sprite.innerWidth - this.z, this.row * this.sprite.innerHeight - this.z);
      this.sprite.render(this.type, ctx);
      return ctx.restore();
    };
    return Tile;
  })();
  Background = (function() {
    function Background(sprite) {
      this.sprite = sprite;
      this.sprite.addImage("background", 0);
    }
    Background.prototype.render = function(ctx) {
      return this.sprite.render("background", ctx);
    };
    return Background;
  })();
  Sprite = (function() {
    function Sprite(hash) {
      var i, key, _ref, _ref2, _ref3, _ref4;
      this.assets = {};
      this.width = hash["width"];
      this.height = hash["height"];
      this.texture = new Image();
      this.texture.src = hash["texture"];
      this.key = (_ref = hash["key"]) != null ? _ref : {};
      _ref2 = this.key;
      for (key in _ref2) {
        i = _ref2[key];
        this.addImage(key, i);
      }
      this.innerWidth = (_ref3 = hash["innerWidth"]) != null ? _ref3 : this.width;
      this.innerHeight = (_ref4 = hash["innerHeight"]) != null ? _ref4 : this.height;
    }
    Sprite.prototype.addImage = function(name, index) {
      return $(this.texture).load(__bind(function() {
        this.texWidth = this.texture.width;
        return this.assets[name] = new Shape(this, index);
      }, this));
    };
    Sprite.prototype.addAnimation = function(name, params) {
      return $(this.texture).load(__bind(function() {
        this.texWidth = this.texture.width;
        return this.assets[name] = new Animation(this, params);
      }, this));
    };
    Sprite.prototype.render = function(name, ctx) {
      if (this.assets[name] != null) {
        return this.assets[name].render(ctx);
      }
    };
    return Sprite;
  })();
  Shape = (function() {
    function Shape(sprite, index) {
      this.sprite = sprite;
      this.sx = (index * this.sprite.width) % this.sprite.texWidth;
      this.sy = Math.floor((index * this.sprite.width) / this.sprite.texWidth) * this.sprite.height;
    }
    Shape.prototype.render = function(ctx) {
      ctx.save();
      ctx.translate(this.sprite.width / 2, this.sprite.height / 2);
      ctx.drawImage(this.sprite.texture, this.sx, this.sy, this.sprite.width, this.sprite.height, 0, 0, this.sprite.width, this.sprite.height);
      return ctx.restore();
    };
    return Shape;
  })();
  Animation = (function() {
    function Animation(sprite, params) {
      var index, _ref, _ref2, _ref3;
      this.sprite = sprite;
      this.fps = (_ref = params["fps"]) != null ? _ref : 30;
      this.loop = (_ref2 = params["loop"]) != null ? _ref2 : true;
      this.callback = (_ref3 = params["callback"]) != null ? _ref3 : null;
      this.frames = (function() {
        var _i, _len, _ref4, _results;
        _ref4 = params["frames"];
        _results = [];
        for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
          index = _ref4[_i];
          _results.push(new Shape(this.sprite, index));
        }
        return _results;
      }).call(this);
      this.lastFrame = this.frames.length - 1;
      this.timer = new Timer;
      this.currentFrame = 0;
      this.playing = true;
    }
    Animation.prototype.render = function(ctx) {
      if (this.playing) {
        this.currentFrame = Math.floor(this.timer.timeSinceLastPunch() / (1000 / this.fps));
        if (this.currentFrame > this.lastFrame) {
          if (typeof this.callback === "function") {
            this.callback();
          }
          if (this.loop) {
            this.rewind();
          } else {
            this.currentFrame = this.lastFrame;
            this.stop();
          }
        }
      }
      return this.frames[this.currentFrame].render(ctx);
    };
    Animation.prototype.play = function() {
      return this.playing = true;
    };
    Animation.prototype.stop = function() {
      return this.playing = false;
    };
    Animation.prototype.rewind = function() {
      this.currentFrame = 0;
      return this.timer.punch();
    };
    return Animation;
  })();
  State = (function() {
    function State() {}
    State.prototype.update = function() {};
    State.prototype.draw = function() {};
    return State;
  })();
  Statemanager = (function() {
    function Statemanager(parent, states) {
      var state, _i, _len;
      this.parent = parent;
      this.statearray = {};
      this.currentState = null;
      for (_i = 0, _len = states.length; _i < _len; _i++) {
        state = states[_i];
        this.addState(state);
      }
    }
    Statemanager.prototype.addState = function(state) {
      this.statearray[state] = new stateclass[state](this.parent);
      if (this.currentState == null) {
        return this.setState(state);
      }
    };
    Statemanager.prototype.setState = function(state) {
      return this.currentState = this.statearray[state];
    };
    return Statemanager;
  })();
  Camera = (function() {
    function Camera(hash) {
      this.projection = hash["projection"];
      this.vpWidth = hash["vpWidth"];
      this.vpHeight = hash["vpHeight"];
      this.coor = new Vector(100, 100);
    }
    Camera.prototype.update = function(delta) {};
    Camera.prototype.apply = function(ctx, callback) {
      switch (this.projection) {
        case "normal":
          ctx.save();
          ctx.scale(0.3, 0.3);
          ctx.translate(this.vpWidth / 2 - this.coor.x, this.vpHeight / 2 - this.coor.y);
          callback();
          return ctx.restore();
        case "iso":
          ctx.save();
          ctx.scale(1, 0.4);
          ctx.rotate(Math.PI / 4);
          ctx.translate(this.vpWidth / 2 - this.coor.x + 300, this.vpHeight / 2 - this.coor.y - 250);
          callback();
          return ctx.restore();
      }
    };
    return Camera;
  })();
  TowerMap = (function() {
    __extends(TowerMap, Game);
    function TowerMap(width, height) {
      TowerMap.__super__.constructor.call(this, width, height);
      this.eventmanager = new Eventmanager;
      this.keyboard = new Keyboard;
      this.stateManager = new Statemanager(this, ["main_map"]);
      this.stateManager.setState("main_map");
    }
    TowerMap.prototype.update = function() {
      TowerMap.__super__.update.call(this);
      return this.stateManager.currentState.update(this.timer.delta);
    };
    TowerMap.prototype.render = function() {
      this.ctx.clearRect(0, 0, this.width, this.height);
      this.stateManager.currentState.render(this.ctx);
      return TowerMap.__super__.render.call(this);
    };
    return TowerMap;
  })();
  $(function() {
    var tower_map;
    tower_map = new TowerMap(800, 600);
    return tower_map.start();
  });
  stateclass["main_map"] = StateMainMap = (function() {
    __extends(StateMainMap, State);
    function StateMainMap(parent) {
      var beach3d;
      this.parent = parent;
      this.gc = __bind(this.gc, this);
      this.camera = new Camera({
        "projection": "iso",
        "vpWidth": this.parent.width,
        "vpHeight": this.parent.height
      });
      this.creeps = [];
      this.lives = 3;
      this.spawners = [];
      this.towers = [];
      this.garbage_every = 30;
      this.garbage_count = 0;
      beach3d = new Sprite({
        "texture": "assets/images/wc33d.png",
        "width": 107,
        "height": 107,
        "innerWidth": 87,
        "innerHeight": 87,
        "key": {
          "00990000": 0,
          "99000000": 1,
          "00009900": 2,
          "00000099": 3,
          "00990099": 4,
          "99990000": 5,
          "99009900": 6,
          "00009999": 7,
          "99990099": 8,
          "99999900": 9,
          "99009999": 10,
          "00999999": 11,
          "00000000": 12,
          "99999999": 13,
          "00999900": 14,
          "99000099": 15
        }
      });
      this.map = new Map({
        "mapfile": "assets/towermap_map1.png",
        "pattern": "towermap",
        "sprite": beach3d,
        "callback": __bind(function() {
          var tile, _i, _len, _ref, _results;
          _ref = this.map.tiles;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            tile = _ref[_i];
            if (tile.isSpawner()) {
              this.creep = new Creep(this.parent.eventmanager, {
                "coor": this.map.vectorAtTile(tile.col, tile.row),
                "speed": new Vector(0, 0.07)
              });
              this.spawner = new Spawner(this.creep, this.creeps, 5);
              this.spawners.push(this.spawner);
            }
            _results.push(tile.isHeroSpawner() ? this.hero = new Hero(this.parent.eventmanager, this.parent.keyboard, {
              "coor": this.map.vectorAtTile(tile.col, tile.row)
            }) : void 0);
          }
          return _results;
        }, this)
      });
    }
    StateMainMap.prototype.update = function(delta) {
      var creep, spawner, tower, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3;
      this.hero.update(delta, this.map);
      _ref = this.towers;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tower = _ref[_i];
        tower.update(delta, this.creeps);
      }
      this.camera.coor = this.hero.coor;
      _ref2 = this.spawners;
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        spawner = _ref2[_j];
        spawner.update(delta, this.map);
      }
      _ref3 = this.creeps;
      for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
        creep = _ref3[_k];
        if (creep.state === "done") {
          if (creep.checkout === false) {
            this.lives -= creep.checkout = true;
          }
        } else {
          creep.update(delta, this.map);
        }
      }
      if (this.lives < 0) {
        console.log("EPIC FAIL YOU NOOB");
      }
      return this.gc();
    };
    StateMainMap.prototype.render = function(ctx) {
      return this.camera.apply(ctx, __bind(function() {
        var creep, tower, _i, _j, _len, _len2, _ref, _ref2, _results;
        this.map.render(ctx);
        this.hero.render(ctx);
        _ref = this.towers;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          tower = _ref[_i];
          tower.render(ctx);
        }
        _ref2 = this.creeps;
        _results = [];
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          creep = _ref2[_j];
          _results.push(creep.render(ctx));
        }
        return _results;
      }, this));
    };
    StateMainMap.prototype.gc = function() {
      var tower, _i, _len, _ref, _results;
      this.garbage_count += 1;
      if (this.garbage_count > this.garbage_every) {
        this.garbage_count = 0;
        _ref = this.towers;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          tower = _ref[_i];
          _results.push(tower.gc());
        }
        return _results;
      }
    };
    return StateMainMap;
  })();
  Hero = (function() {
    function Hero(eventmanager, keyboard, options) {
      this.eventmanager = eventmanager;
      this.keyboard = keyboard;
      this.sprite = new Sprite({
        "texture": "assets/images/test.png",
        "width": 50,
        "height": 50,
        "key": {
          "normal": 3
        }
      });
      this.state = "normal";
      this.coor = options["coor"];
      this.speed = new Vector(0, 0);
      this.force = 0.01;
      this.decay = 0.95;
    }
    Hero.prototype.update = function(delta, map) {
      var new_coor, new_tile;
      this.determine_speed();
      new_coor = this.coor.add(this.speed.mult(delta));
      new_tile = map.tileAtVector(new_coor);
      if (typeof new_tile.isHeroWalkable === "function" ? new_tile.isHeroWalkable() : void 0) {
        return this.coor = new_coor;
      } else {
        this.speed.y = 0;
        return this.speed.x = 0;
      }
    };
    Hero.prototype.render = function(ctx) {
      ctx.save();
      ctx.translate(this.coor.x, this.coor.y);
      this.sprite.render(this.state, ctx);
      return ctx.restore();
    };
    Hero.prototype.determine_speed = function() {
      if (this.keyboard.key("right")) {
        this.speed.x += this.force;
      } else if (this.keyboard.key("left")) {
        this.speed.x -= this.force;
      } else {
        this.speed.x *= this.decay;
      }
      if (this.keyboard.key("up")) {
        this.speed.y -= this.force;
      } else if (this.keyboard.key("down")) {
        this.speed.y += this.force;
      } else {
        this.speed.y *= this.decay;
      }
      if (this.keyboard.key("space")) {
        this.speed.y = 0.0;
        return this.speed.x = 0.0;
      }
    };
    return Hero;
  })();
  Tower = (function() {
    function Tower(eventmanager, keyboard, options) {
      var _ref, _ref2, _ref3, _ref4, _ref5;
      this.eventmanager = eventmanager;
      this.keyboard = keyboard;
      this.gc = __bind(this.gc, this);
      this.state = "normal";
      this.sprite = new Sprite({
        "texture": "assets/images/enemies.png",
        "width": 50,
        "height": 50,
        "key": {
          "normal": 7,
          "attacking": 3
        }
      });
      this.coor = options["coor"];
      this.hp = (_ref = options["hp"]) != null ? _ref : 100;
      this.range = (_ref2 = options["range"]) != null ? _ref2 : 450;
      this.range *= this.range;
      this.last_target = null;
      this.scan_rate = (_ref3 = options["scan_rate"]) != null ? _ref3 : 500;
      this.fire_rate = (_ref4 = options["fire_rate"]) != null ? _ref4 : 1000;
      this.damage = (_ref5 = options["damage"]) != null ? _ref5 : 100;
      this.current_scan_rate = 0;
      this.bullets = [];
      this.garbage_every = 30;
      this.garbage_count = 0;
    }
    Tower.prototype.update = function(delta, targets) {
      var bullet, _i, _len, _ref, _results;
      this.current_scan_rate += delta;
      if (this.current_scan_rate >= this.scan_rate) {
        this.current_scan_rate -= this.scan_rate;
        this.scan(targets);
      }
      _ref = this.bullets;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        bullet = _ref[_i];
        _results.push(bullet.update(delta, targets));
      }
      return _results;
    };
    Tower.prototype.render = function(ctx) {
      var bullet, _i, _len, _ref, _results;
      ctx.save();
      ctx.translate(this.coor.x, this.coor.y);
      this.sprite.render(this.state, ctx);
      ctx.restore();
      _ref = this.bullets;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        bullet = _ref[_i];
        _results.push(bullet.render(ctx));
      }
      return _results;
    };
    Tower.prototype.scan = function(targets) {
      var target;
      target = this.closest_target(targets);
      if (target != null) {
        this.state = "attacking";
        return this.bullets.push(new Bullet(this.coor, target.coor));
      } else {
        return this.state = "normal";
      }
    };
    Tower.prototype.closest_target = function(targets) {
      var dist, min_range, min_target, target, _i, _len;
      min_range = 999999;
      min_target = null;
      for (_i = 0, _len = targets.length; _i < _len; _i++) {
        target = targets[_i];
        dist = this.coor.subtract(target.coor).lengthSquared();
        if (dist < min_range) {
          min_target = target;
          min_range = dist;
        }
      }
      if (min_range < this.range) {
        return min_target;
      } else {
        return null;
      }
    };
    Tower.prototype.gc = function() {
      var bullet;
      return this.bullets = (function() {
        var _i, _len, _ref, _results;
        _ref = this.bullets;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          bullet = _ref[_i];
          if (bullet.state !== "done") {
            _results.push(bullet);
          }
        }
        return _results;
      }).call(this);
    };
    return Tower;
  })();
  Creep = (function() {
    var newSpeed;
    function Creep(eventmanager, options) {
      var _ref;
      this.eventmanager = eventmanager;
      this.sprite = new Sprite({
        "texture": "assets/images/test.png",
        "width": 50,
        "height": 50,
        "key": {
          "done": 2,
          "normal": 3
        }
      });
      this.checkout = false;
      this.state = "normal";
      this.speed = (_ref = options["speed"]) != null ? _ref : new Vector(0, 0);
      this.coor = options["coor"];
      this.start_coor = this.coor;
    }
    Creep.prototype.update = function(delta, map) {
      var current_tile, new_coor, new_tile;
      current_tile = map.tileAtVector(this.coor);
      if (this.targetReached(current_tile)) {
        if (this.state !== "done") {
          return this.state = "done";
        }
      } else {
        new_coor = this.coor.add(this.speed.mult(delta));
        new_tile = map.tileAtVector(new_coor);
        if (typeof new_tile.isWalkable === "function" ? new_tile.isWalkable() : void 0) {
          return this.coor = new_coor;
        } else {
          return this.speed = newSpeed(current_tile, this.speed);
        }
      }
    };
    Creep.prototype.render = function(ctx) {
      ctx.save();
      ctx.translate(this.coor.x, this.coor.y);
      this.sprite.render(this.state, ctx);
      return ctx.restore();
    };
    Creep.prototype.targetReached = function(tile) {
      return tile.isTarget();
    };
    newSpeed = function(tile, speed) {
      var direction_tile, key, new_speed, test_speed, _ref, _results;
      _ref = tile.sourrounding;
      _results = [];
      for (key in _ref) {
        direction_tile = _ref[key];
        if (direction_tile != null ? typeof direction_tile.isWalkable === "function" ? direction_tile.isWalkable() : void 0 : void 0) {
          switch (key) {
            case "left":
              new_speed = new Vector(-0.07, 0);
              break;
            case "right":
              new_speed = new Vector(0.07, 0);
              break;
            case "top":
              new_speed = new Vector(0, -0.07);
              break;
            case "bottom":
              new_speed = new Vector(0, 0.07);
          }
          test_speed = new_speed.mult(-1);
          if (speed.x !== test_speed.x && speed.y !== test_speed.y) {
            return new_speed;
          }
        }
      }
      return _results;
    };
    return Creep;
  })();
  Bullet = (function() {
    function Bullet(from_coor, to_coor, options) {
      this.explode = __bind(this.explode, this);      this.sprite = new Sprite({
        "texture": "assets/images/enemies.png",
        "width": 50,
        "height": 50,
        "key": {
          "normal": 1,
          "done": 13
        }
      });
      this.sprite.addAnimation("exploding", {
        frames: [0, 1, 2, 3, 4, 13],
        fps: 8,
        loop: false,
        callback: this.explode
      });
      this.state = "normal";
      this.range_traveled = 0;
      this.direction = to_coor.subtract(from_coor).norm();
      this.coor = from_coor;
      this.speed = 1;
      this.damage = 100;
      this.max_range = 600;
      this.splash_radius = 50;
      this.splash_damage = 10;
      this.trigger_range = 225;
    }
    Bullet.prototype.update = function(delta, targets) {
      var new_dist;
      if (this.state === "normal") {
        new_dist = delta * this.speed;
        if (this.range_traveled + new_dist >= this.max_range) {
          new_dist = this.max_range - this.range_traveled;
        }
        this.range_traveled += new_dist;
        this.coor = this.coor.add(this.direction.mult(new_dist));
        this.target = this.closest_target(targets);
        if (this.target) {
          this.state = "exploding";
        }
        if (this.range_traveled >= this.max_range) {
          return this.state = "done";
        }
      }
    };
    Bullet.prototype.render = function(ctx) {
      ctx.save();
      ctx.translate(this.coor.x, this.coor.y);
      this.sprite.render(this.state, ctx);
      return ctx.restore();
    };
    Bullet.prototype.closest_target = function(targets) {
      var dist, min_range, min_target, target, _i, _len;
      min_range = 999999;
      min_target = null;
      for (_i = 0, _len = targets.length; _i < _len; _i++) {
        target = targets[_i];
        dist = this.coor.subtract(target.coor).lengthSquared();
        if (dist < min_range) {
          min_target = target;
          min_range = dist;
        }
      }
      if (min_range < this.trigger_range) {
        return min_target;
      } else {
        return null;
      }
    };
    Bullet.prototype.explode = function() {
      return this.state = "done";
    };
    return Bullet;
  })();
  Spawner = (function() {
    function Spawner(creep, creeps, quantity) {
      this.creep = creep;
      this.creeps = creeps;
      this.quantity = quantity;
      this.spawn_rate = 1500;
      this.current_spawn_rate = 0;
      this.creep.speed = new Vector(0, 0.07);
    }
    Spawner.prototype.update = function(delta, map) {
      if (this.quantity > 0) {
        this.current_spawn_rate += delta;
        if (this.current_spawn_rate >= this.spawn_rate) {
          this.current_spawn_rate -= this.spawn_rate;
          this.spawn();
          return this.quantity -= 1;
        }
      }
    };
    Spawner.prototype.render = function(ctx) {};
    Spawner.prototype.spawn = function() {
      var new_creep;
      new_creep = new Creep(this.creep.eventmanager, {
        "coor": this.creep.coor,
        "speed": this.creep.speed
      });
      return this.creeps.push(new_creep);
    };
    return Spawner;
  })();
}).call(this);
