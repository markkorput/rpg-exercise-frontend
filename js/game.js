// Generated by CoffeeScript 1.6.3
(function() {
  var _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  this.GameView = (function(_super) {
    __extends(GameView, _super);

    function GameView() {
      _ref = GameView.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    GameView.prototype.initialize = function() {
      var no_func, yes_func;
      this.game = new Game();
      this.game_states = new Backbone.Collection([this.getCurrentState()]);
      this.render();
      this.$el.hide();
      this.game_ui = new GameUi();
      this.game_visuals = new GameVisuals({
        game_states: this.game_states
      });
      yes_func = (function() {
        var _this = this;
        return this.game_visuals.answerYesTween().start().onComplete(function() {
          return _this.trigger('answer', _this.getAnswer('Yes'));
        });
      });
      no_func = (function() {
        var _this = this;
        return this.game_visuals.answerNoTween().start().onComplete(function() {
          return _this.trigger('answer', _this.getAnswer('No'));
        });
      });
      this.game_ui.on('answer-yes', yes_func, this);
      this.game_ui.on('answer-no', no_func, this);
      this.game_ui.on('toggle-stats', (function() {
        return this.$el.toggle();
      }), this);
      this.game_visuals.on('answer-yes', yes_func, this);
      this.game_visuals.on('answer-no', no_func, this);
      this.on('answer', (function(answer) {
        return this.game.submitAnswer(answer);
      }), this);
      this.game.on('change', this.renderGame, this);
      this.game.on('change', this.renderStats, this);
      this.game.user.on('change', this.renderStats, this);
      this.game.submissions.on('change', this.renderStats, this);
      this.game.submissions.on('add', (function() {
        return this.game_states.add([this.getCurrentState()]);
      }), this);
      this.game.on('new-question', (function(question) {
        return this.game_visuals.showQuestion(question);
      }), this);
      all_questions.fetchOrInit();
      return this.game.nextQuestion();
    };

    GameView.prototype.game_el = function() {
      return this.$el.find('#current-question');
    };

    GameView.prototype.stats_el = function() {
      return this.$el.find('#game-stats');
    };

    GameView.prototype.getAnswer = function(txt) {
      return this.game.current_question().answers().findWhere({
        text: txt
      });
    };

    GameView.prototype.getCurrentState = function() {
      return new Backbone.Model({
        number_of_answers: this.game.submissions.length,
        skills: this.game.user.skillsClone()
      });
    };

    GameView.prototype.render = function() {
      this.$el.html('<h1>Next Question</h1><div id="current-question"></div><h1>Game Stats</h1><ul id="game-stats"></ul>');
      this.renderGame();
      this.renderStats();
      return this;
    };

    GameView.prototype.renderGame = function() {
      var q,
        _this = this;
      this.game_el().html('');
      if (q = this.game.current_question()) {
        this.game_el().append('<h2>' + q.get('text') + '</h2>');
        return q.answers().each(function(answer) {
          var button;
          button = $('<button>' + answer.get('text') + '</button>');
          button.on('click', function(event) {
            return _this.trigger('answer', answer);
          });
          return _this.game_el().append(button);
        });
      }
    };

    GameView.prototype.renderStats = function() {
      var skills_el, skills_line, state;
      this.stats_el().html('');
      state = this.getCurrentState();
      if (this.game.user) {
        this.stats_el().append('<li>User: ' + this.game.user.get('name') + '</li>');
      }
      this.stats_el().append('<li>Questions answered: ' + state.get('number_of_answers') + '</li>');
      skills_el = $('<ul></ul>');
      (state.get('skills') || new Backbone.Collection).each(function(skill) {
        return skills_el.append('<li>' + skill.get('text') + ': ' + skill.get('score') + '</li>');
      });
      skills_line = $('<li></li>');
      skills_line.append(skills_el);
      return this.stats_el().append(skills_line);
    };

    return GameView;

  })(Backbone.View);

}).call(this);
